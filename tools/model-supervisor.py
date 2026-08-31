#!/usr/bin/env python3
"""Loopback supervisor that exposes model discovery and safe model switching."""

from __future__ import annotations

import argparse
import http.client
import json
import os
import signal
import subprocess
import threading
import time
import socket
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlsplit

MODEL_EXTENSIONS = {".safetensors", ".ckpt", ".gguf", ".bin"}


class State:
    def __init__(self, args: argparse.Namespace) -> None:
        self.args = args
        self.root = Path(args.root).resolve()
        self.models_dir = (self.root / "models").resolve()
        self.child: subprocess.Popen[bytes] | None = None
        self.model = ""
        self.lock = threading.RLock()

    def models(self) -> list[dict[str, object]]:
        entries: list[dict[str, object]] = []
        if not self.models_dir.is_dir():
            return entries
        for path in sorted(self.models_dir.iterdir()):
            if not path.is_file() or path.suffix.lower() not in MODEL_EXTENSIONS:
                continue
            relative = path.relative_to(self.root).as_posix()
            entries.append({
                "name": path.stem,
                "path": relative,
                "size_bytes": path.stat().st_size,
                "active": relative == self.model,
            })
        return entries

    def resolve_model(self, value: str) -> Path:
        candidate = (self.root / value).resolve()
        if candidate.parent != self.models_dir:
            raise ValueError("model must be a file directly inside models/")
        if not candidate.is_file() or candidate.suffix.lower() not in MODEL_EXTENSIONS:
            raise ValueError("model is not a supported file in models/")
        return candidate

    def start(self, model: str) -> None:
        path = self.resolve_model(model)
        command = [
            self.args.server,
            "--model", str(path),
            "--listen-ip", "127.0.0.1",
            "--listen-port", str(self.args.child_port),
            "--lora-model-dir", str(self.root / self.args.lora_dir),
            "--lora-apply-mode", self.args.lora_apply_mode,
            "--serve-html-path", str(self.root / self.args.frontend),
            "--backend", self.args.backend,
        ]
        if self.args.vae_tiling == "1":
            command.append("--vae-tiling")
        child = subprocess.Popen(command)
        deadline = time.monotonic() + 120
        while time.monotonic() < deadline:
            if child.poll() is not None:
                raise RuntimeError(f"sd-server exited with code {child.returncode} while loading {path.name}")
            try:
                connection = http.client.HTTPConnection("127.0.0.1", self.args.child_port, timeout=1)
                connection.request("GET", "/sdcpp/v1/capabilities")
                response = connection.getresponse()
                response.read()
                connection.close()
                if response.status < 500:
                    self.child = child
                    self.model = path.relative_to(self.root).as_posix()
                    print(f"Modelo activo: {self.model}", flush=True)
                    return
            except (OSError, http.client.HTTPException):
                time.sleep(0.5)
        child.terminate()
        child.wait(timeout=10)
        raise RuntimeError(f"timeout while loading {path.name}")

    def stop(self) -> None:
        if not self.child or self.child.poll() is not None:
            return
        self.child.send_signal(signal.SIGTERM)
        try:
            self.child.wait(timeout=10)
        except subprocess.TimeoutExpired:
            self.child.kill()
            self.child.wait(timeout=5)
        self.child = None

    def switch(self, model: str) -> None:
        with self.lock:
            self.resolve_model(model)
            previous = self.model
            self.stop()
            time.sleep(0.2)
            try:
                self.start(model)
            except Exception:
                if previous:
                    print(f"Cambio fallido; restaurando {previous}", flush=True)
                    self.start(previous)
                raise

    def shutdown(self) -> None:
        with self.lock:
            self.stop()


class Handler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

    def _json(self, status: int, value: object) -> None:
        payload = json.dumps(value).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def _proxy(self) -> None:
        state: State = self.server.state  # type: ignore[attr-defined]
        parsed = urlsplit(self.path)
        body = None
        length = int(self.headers.get("Content-Length", "0"))
        if length:
            body = self.rfile.read(length)
        headers = {key: value for key, value in self.headers.items() if key.lower() not in {"host", "content-length"}}
        try:
            with state.lock:
                connection = http.client.HTTPConnection("127.0.0.1", state.args.child_port, timeout=600)
                connection.request(self.command, parsed.path + (f"?{parsed.query}" if parsed.query else ""), body, headers)
                response = connection.getresponse()
                payload = response.read()
                response_headers = dict(response.getheaders())
                connection.close()
            self.send_response(response.status)
            for key, value in response_headers.items():
                if key.lower() not in {"connection", "transfer-encoding", "content-length"}:
                    self.send_header(key, value)
            self.send_header("Content-Length", str(len(payload)))
            self.end_headers()
            self.wfile.write(payload)
        except Exception as exc:  # pragma: no cover - exercised by the running server
            self._json(503, {"error": f"model server unavailable: {exc}"})

    def do_GET(self) -> None:  # noqa: N802
        state: State = self.server.state  # type: ignore[attr-defined]
        if self.path == "/deep-diffusion/models":
            self._json(200, {"models": state.models(), "active": state.model})
            return
        self._proxy()

    def do_POST(self) -> None:  # noqa: N802
        if self.path == "/deep-diffusion/models/select":
            length = int(self.headers.get("Content-Length", "0"))
            try:
                body = json.loads(self.rfile.read(length) or b"{}")
                model = str(body.get("model", ""))
                self.server.state.switch(model)  # type: ignore[attr-defined]
                self._json(200, {"active": self.server.state.model})  # type: ignore[attr-defined]
            except (ValueError, json.JSONDecodeError, OSError) as exc:
                self._json(400, {"error": str(exc)})
            return
        self._proxy()

    def log_message(self, format: str, *args: object) -> None:
        print(f"[supervisor] {format % args}", flush=True)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", required=True)
    parser.add_argument("--server", required=True)
    parser.add_argument("--model", required=True)
    parser.add_argument("--frontend", required=True)
    parser.add_argument("--lora-dir", required=True)
    parser.add_argument("--lora-apply-mode", default="immediately")
    parser.add_argument("--backend", required=True)
    parser.add_argument("--vae-tiling", default="1")
    parser.add_argument("--port", type=int, default=1234)
    parser.add_argument("--child-port", type=int, default=1235)
    args = parser.parse_args()
    state = State(args)
    try:
        for port, label in ((args.port, "web"), (args.child_port, "engine")):
            probe = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            try:
                probe.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
                probe.bind(("127.0.0.1", port))
            except OSError as exc:
                raise RuntimeError(f"{label} port 127.0.0.1:{port} is already in use; stop the previous deep-diffusion process first") from exc
            finally:
                probe.close()
        server = ThreadingHTTPServer(("127.0.0.1", args.port), Handler)
        state.start(args.model)
        server.state = state  # type: ignore[attr-defined]
        print(f"Interfaz local: http://127.0.0.1:{args.port}", flush=True)
    except Exception as exc:
        state.shutdown()
        print(f"No se pudo iniciar deep-diffusion: {exc}", flush=True)
        return 1
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()
        state.shutdown()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

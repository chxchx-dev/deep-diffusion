# deep-diffusion-webui

A lightweight React + Vite web UI for `stable-diffusion.cpp` servers that expose the native `sdcpp` API.

It is designed for two use cases:

- run as a standalone frontend during local development
- build into a single HTML file that can be embedded into `sd-server`

## What It Does

`deep-diffusion-webui` talks directly to the native server endpoints:

- `GET /sdcpp/v1/capabilities`
- `POST /sdcpp/v1/img_gen`
- `POST /sdcpp/v1/vid_gen`
- `GET /sdcpp/v1/jobs/:id`
- `POST /sdcpp/v1/jobs/:id/cancel`

The current UI supports:

- image generation through the native async API
- prompt and negative prompt editing
- width, height, seed and batch count
- sampler, steps, CFG and seed controls
- LoRA selection from server capabilities
- VAE tiling controls
- cache controls
- job polling, cancellation and image preview
- local model discovery and model switching through the loopback supervisor
- built-in generation recipes for anime, portraits, landscapes, logos and icons
- browser-local presets and reproducible execution history
- contextual `?` help with recommendations for prompts and hardware-safe settings

## Requirements

- Node.js `>= 20`
- `pnpm` `>= 10`
- a running `stable-diffusion.cpp` server with the `sdcpp` API enabled

## Development

Install dependencies:

```bash
pnpm install
```

Start the dev server:

```bash
pnpm dev
```

In another terminal, start the local backend with `pnpm web`. Vite proxies
`/sdcpp/*` and `/deep-diffusion/*` to `http://127.0.0.1:1234`, so the React interface
works during development without manually configuring CORS. Override that
target in `web/.env` using `VITE_API_PROXY_TARGET` if needed.

The UI lets you set the backend base URL in the Settings tab.  
If left empty, requests go to the current origin.

## Production Build

Build a production bundle:

```bash
pnpm build
```

This project uses `vite-plugin-singlefile`, so the output is emitted as a self-contained `dist/index.html`.

Preview the production build locally:

```bash
pnpm preview
```

## Embedding Into `sd-server`

If you want to ship the UI inside `stable-diffusion.cpp`, first build the frontend:

```bash
pnpm build
```

Then generate the C header:

```bash
pnpm build:header
```

That produces:

```text
dist/gen_index_html.h
```

The generated header contains the built HTML as a byte array, which can be compiled into the server binary.

## Type Checking

Run:

```bash
pnpm type-check
```

## Project Layout

```text
src/
  components/   reusable UI pieces
  lib/          API, form mapping, image helpers, settings helpers
  App.tsx       main application shell
  main.tsx      app entry
  styles.css    global styles
scripts/
  build_gen_index_html.js
```

## Notes

- This UI is intentionally local. Most selectable options come from the server's `capabilities` response.
- The Presets panel includes built-in generation recipes with prompts and settings for anime characters, portraits, landscapes, logos, and product icons. They are editable starting points, not an image gallery.
- The Output panel keeps a local execution history with reproducible settings; history export excludes generated media and auxiliary image data.
- It assumes the backend handles CORS correctly if the frontend is served from a different origin.
- It is scoped to the native `sdcpp` API, not the OpenAI-compatible routes and not the A1111-compatible `sdapi` routes.

## License

This frontend retains the upstream license notice in [`LICENSE`](LICENSE).
That notice applies to the web frontend code and is separate from the root
project's distribution status.

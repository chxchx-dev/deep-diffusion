import { snapshotForm } from "./presets";
import type { GenerationForm, GenerationMode, Job } from "./types";

const STORAGE_KEY = "deep-diffusion-generation-history";
const MAX_ENTRIES = 30;

export interface GenerationHistoryEntry {
  id: string;
  created_at: string;
  completed_at?: string;
  mode: GenerationMode;
  status: string;
  job_id?: string;
  form: Partial<GenerationForm>;
  request: Record<string, unknown>;
  error?: string;
}

function readHistory(): GenerationHistoryEntry[] {
  try {
    const raw = window.localStorage.getItem(STORAGE_KEY);
    const value = raw ? JSON.parse(raw) : [];
    return Array.isArray(value) ? value : [];
  } catch {
    return [];
  }
}

function writeHistory(entries: GenerationHistoryEntry[]): void {
  window.localStorage.setItem(STORAGE_KEY, JSON.stringify(entries.slice(0, MAX_ENTRIES)));
}

function withoutImages(request: unknown): Record<string, unknown> {
  const copy = request && typeof request === "object"
    ? JSON.parse(JSON.stringify(request)) as Record<string, unknown>
    : {};
  for (const key of ["init_image", "end_image", "mask_image", "control_image", "ref_images", "control_frames"]) {
    delete copy[key];
  }
  return copy;
}

export function listHistory(): GenerationHistoryEntry[] {
  return readHistory().sort((a, b) => b.created_at.localeCompare(a.created_at));
}

export function addHistory(mode: GenerationMode, form: GenerationForm, request: unknown, job: Job): GenerationHistoryEntry {
  const entry: GenerationHistoryEntry = {
    id: `${Date.now()}-${Math.random().toString(36).slice(2, 8)}`,
    created_at: new Date().toISOString(),
    mode,
    status: job.status || "queued",
    job_id: job.id,
    form: snapshotForm(form),
    request: withoutImages(request),
  };
  writeHistory([entry, ...readHistory()]);
  return entry;
}

export function updateHistory(id: string, job: Job, error?: string): void {
  const entries = readHistory();
  const entry = entries.find((item) => item.id === id);
  if (!entry) return;
  entry.status = job.status || entry.status;
  entry.job_id = job.id || entry.job_id;
  if (error) entry.error = error;
  if (!["queued", "generating"].includes(entry.status)) {
    entry.completed_at = new Date().toISOString();
  }
  writeHistory(entries);
}

export function removeHistory(id: string): void {
  writeHistory(readHistory().filter((entry) => entry.id !== id));
}

export function clearHistory(): void {
  writeHistory([]);
}

export function exportHistory(): string {
  return JSON.stringify({
    schema_version: 1,
    project: "deep-diffusion",
    exported_at: new Date().toISOString(),
    executions: listHistory(),
  }, null, 2) + "\n";
}

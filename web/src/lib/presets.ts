import type { GenerationForm } from "./types";

const STORAGE_KEY = "sdcpp-webui-generation-presets";

export interface GenerationPreset {
  name: string;
  updated_at: string;
  form: Partial<GenerationForm>;
}

export interface PresetBundle {
  schema_version: 1;
  project: "deep-n";
  exported_at: string;
  presets: GenerationPreset[];
}

function readPresets(): GenerationPreset[] {
  try {
    const raw = window.localStorage.getItem(STORAGE_KEY);
    const value = raw ? JSON.parse(raw) : [];
    if (!Array.isArray(value)) return [];
    return value.filter((item): item is GenerationPreset => {
      return Boolean(item && typeof item.name === "string" && item.form && typeof item.form === "object");
    });
  } catch {
    return [];
  }
}

function writePresets(presets: GenerationPreset[]): void {
  window.localStorage.setItem(STORAGE_KEY, JSON.stringify(presets));
}

export function listPresets(): GenerationPreset[] {
  return readPresets().sort((a, b) => a.name.localeCompare(b.name));
}

export function snapshotForm(form: GenerationForm): Partial<GenerationForm> {
  const snapshot = JSON.parse(JSON.stringify(form)) as Partial<GenerationForm>;
  // Auxiliary images are intentionally session-only and are never persisted.
  delete snapshot.init_image;
  delete snapshot.end_image;
  delete snapshot.ref_images;
  delete snapshot.control_frames;
  delete snapshot.mask_image;
  delete snapshot.control_image;
  return snapshot;
}

export function savePreset(name: string, form: GenerationForm): GenerationPreset {
  const normalizedName = name.trim();
  if (!normalizedName) {
    throw new Error("Preset name is required.");
  }
  const preset: GenerationPreset = {
    name: normalizedName,
    updated_at: new Date().toISOString(),
    form: snapshotForm(form),
  };
  const presets = readPresets().filter((item) => item.name !== normalizedName);
  presets.push(preset);
  writePresets(presets);
  return preset;
}

export function removePreset(name: string): void {
  writePresets(readPresets().filter((item) => item.name !== name));
}

export function exportPresets(): string {
  const bundle: PresetBundle = {
    schema_version: 1,
    project: "deep-n",
    exported_at: new Date().toISOString(),
    presets: listPresets(),
  };
  return JSON.stringify(bundle, null, 2) + "\n";
}

export function importPresets(serialized: string): number {
  const parsed: unknown = JSON.parse(serialized);
  const incoming = Array.isArray(parsed)
    ? parsed
    : parsed && typeof parsed === "object" && Array.isArray((parsed as { presets?: unknown }).presets)
      ? (parsed as { presets: unknown[] }).presets
      : null;
  if (!incoming) {
    throw new Error("Invalid preset file: expected a preset list.");
  }
  const valid = incoming.filter((item): item is GenerationPreset => {
    return Boolean(item && typeof item === "object" &&
      typeof (item as GenerationPreset).name === "string" &&
      (item as GenerationPreset).form && typeof (item as GenerationPreset).form === "object");
  });
  if (!valid.length) {
    throw new Error("The preset file contains no valid presets.");
  }
  const merged = readPresets();
  for (const preset of valid) {
    const index = merged.findIndex((item) => item.name === preset.name);
    if (index >= 0) merged[index] = preset;
    else merged.push(preset);
  }
  writePresets(merged);
  return valid.length;
}

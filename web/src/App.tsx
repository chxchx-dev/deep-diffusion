import { useEffect, useMemo, useRef, useState } from "react";
import HelpTip from "./components/HelpTip";
import { cancelJob, getCapabilities, getJob, getModels, selectModel, submitImageJob, submitVideoJob } from "./lib/api";
import { buildRequestBodyForMode, CACHE_MODES, createBlankForm, formFromCapabilities } from "./lib/form";
import { IMAGE_INPUTS } from "./lib/image-inputs";
import { EXAMPLE_PRESETS } from "./lib/example-presets";
import { addHistory, clearHistory, exportHistory, listHistory, removeHistory, updateHistory, type GenerationHistoryEntry } from "./lib/history";
import { exportPresets, importPresets, listPresets, removePreset, savePreset, type GenerationPreset } from "./lib/presets";
import { createStoredRef, normalizePollIntervalMs } from "./lib/settings";
import type { AvailableModel, Capabilities, GenerationForm, Job, SampleParams } from "./lib/types";

type Tab = "image" | "settings";

function clone<T>(value: T): T { return JSON.parse(JSON.stringify(value)); }
function formatBytes(value: number): string { return `${(value / 1024 / 1024 / 1024).toFixed(2)} GiB`; }
function HelpLabel({ children, text }: { children: React.ReactNode; text: string }) { return <label>{children} <HelpTip text={text} /></label>; }

function Section({ title, help, children }: { title: string; help: string; children: React.ReactNode }) {
    const [open, setOpen] = useState(true);
    return <section className="advanced-panel module-card stack-top">
        <button className="advanced-group__toggle" type="button" onClick={() => setOpen(!open)}>
            <span className="module-card__copy"><span className="module-card__eyebrow">{title} <HelpTip text={help} /></span></span>
            <span className="module-card__action">{open ? "Hide" : "Show"}</span>
        </button>
        {open && <div className="advanced-group__content">{children}</div>}
    </section>;
}

export default function App() {
    const baseUrl = createStoredRef<string>("deep-diffusion-base-url", import.meta.env.VITE_API_BASE_URL || "", (v) => String(v || ""));
    const pollSetting = createStoredRef<number>("deep-diffusion-poll-interval-ms", 100, normalizePollIntervalMs);
    const [pollInterval, setPollInterval] = useState(pollSetting.value);
    const [tab, setTab] = useState<Tab>("image");
    const [form, setForm] = useState<GenerationForm>(createBlankForm());
    const [capabilities, setCapabilities] = useState<Capabilities | null>(null);
    const [models, setModels] = useState<AvailableModel[]>([]);
    const [activeModel, setActiveModel] = useState("");
    const [selectedModel, setSelectedModel] = useState("");
    const [job, setJob] = useState<Job | null>(null);
    const [message, setMessageState] = useState("");
    const [messageTone, setMessageTone] = useState("");
    const [presets, setPresets] = useState<GenerationPreset[]>([]);
    const [presetName, setPresetName] = useState("");
    const [selectedPreset, setSelectedPreset] = useState("");
    const [example, setExample] = useState("");
    const [history, setHistory] = useState<GenerationHistoryEntry[]>([]);
    const [selectedHistory, setSelectedHistory] = useState("");
    const [switching, setSwitching] = useState(false);
    const fileRef = useRef<HTMLInputElement>(null);
    const historyId = useRef("");
    const setMessage = (text: string, tone = "") => { setMessageState(text); setMessageTone(tone); };

    const modelName = capabilities?.model?.stem || capabilities?.model?.name || activeModel || "No model info";
    const availableLoras = capabilities?.loras || [];
    const samplers = capabilities?.samplers || ["default"];
    const currentJob = job?.status || "idle";
    const running = currentJob === "queued" || currentJob === "generating";
    const image = job?.kind === "img_gen" ? job.result?.images?.[0] : undefined;
    const imageSrc = image ? `data:image/${job?.result?.output_format || "png"};base64,${image.b64_json}` : "";
    const outputFormats = capabilities?.output_formats_by_mode?.img_gen || ["png", "jpeg"];
    const refresh = async () => {
        try {
            const [caps, catalog] = await Promise.all([getCapabilities(baseUrl.value), getModels(baseUrl.value)]);
            setCapabilities(caps); setModels(catalog.models); setActiveModel(catalog.active); setSelectedModel(catalog.active);
            setForm(formFromCapabilities(caps));
        } catch (error) { setMessage(error instanceof Error ? error.message : String(error), "error"); }
    };
    useEffect(() => { setPresets(listPresets()); setHistory(listHistory()); void refresh(); }, []);
    useEffect(() => { pollSetting.value = normalizePollIntervalMs(pollInterval); }, [pollInterval]);

    const update = (key: keyof GenerationForm, value: unknown) => setForm((old) => ({ ...old, [key]: value }));
    const updateSample = (key: keyof SampleParams, value: unknown) => setForm((old) => ({ ...old, sample_params: { ...old.sample_params, [key]: value } }));
    const updateGuidance = (key: string, value: unknown) => setForm((old) => ({ ...old, sample_params: { ...old.sample_params, guidance: { ...old.sample_params.guidance, [key]: value } } }));
    const apply = (next: Partial<GenerationForm>) => setForm((old) => Object.assign(clone(createBlankForm()), old, next));

    const chooseExample = (name: string) => { setExample(name); const found = EXAMPLE_PRESETS.find((item) => item.name === name); if (found) { apply(found.form); setMessage(`Example loaded: ${name}`); } };
    const choosePreset = (name: string) => { setSelectedPreset(name); const found = presets.find((item) => item.name === name); if (found) { apply(found.form); setMessage(`Preset loaded: ${name}`); } };
    const saveCurrent = () => { try { const saved = savePreset(presetName, form); setPresets(listPresets()); setSelectedPreset(saved.name); setPresetName(""); setMessage(`Preset saved: ${saved.name}`, "success"); } catch (e) { setMessage(e instanceof Error ? e.message : String(e), "error"); } };
    const downloadJson = (name: string, body: string) => { const a = document.createElement("a"); a.href = URL.createObjectURL(new Blob([body], { type: "application/json" })); a.download = name; a.click(); URL.revokeObjectURL(a.href); };
    const importFile = async (event: React.ChangeEvent<HTMLInputElement>) => { const file = event.target.files?.[0]; event.target.value = ""; if (!file) return; try { importPresets(await file.text()); setPresets(listPresets()); setMessage("Presets imported.", "success"); } catch (e) { setMessage(e instanceof Error ? e.message : String(e), "error"); } };
    const switchModel = async () => { if (!selectedModel || selectedModel === activeModel) return; setSwitching(true); setMessage("Switching model and restarting local engine…"); try { const response = await selectModel(baseUrl.value, selectedModel); setActiveModel(response.active); await refresh(); setMessage(`Model active: ${response.active}`, "success"); } catch (e) { setMessage(e instanceof Error ? e.message : String(e), "error"); } finally { setSwitching(false); } };
    const loadHistory = () => { const entry = history.find((item) => item.id === selectedHistory); if (entry) { apply(entry.form); setMessage(`Execution loaded: ${entry.status}`, "success"); } };

    const poll = async (id: string) => { try { const next = await getJob(baseUrl.value, id); setJob(next); if (["queued", "generating"].includes(next.status)) { window.setTimeout(() => void poll(id), pollInterval); } else { if (historyId.current) updateHistory(historyId.current, next, next.error?.message); setHistory(listHistory()); setMessage(next.status === "completed" ? "Generation completed." : next.error?.message || `Job ${next.status}.`, next.status === "completed" ? "success" : "error"); } } catch (e) { setMessage(e instanceof Error ? e.message : String(e), "error"); } };
    const generate = async () => { try { const request = buildRequestBodyForMode("image", form); const next = await submitImageJob(baseUrl.value, request); setJob(next); const saved = addHistory("image", form, request, next); historyId.current = saved.id; setHistory(listHistory()); void poll(next.id); } catch (e) { setMessage(e instanceof Error ? e.message : String(e), "error"); } };
    const cancel = async () => { if (!job?.id) return; const next = await cancelJob(baseUrl.value, job.id); setJob(next); setHistory(listHistory()); };

    return <div className="shell">
        <header className="page-header panel">
            <div className="page-header__top"><div className="page-header__copy"><div className="breadcrumb"><span className="breadcrumb__org">deep-diffusion</span><span className="breadcrumb__slash">/</span><span>{modelName}</span></div><h1 className="page-title">{modelName}</h1><p className="page-description">Local React + Vite interface for stable-diffusion.cpp.</p></div><div className="page-header__meta"><span className="chip chip--online">local service</span><span className="chip">{currentJob}</span></div></div>
            <div className="page-tabs"><div className="page-tabs__list"><button className={`page-tab ${tab === "image" ? "page-tab--active" : ""}`} onClick={() => setTab("image")}>Image Generation</button><button className={`page-tab ${tab === "settings" ? "page-tab--active" : ""}`} onClick={() => setTab("settings")}>Settings</button></div><div className="page-tabs__actions"><button className="btn-secondary" onClick={() => void refresh()}>Refresh Server Info</button></div></div>
            {tab === "settings" && <div className="settings"><div className="settings__grid"><div className="field"><HelpLabel text="Address of the local supervisor or server.">Base URL</HelpLabel><input value={baseUrl.value} onChange={(e) => { baseUrl.value = e.target.value; }} placeholder="Leave blank for same origin" /></div><div className="field field--full"><HelpLabel text="Choose a local model. Switching restarts the engine and reloads capabilities.">Model</HelpLabel><div className="inline-control"><select value={selectedModel} disabled={!models.length || switching} onChange={(e) => setSelectedModel(e.target.value)}>{!models.length && <option value="">Supervisor catalog unavailable</option>}{models.map((m) => <option key={m.path} value={m.path}>{m.name} · {formatBytes(m.size_bytes)}</option>)}</select><button className="btn-secondary" disabled={!selectedModel || switching || selectedModel === activeModel} onClick={() => void switchModel()}>{switching ? "Loading…" : "Use model"}</button></div></div><div className="field"><HelpLabel text="Polling interval for queued and generating jobs. Keep 100 ms for responsive status.">Poll interval</HelpLabel><input type="number" value={pollInterval} onChange={(e) => setPollInterval(Number(e.target.value))} /></div></div></div>}
        </header>
        {tab === "image" && <div className="layout"><section className="panel control-panel"><div className="panel-header"><h2 className="panel-title">Input</h2></div>
            <div className="prompt-card stack-top"><div className="panel-header"><h2 className="panel-title">Presets <HelpTip text="Save complete settings for repeatable generations." /></h2></div><div className="fields"><div className="field"><HelpLabel text="Loads a saved local configuration.">Load preset</HelpLabel><select value={selectedPreset} onChange={(e) => choosePreset(e.target.value)}><option value="">Choose a preset</option>{presets.map((p) => <option key={p.name}>{p.name}</option>)}</select></div><div className="field"><HelpLabel text="Name for the current configuration.">New preset name</HelpLabel><input value={presetName} onChange={(e) => setPresetName(e.target.value)} placeholder="Anime watercolor" /></div></div><div className="actions stack-top"><button className="btn-secondary" onClick={saveCurrent}>Save current</button><button className="btn-ghost" disabled={!selectedPreset} onClick={() => { removePreset(selectedPreset); setPresets(listPresets()); setSelectedPreset(""); }}>Delete selected</button><button className="btn-ghost" onClick={() => downloadJson("deep-diffusion-presets.json", exportPresets())}>Export JSON</button><button className="btn-ghost" onClick={() => fileRef.current?.click()}>Import JSON</button><input ref={fileRef} type="file" accept="application/json,.json" hidden onChange={importFile} /></div><div className="field field--full stack-top"><HelpLabel text="Loads a tested prompt and parameter combination as a starting point; it is not an image gallery.">Load example recipe</HelpLabel><select value={example} onChange={(e) => chooseExample(e.target.value)}><option value="">Choose an example</option>{EXAMPLE_PRESETS.map((p) => <option key={p.name}>{p.name}</option>)}</select></div></div>
            <div className="prompt-card"><div className="field field--full"><HelpLabel text="Describe subject, composition, lighting and style. Start concise.">Prompt</HelpLabel><textarea value={form.prompt} onChange={(e) => update("prompt", e.target.value)} /></div><div className="field field--full stack-top"><HelpLabel text="List unwanted qualities such as blur, bad anatomy, text or watermark.">Negative Prompt</HelpLabel><textarea value={form.negative_prompt} onChange={(e) => update("negative_prompt", e.target.value)} /></div></div>
            <div className="fields stack-top"><div className="field"><HelpLabel text="Recommended: 512 for Vega 7.">Width</HelpLabel><input type="number" value={form.width} onChange={(e) => update("width", Number(e.target.value))} /></div><div className="field"><HelpLabel text="Recommended: 512 for Vega 7.">Height</HelpLabel><input type="number" value={form.height} onChange={(e) => update("height", Number(e.target.value))} /></div><div className="field"><HelpLabel text="Number of images; keep 1 to limit memory.">Batch Count</HelpLabel><input type="number" value={form.batch_count} onChange={(e) => update("batch_count", Number(e.target.value))} /></div><div className="field"><HelpLabel text="Use 42 to reproduce a result or -1 for random.">Seed</HelpLabel><input type="number" value={form.seed} onChange={(e) => update("seed", Number(e.target.value))} /></div></div>
            <Section title="Sampling" help="Controls denoising. Recommended: 20 steps and Euler A."><div className="fields"><div className="field"><HelpLabel text="More steps can improve quality but increase time.">Steps</HelpLabel><input type="number" value={form.sample_params.sample_steps} onChange={(e) => updateSample("sample_steps", Number(e.target.value))} /></div><div className="field"><HelpLabel text="Sampling method. Euler A is a reliable SD 1.5 baseline.">Method</HelpLabel><select value={form.sample_params.sample_method} onChange={(e) => updateSample("sample_method", e.target.value)}><option value="default">default</option>{samplers.map((s) => <option key={s}>{s}</option>)}</select></div></div></Section>
            <Section title="Guidance" help="CFG controls prompt adherence. Start at 7."><div className="field"><HelpLabel text="Higher values follow the prompt more strongly but may create artifacts.">CFG Scale</HelpLabel><input type="number" step="0.1" value={form.sample_params.guidance.txt_cfg} onChange={(e) => updateGuidance("txt_cfg", Number(e.target.value))} /></div></Section>
            <Section title="LoRA" help="Use compatible adapters one at a time; start around weight 0.6.">{form.lora.map((item, index) => <div className="list-row" key={index}><select value={item.path} onChange={(e) => { const l = clone(form.lora); l[index].path = e.target.value; update("lora", l); }}>{availableLoras.map((l) => <option key={l.path} value={l.path}>{l.name}</option>)}</select><input type="number" step="0.1" value={item.multiplier} onChange={(e) => { const l = clone(form.lora); l[index].multiplier = Number(e.target.value); update("lora", l); }} /><button className="btn-ghost" onClick={() => update("lora", form.lora.filter((_, i) => i !== index))}>Remove</button></div>)}<button className="btn-ghost" disabled={!availableLoras.length} onClick={() => update("lora", [...form.lora, { path: availableLoras[0]?.path || "", multiplier: 0.6, is_high_noise: false }])}>Add LoRA</button></Section>
            <Section title="Advanced" help="VAE tiling reduces memory pressure; cache options should only change after benchmarks."><div className="field"><HelpLabel text="Use tiling for larger images or memory pressure.">VAE tiling</HelpLabel><input type="checkbox" checked={form.vae_tiling_params.enabled} onChange={(e) => update("vae_tiling_params", { ...form.vae_tiling_params, enabled: e.target.checked })} /></div><div className="field"><HelpLabel text="Leave disabled for the stable baseline.">Cache mode</HelpLabel><select value={form.cache.mode} onChange={(e) => update("cache", { ...form.cache, mode: e.target.value })}>{CACHE_MODES.map((m) => <option key={m}>{m}</option>)}</select></div></Section>
        </section><section className="panel output-panel"><div className="panel-header"><h2 className="panel-title">Output</h2></div><div className="hero-frame hero-frame--button">{imageSrc ? <img src={imageSrc} alt="Generated output" /> : <div className="hero-placeholder"><h2>Generate Image</h2><p>Your generated image will appear here.</p></div>}</div><div className="output-controls"><button className="btn output-controls__primary" disabled={running} onClick={() => void generate()}>Generate Image</button><div className="actions output-controls__secondary"><button className="btn-danger" disabled={!running} onClick={() => void cancel()}>Cancel</button></div></div>{message && <div className={`status-message status-message--${messageTone || "success"}`}>{message}</div>}<div className="prompt-card stack-top"><div className="panel-header"><h2 className="panel-title">Execution history</h2></div><select value={selectedHistory} onChange={(e) => setSelectedHistory(e.target.value)}><option value="">Choose an execution</option>{history.map((h) => <option key={h.id} value={h.id}>{new Date(h.created_at).toLocaleString()} · {h.status}</option>)}</select><div className="actions stack-top"><button className="btn-ghost" disabled={!selectedHistory} onClick={loadHistory}>Load</button><button className="btn-ghost" onClick={() => downloadJson("deep-diffusion-history.json", exportHistory())}>Export JSON</button><button className="btn-ghost" disabled={!history.length} onClick={() => { clearHistory(); setHistory([]); }}>Clear</button><button className="btn-ghost" disabled={!selectedHistory} onClick={() => { removeHistory(selectedHistory); setHistory(listHistory()); setSelectedHistory(""); }}>Delete</button></div></div></section></div>}
    </div>;
}

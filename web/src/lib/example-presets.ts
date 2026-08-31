import type { GenerationPreset } from "./presets";
import type { GenerationForm } from "./types";

// Curated starting points for the web UI. These are recipes, not generated
// images: selecting one fills the form so the user can adjust and generate.
export const EXAMPLE_PRESETS: GenerationPreset[] = [
  {
    name: "Anime watercolor",
    updated_at: "2026-08-07T00:00:00Z",
    form: {
      prompt: "original anime character, clearly adult woman, silver hair, vivid blue eyes, elegant fantasy dress, enchanted forest, soft sunlight, detailed face, anime illustration, watercolor accents",
      negative_prompt: "low quality, blurry, bad anatomy, malformed hands, extra fingers, duplicate, cropped, text, watermark, signature",
      width: 512,
      height: 512,
      batch_count: 1,
      seed: 42,
      output_format: "png",
      lora: [{ path: "fladdict-watercolor-sd-1-5.safetensors", multiplier: 0.6, is_high_noise: false }],
      sample_params: { sample_method: "euler_a", sample_steps: 20, guidance: { txt_cfg: 7 } } as GenerationForm["sample_params"],
    },
  },
  {
    name: "Anime portrait",
    updated_at: "2026-08-07T00:00:00Z",
    form: {
      prompt: "original anime character, clearly adult man, short dark hair, amber eyes, upper-body portrait, confident expression, cinematic rim light, clean anime linework, detailed illustration",
      negative_prompt: "low quality, blurry, bad anatomy, malformed hands, extra fingers, duplicate face, cropped, text, watermark",
      width: 512,
      height: 512,
      batch_count: 1,
      seed: 42,
      sample_params: { sample_method: "euler_a", sample_steps: 24, guidance: { txt_cfg: 7 } } as GenerationForm["sample_params"],
    },
  },
  {
    name: "Fantasy landscape",
    updated_at: "2026-08-07T00:00:00Z",
    form: {
      prompt: "fantasy castle above a misty valley, winding river, ancient mountains, dramatic clouds, warm sunrise, atmospheric depth, detailed digital painting",
      negative_prompt: "low quality, blurry, flat lighting, distorted architecture, duplicate objects, text, watermark, signature",
      width: 512,
      height: 512,
      batch_count: 1,
      seed: 42,
      sample_params: { sample_method: "euler_a", sample_steps: 24, guidance: { txt_cfg: 7 } } as GenerationForm["sample_params"],
    },
  },
  {
    name: "Logo mascot",
    updated_at: "2026-08-07T00:00:00Z",
    form: {
      prompt: "friendly original fox mascot, clean bold silhouette, simple geometric shapes, two-color palette, centered, isolated plain background, professional brand mark, vector-like icon, no lettering",
      negative_prompt: "photorealistic, complex background, clutter, gradients, illegible text, random letters, watermark, signature, low quality",
      width: 512,
      height: 512,
      batch_count: 1,
      seed: 42,
      sample_params: { sample_method: "euler_a", sample_steps: 20, guidance: { txt_cfg: 6.5 } } as GenerationForm["sample_params"],
    },
  },
  {
    name: "Product icon",
    updated_at: "2026-08-07T00:00:00Z",
    form: {
      prompt: "minimal app icon for a private local image generator, abstract spark and mountain motif, rounded square, flat colors, strong contrast, vector-like design, centered, no lettering",
      negative_prompt: "photorealistic, clutter, tiny details, illegible text, random letters, watermark, signature, low quality",
      width: 512,
      height: 512,
      batch_count: 1,
      seed: 42,
      sample_params: { sample_method: "euler_a", sample_steps: 20, guidance: { txt_cfg: 6.5 } } as GenerationForm["sample_params"],
    },
  },
];

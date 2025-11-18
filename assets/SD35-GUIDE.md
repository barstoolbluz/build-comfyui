# Stable Diffusion 3.5 Large Setup Guide

## ✅ Model Downloaded

Your SD 3.5 Large model (16GB + text encoders) has been successfully downloaded to:

```
~/comfyui-work/models/
├── checkpoints/
│   └── sd3.5_large.safetensors (16GB)
└── clip/
    └── text_encoders/
        ├── clip_l.safetensors (235MB)
        ├── clip_g.safetensors (1.3GB)
        └── t5xxl_fp16.safetensors (9.2GB)
```

Total download: ~27GB

## Using SD 3.5 in ComfyUI

### 1. Access ComfyUI

Open your browser to: **http://0.0.0.0:8188**

### 2. Load SD 3.5 Checkpoint

In ComfyUI:
1. Click on any "Load Checkpoint" node
2. Select `sd3.5_large.safetensors` from the dropdown
3. The model will load into VRAM

### 3. Text Encoders

SD 3.5 uses three text encoders (CLIP-L, CLIP-G, T5XXL) that were downloaded to the `clip/text_encoders/` directory. ComfyUI should automatically find and use them.

### 4. Correct Workflow Setup

**IMPORTANT:** SD 3.5 requires a special workflow because the text encoders are separate files.

**Required Nodes:**

1. **CheckpointLoaderSimple**
   - Select: `sd3.5_large.safetensors`
   - Provides: MODEL and VAE

2. **TripleCLIPLoader** (Add Node → loaders → TripleCLIPLoader)
   - clip_name1: `text_encoders/clip_l.safetensors`
   - clip_name2: `text_encoders/clip_g.safetensors`
   - clip_name3: `t5xxl_fp16.safetensors`
   - Provides: CLIP

3. **CLIPTextEncodeSD3** (NOT regular CLIPTextEncode!)
   - Use for positive prompt
   - Connect CLIP from TripleCLIPLoader (NOT from CheckpointLoaderSimple)

4. **CLIPTextEncodeSD3**
   - Use for negative prompt
   - Connect CLIP from TripleCLIPLoader

**Workflow Structure:**
```
[CheckpointLoaderSimple: sd3.5_large.safetensors]
    ├──MODEL──→ [KSampler]
    └──VAE────→ [VAEDecode]

[TripleCLIPLoader: clip_l, clip_g, t5xxl]
    └──CLIP──┬──→ [CLIPTextEncodeSD3] (positive) → [KSampler]
             └──→ [CLIPTextEncodeSD3] (negative) → [KSampler]

[KSampler] → [VAEDecode] → [SaveImage]
```

**Step-by-Step Setup:**

1. Add CheckpointLoaderSimple, select `sd3.5_large.safetensors`
2. Right-click canvas → Add Node → loaders → TripleCLIPLoader
3. In TripleCLIPLoader, select the three text encoder files
4. Add two CLIPTextEncodeSD3 nodes (search for "CLIPTextEncodeSD3")
5. Connect TripleCLIPLoader CLIP output to both CLIPTextEncodeSD3 nodes
6. Connect CheckpointLoaderSimple MODEL to KSampler
7. Connect CheckpointLoaderSimple VAE to VAEDecode
8. Wire up the rest normally (KSampler → VAEDecode → SaveImage)

### 5. Settings Recommendations

For SD 3.5 Large with your RTX 5090 (32GB VRAM):

- **Steps**: 28-50 (SD 3.5 works well with fewer steps)
- **CFG Scale**: 3.5-5.0 (lower than SD 1.5/XL)
- **Sampler**: DPM++ 2M or Euler
- **Scheduler**: Normal or SGM Uniform
- **Resolution**: Up to 1024x1024 native, higher with upscaling

### 6. VRAM Usage

Expected VRAM usage:
- Model loaded: ~16GB
- During generation (1024x1024): ~20-24GB
- Your RTX 5090 (32GB) has plenty of headroom

### 7. Re-downloading Models

If you need to re-download or download different variants:

```bash
cd /home/daedalus/dev/testes/comfyui
flox activate
python3 download-sd35.py
```

### 8. Model License

SD 3.5 is released under Stability AI's Community License. For commercial use beyond certain revenue thresholds, review the license at:
https://huggingface.co/stabilityai/stable-diffusion-3.5-large

## Troubleshooting

### Model not appearing in ComfyUI

Restart the service:
```bash
flox activate
flox services restart comfyui
```

### Out of VRAM

If you somehow run out of memory:
- Reduce batch size to 1
- Lower resolution (try 896x896 or 768x768)
- Use `--lowvram` flag (edit manifest service command)

### Check service status

```bash
flox activate
flox services status
flox services logs comfyui
```

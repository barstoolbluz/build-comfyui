# SD 3.5 Image-to-Image Guide

This guide explains how to use Stable Diffusion 3.5 for image-to-image generation in ComfyUI.

## What is Image-to-Image?

Image-to-image (img2img) takes an existing image and modifies it based on your prompt, preserving the overall structure while changing details, style, or quality.

**Use cases:**
- Enhance/upscale images
- Change art style (photo → painting, etc.)
- Add/modify details
- Fix imperfections
- Apply creative variations

## SD 3.5 Img2Img Workflow

### Required Nodes

1. **CheckpointLoaderSimple** → Load `sd3.5_large.safetensors`
2. **TripleCLIPLoader** → Load 3 text encoders (same as txt2img)
3. **CLIPTextEncodeSD3** (2x) → Positive and negative prompts
4. **LoadImage** → Load your input image
5. **VAEEncode** → Convert image to latent space
6. **KSampler** → Process with **denoise < 1.0**
7. **VAEDecode** → Convert back to image
8. **SaveImage** → Save result

### Workflow Structure

```
[CheckpointLoaderSimple: sd3.5_large.safetensors]
    ├──MODEL──→ [KSampler]
    └──VAE────┬→ [VAEEncode]
              └→ [VAEDecode]

[TripleCLIPLoader: clip_l, clip_g, t5xxl]
    └──CLIP──┬──→ [CLIPTextEncodeSD3] (positive) → [KSampler]
             └──→ [CLIPTextEncodeSD3] (negative) → [KSampler]

[LoadImage] → [VAEEncode] → [KSampler] → [VAEDecode] → [SaveImage]
```

## Key Setting: Denoise

**The denoise parameter controls how much the image changes:**

- **1.0** = Complete redraw (essentially txt2img)
- **0.8-0.9** = Major changes, loosely follows structure
- **0.6-0.7** = Balanced - good for enhancements (RECOMMENDED)
- **0.4-0.5** = Subtle changes, stays close to original
- **0.1-0.3** = Minimal changes, mostly detail refinement

**For SD 3.5 img2img, start with denoise = 0.7**

## Step-by-Step Setup

### 1. Load the Example Workflow

In your ComfyUI environment:
```bash
# Copy example workflow to input directory
cp ~/.flox/.../share/workflows/sd35-img2img.json ~/comfyui-work/input/
```

Then in ComfyUI:
- Menu → Load → Browse to `~/comfyui-work/input/sd35-img2img.json`

### 2. Upload Your Input Image

- Click on **LoadImage** node
- Click **Choose File** and select your image
- Or drag-drop image onto the node

### 3. Adjust Prompts

**Positive prompt (what you want):**
```
[describe desired changes], enhanced, detailed, high quality
```

Examples:
- "oil painting style, vibrant colors, artistic"
- "photorealistic, professional photography, 8k"
- "anime style, cel shaded, vibrant"

**Negative prompt (what to avoid):**
```
blurry, low quality, artifacts, distorted, deformed
```

### 4. Adjust Denoise

In **KSampler** node:
- **denoise: 0.7** (default - good starting point)
  - Too much change? Lower to 0.5-0.6
  - Not enough change? Raise to 0.8-0.9

### 5. Other Settings

**In KSampler:**
- **steps**: 28-40 (higher for more detail)
- **cfg**: 4.0-5.0 (SD 3.5 works well with lower CFG)
- **sampler_name**: dpmpp_2m or euler
- **scheduler**: sgm_uniform or normal

## Recommended Settings by Use Case

### Upscaling / Enhancement
```
denoise: 0.5-0.6
steps: 35
cfg: 4.5
prompt: "high resolution, sharp details, enhanced quality, masterpiece"
```

### Style Transfer
```
denoise: 0.7-0.8
steps: 28
cfg: 4.5
prompt: "[target style], artistic, detailed"
```

### Creative Variations
```
denoise: 0.8-0.9
steps: 28
cfg: 5.0
prompt: "[creative direction]"
```

### Subtle Fixes
```
denoise: 0.3-0.4
steps: 20
cfg: 4.0
prompt: "clean, corrected, refined"
```

## Advanced: Resolution Handling

SD 3.5 works best at 1024x1024, but img2img can handle various sizes:

**If your input image is not 1024x1024:**
- ComfyUI will work with the original size
- Larger images use more VRAM
- Very different aspect ratios may give unexpected results

**For best results:**
- Resize input to 1024x1024 or multiples (512, 768, 1536, 2048)
- Keep aspect ratio close to 1:1 or standard ratios (16:9, 4:3)

## Troubleshooting

### Image Changes Too Much
- **Lower denoise** to 0.5 or 0.4
- **Lower CFG** to 3.5-4.0
- Use more specific prompts

### Image Doesn't Change Enough
- **Raise denoise** to 0.8 or 0.9
- **Raise CFG** to 5.5-6.0
- **Increase steps** to 35-40
- Use stronger prompt words

### Output Quality Issues
- **Check input image quality** - garbage in, garbage out
- **Adjust negative prompt** to avoid artifacts
- **Try different samplers** (euler, dpmpp_2m, dpmpp_2m_sde)
- **Increase steps** to 35-40

### Out of VRAM
- **Reduce image resolution** before loading
- **Lower batch size** to 1
- Add `--lowvram` flag to ComfyUI service command

## Example Workflows

### Photo Enhancement
```
Input: Regular photo
Prompt: "professional photography, enhanced lighting, sharp details, 8k, high quality"
Negative: "blurry, low quality, noise, artifacts"
Denoise: 0.6
CFG: 4.5
Steps: 35
```

### Artistic Style Transfer
```
Input: Photo
Prompt: "oil painting, impressionist style, vibrant colors, artistic masterpiece"
Negative: "photorealistic, photograph, realistic"
Denoise: 0.75
CFG: 5.0
Steps: 28
```

### Detail Enhancement
```
Input: Sketch or low-detail image
Prompt: "highly detailed, intricate, refined, professional, masterpiece"
Negative: "simple, rough, sketch, unfinished"
Denoise: 0.7
CFG: 4.5
Steps: 30
```

## Comparison: Img2Img vs Txt2Img

| Feature | Txt2Img | Img2Img |
|---------|---------|---------|
| **Input** | Empty latent | Loaded image |
| **Denoise** | Always 1.0 | 0.3-0.9 |
| **Control** | Full randomness | Guided by input |
| **Use case** | Create from scratch | Modify existing |
| **VRAM** | Lower | Slightly higher |

## Tips & Tricks

1. **Experiment with denoise** - This is the most important parameter for img2img
2. **Match your prompt to the input** - Describe what you want to change, not what's already there
3. **Use negative prompts** - List unwanted artifacts specific to img2img (blur, distortion)
4. **Try multiple seeds** - Same input + different seeds = variety of variations
5. **Chain processing** - Output of one img2img can be input to another for iterative refinement

## Batch Processing

To process multiple images:

1. Add **Load Image (Batch)** node instead of LoadImage
2. Place multiple images in `~/comfyui-work/input/`
3. Adjust batch size in workflow
4. All images will use the same prompt/settings

## Next Steps

- Try the example workflow: `workflow-sd35-img2img.json`
- Experiment with different denoise values
- Explore different samplers and schedulers
- Combine with other ComfyUI nodes (upscaling, masks, etc.)

## Related Documentation

- **SD35-GUIDE.md** - Basic SD 3.5 setup and txt2img
- **README.md** - ComfyUI environment documentation

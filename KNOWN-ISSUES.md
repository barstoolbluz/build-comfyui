# Known Issues - ComfyUI Flox Package

## macOS: Duplicate FFmpeg Class Warning

### Symptom

When running ComfyUI on macOS (especially ARM64/Apple Silicon), you may see warnings like:

```
objc[81422]: Class AVFFrameReceiver is implemented in both
  /nix/store/.../ffmpeg-headless-7.1.1-lib/lib/libavdevice.61.3.100.dylib
  and
  /nix/store/.../ffmpeg-full-6.1.2-lib/lib/libavdevice.60.3.100.dylib.
This may cause spurious casting failures and mysterious crashes.
One of the duplicates must be removed or renamed.

objc[81422]: Class AVFAudioReceiver is implemented in both ...
```

### Cause

Two different Python dependencies require different FFmpeg versions:
- **torchaudio 2.8.0** → depends on `ffmpeg-full-6.1.2`
- **av 15.1.0** → depends on `ffmpeg-headless-7.1.1`

Both libraries get loaded into the same process, causing Objective-C runtime to detect duplicate class definitions.

### Impact

**Status: Appears harmless in practice**

- ComfyUI runs normally despite the warnings
- No actual crashes or functionality issues observed
- Warning is cosmetic on macOS (Objective-C runtime complaining about duplicates)
- Both FFmpeg versions coexist without interfering with each other

### Root Cause

This is an **upstream nixpkgs issue** where different packages in the Python ecosystem depend on different FFmpeg versions. The Python packages themselves don't specify FFmpeg version constraints, so nixpkgs picks defaults that happen to differ.

### Potential Solutions (⚠️ Change at Your Own Risk)

The following solutions *might* silence the warning, but could introduce other issues:

#### Option 1: Override torchaudio to use ffmpeg-headless (unifies on newer FFmpeg)

In `.flox/pkgs/comfyui.nix`, add before the main package definition:

```nix
let
  # Force torchaudio to use the same FFmpeg as av
  torchaudio-unified = python3.pkgs.torchaudio.override {
    ffmpeg = python3.pkgs.ffmpeg-headless;
  };
in
```

Then in `propagatedBuildInputs`, replace:
```nix
torchaudio
```

With:
```nix
torchaudio-unified
```

**Risks:**
- May break if torchaudio requires ffmpeg-full features
- Override might fail on nixpkgs updates
- Untested with ComfyUI's audio features

#### Option 2: Override av to use ffmpeg-full (unifies on older FFmpeg)

```nix
let
  # Force av to use the same FFmpeg as torchaudio
  av-unified = python3.pkgs.av.override {
    ffmpeg = python3.pkgs.ffmpeg-full;
  };
in
```

Then replace `av` with `av-unified` in dependencies.

**Risks:**
- Pulls in larger ffmpeg-full dependency
- May have feature differences from ffmpeg-headless
- Override might fail on nixpkgs updates

#### Option 3: Pin both to specific FFmpeg version

Explicitly override both packages to use the same FFmpeg version:

```nix
let
  unifiedFFmpeg = python3.pkgs.ffmpeg-headless; # or ffmpeg-full

  torchaudio-unified = python3.pkgs.torchaudio.override {
    ffmpeg = unifiedFFmpeg;
  };

  av-unified = python3.pkgs.av.override {
    ffmpeg = unifiedFFmpeg;
  };
in
```

**Risks:**
- Most complex approach
- Hardest to maintain across nixpkgs updates
- May require rebuilding large portions of the dependency tree

### Recommendation

**⚠️ Do not attempt to "fix" this unless:**
1. You're experiencing actual crashes or functionality issues
2. You're comfortable debugging Nix package overrides
3. You're prepared to rebuild and retest after nixpkgs updates

**Current stance:** This is a cosmetic warning. ComfyUI works correctly despite it. The warning can be safely ignored.

### Future Resolution

This issue should be resolved upstream in nixpkgs when:
- Python packages standardize on a single FFmpeg version, or
- nixpkgs maintainers coordinate FFmpeg versions across PyTorch ecosystem packages

Track progress: Check nixpkgs issues for "ffmpeg" + "pytorch" or "torchaudio"

---

**Last Updated:** 2025-11-27
**Affects:** macOS ARM64 (aarch64-darwin), possibly macOS x86_64
**Status:** Known, harmless, no action required

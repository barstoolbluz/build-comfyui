# Branching Strategy

## Branch Structure

```
nightly-testing → nightly-staging → nightly     # Latest/experimental versions
main-testing → main-staging → main              # Stable/current versions
v0.9.1, v0.9.0, v0.6.0                         # Archived version branches
```

## Workflow

### Development Flow
1. **Testing branches** (`*-testing`): Active development and fixes
2. **Staging branches** (`*-staging`): Pre-release validation
3. **Release branches** (`main`, `nightly`): Production-ready code

### Version Promotion
When promoting a new version from nightly to main:
1. Current `main` → Archive as `v{version}` (e.g., `v0.9.1`)
2. Current `nightly` → New `main`
3. Next version → New `nightly`

### Example Promotion
```bash
# Archive current main
git checkout main
git checkout -b v0.9.1
git push -u origin v0.9.1

# Promote nightly to main
git checkout main
git merge nightly
git push

# Update nightly with next version
git checkout nightly
git merge nightly-staging
git push
```

## Current Package Versions
- **main**: ComfyUI v0.6.0 (stable)
- **nightly**: ComfyUI v0.9.1 (latest)
- **v0.6.0**: Historical v0.6.0 archive

## Branch Purposes

### Testing Branches
- `main-testing`: Develop fixes for stable version
- `nightly-testing`: Develop features for latest version
- Frequent commits, may be unstable

### Staging Branches
- `main-staging`: Validate stable fixes before release
- `nightly-staging`: Validate new features before release
- Should pass all tests before promotion

### Release Branches
- `main`: Current stable release for production use
- `nightly`: Latest features for early adopters
- Must be fully functional and tested

### Version Archives
- `v{version}`: Preserved historical releases
- Read-only after creation
- Available for rollback if needed
#!/usr/bin/env bash
set -euo pipefail

# Check for ComfyUI updates
# This script checks GitHub and PyPI for newer versions

echo "🔍 Checking for ComfyUI updates..."
echo ""

# Get current version from comfyui-base.nix
CURRENT_VERSION=$(grep 'version = ' .flox/pkgs/comfyui-base.nix | head -1 | sed 's/.*"\(.*\)".*/\1/')
echo "Current ComfyUI version: $CURRENT_VERSION"

# Check GitHub for latest release
LATEST_VERSION=$(curl -s https://api.github.com/repos/comfyanonymous/ComfyUI/releases/latest | jq -r '.tag_name' | sed 's/^v//')
echo "Latest ComfyUI version:  $LATEST_VERSION"

if [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
    echo ""
    echo "🆕 New version available!"
    echo "Release notes: https://github.com/comfyanonymous/ComfyUI/releases/tag/v$LATEST_VERSION"
    echo ""
    echo "To update:"
    echo "  1. Edit .flox/pkgs/comfyui-base.nix - change version to \"$LATEST_VERSION\""
    echo "  2. Run: flox build comfyui-base (will show correct hash)"
    echo "  3. Update hash in comfyui-base.nix"
    echo "  4. Check requirements.txt for dependency updates"
else
    echo ""
    echo "✅ Already on latest version"
fi

echo ""
echo "📦 Checking dependency packages..."

# Check frontend package
CURRENT_FRONTEND=$(grep 'version = ' .flox/pkgs/comfyui-frontend-package.nix | head -1 | sed 's/.*"\(.*\)".*/\1/')
LATEST_FRONTEND=$(curl -s https://pypi.org/pypi/comfyui-frontend-package/json | jq -r '.info.version')
echo "  Frontend:  $CURRENT_FRONTEND → $LATEST_FRONTEND $([ "$CURRENT_FRONTEND" != "$LATEST_FRONTEND" ] && echo '(UPDATE)' || echo '(OK)')"

# Check workflow templates
CURRENT_WORKFLOW=$(grep 'version = ' .flox/pkgs/comfyui-workflow-templates.nix | head -1 | sed 's/.*"\(.*\)".*/\1/')
LATEST_WORKFLOW=$(curl -s https://pypi.org/pypi/comfyui-workflow-templates/json | jq -r '.info.version')
echo "  Workflows: $CURRENT_WORKFLOW → $LATEST_WORKFLOW $([ "$CURRENT_WORKFLOW" != "$LATEST_WORKFLOW" ] && echo '(UPDATE)' || echo '(OK)')"

# Check embedded docs
CURRENT_DOCS=$(grep 'version = ' .flox/pkgs/comfyui-embedded-docs.nix | head -1 | sed 's/.*"\(.*\)".*/\1/')
LATEST_DOCS=$(curl -s https://pypi.org/pypi/comfyui-embedded-docs/json | jq -r '.info.version')
echo "  Docs:      $CURRENT_DOCS → $LATEST_DOCS $([ "$CURRENT_DOCS" != "$LATEST_DOCS" ] && echo '(UPDATE)' || echo '(OK)')"

# Check spandrel
CURRENT_SPANDREL=$(grep 'version = ' .flox/pkgs/spandrel.nix | head -1 | sed 's/.*"\(.*\)".*/\1/')
LATEST_SPANDREL=$(curl -s https://pypi.org/pypi/spandrel/json | jq -r '.info.version')
echo "  Spandrel:  $CURRENT_SPANDREL → $LATEST_SPANDREL $([ "$CURRENT_SPANDREL" != "$LATEST_SPANDREL" ] && echo '(UPDATE)' || echo '(OK)')"

echo ""
echo "See README.md for update instructions"

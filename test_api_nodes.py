#!/usr/bin/env python3
import sys
import os

# Add ComfyUI to path
comfyui_path = os.path.join(os.path.dirname(__file__), 'result-comfyui/share/comfyui')
sys.path.insert(0, comfyui_path)

print("Testing ComfyUI API nodes imports...")

# Test individual problematic nodes
nodes_to_test = ['nodes_gemini', 'nodes_moonvalley', 'nodes_rodin', 'nodes_vidu', 'nodes_wan']

for node in nodes_to_test:
    try:
        module = __import__(f'comfy_api_nodes.{node}', fromlist=[''])
        print(f"✅ {node}: Import successful")
    except ImportError as e:
        print(f"❌ {node}: {e}")
    except Exception as e:
        print(f"⚠️  {node}: {type(e).__name__}: {e}")

print("\nTest complete!")

#!/usr/bin/env python3
"""
Generate PNG from Mermaid diagram using Mermaid.ink API
"""
import base64
import json
import sys
from pathlib import Path

try:
    import requests
except ImportError:
    print("Error: requests library not found. Install it with: pip install requests")
    sys.exit(1)

def mermaid_to_png(mermaid_content: str, output_path: str):
    """Convert Mermaid diagram to PNG using Mermaid.ink API"""
    # Encode mermaid content to base64
    mermaid_b64 = base64.urlsafe_b64encode(mermaid_content.encode('utf-8')).decode('utf-8')
    
    # Mermaid.ink API endpoint
    api_url = f"https://mermaid.ink/img/{mermaid_b64}"
    
    print(f"Generating PNG from Mermaid diagram...")
    print(f"API URL: {api_url[:80]}...")
    
    try:
        response = requests.get(api_url, timeout=30)
        response.raise_for_status()
        
        # Save PNG file
        with open(output_path, 'wb') as f:
            f.write(response.content)
        
        print(f"✅ Successfully generated: {output_path}")
        print(f"   File size: {len(response.content) / 1024:.1f} KB")
        return True
        
    except requests.exceptions.RequestException as e:
        print(f"❌ Error generating PNG: {e}")
        return False

def main():
    script_dir = Path(__file__).parent
    mermaid_file = script_dir / "RELATIONSHIPS.mmd"
    output_file = script_dir / "RELATIONSHIPS.png"
    
    if not mermaid_file.exists():
        print(f"❌ Error: {mermaid_file} not found")
        sys.exit(1)
    
    # Read Mermaid content
    with open(mermaid_file, 'r', encoding='utf-8') as f:
        mermaid_content = f.read()
    
    print(f"Reading Mermaid file: {mermaid_file}")
    print(f"Output PNG file: {output_file}")
    print()
    
    # Generate PNG
    if mermaid_to_png(mermaid_content, str(output_file)):
        sys.exit(0)
    else:
        sys.exit(1)

if __name__ == "__main__":
    main()


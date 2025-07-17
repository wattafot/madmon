#!/bin/bash
echo "Exporting to web..."
godot --headless --export-release "Web" export/web/index.html
echo "Export complete! Game available at http://localhost:8000"
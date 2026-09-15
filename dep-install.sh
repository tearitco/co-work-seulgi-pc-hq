#!/bin/bash
# dep-install.sh - install build + runtime dependencies for piececraft-hq
# on Debian/Ubuntu. Run once before first build.
#
# Usage: sudo ./dep-install.sh
set -eu
echo "Installing build deps (gcc, pkg-config, X11/Xft/GLUT/GL dev, freetype)..."
apt-get update -qq
apt-get install -y --no-install-recommends \
  gcc pkg-config \
  libx11-dev libxext-dev libxft-dev \
  freeglut3-dev libgl-dev libglu1-mesa-dev \
  libfreetype-dev \
  libx11-6 libxext6 libxft2 libfontconfig1 libfreetype6 libxrender1 \
  libpng16-16 libexpat1 fonts-dejavu-core \
  libglut3.12 libgl1 libglu1-mesa
echo "Done. Rebuild the renderer/board window: ./launch.sh (does everything on demand)."
echo "Or manually: 44.xyz.01.00/*.monads/*.livedesk-taskbar/ops/build_core_render.sh"
echo "         and 44.xyz.01.00/@.apps/piececraft-hq/scripts/build.sh"
echo "         and 44.xyz.01.00/&.widgits/board-viewer/scripts/build.sh"

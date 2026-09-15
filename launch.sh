#!/bin/bash
# launch.sh - launch piececraft-hq's board window from this standalone
# tree (house-root + engine + renderer + shared-lib all live here;
# nothing outside this package is touched at runtime, except the
# mineclonia texture pack - see README.md #3 for that one real gap).
#
# This just pre-builds the two widgets open_pchq_board.sh itself does
# NOT build on demand (events-hq, file-explorer), then delegates to
# piececraft-hq's own real launcher, which already knows how to build
# everything else on demand and start the board-viewer engine session.
#
# Usage: ./launch.sh
#   Stop: kill by PID - see README.md #4.
set -eu
DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$DIR/44.xyz.01.00"

mkdir -p "$ROOT/#.desktop"

echo "-- building events-hq (Common Event manager + command ops, needed by the Menu action and common_events/) --"
( cd "$ROOT/&.widgits/events-hq/ops" && bash build_events_hq_manager.sh >/dev/null 2>&1 ) || \
    echo "WARN: events-hq manager build failed - Common Events won't play; see $ROOT/&.widgits/events-hq/ops for manual build"
( cd "$ROOT/&.widgits/events-hq/ops" && bash build_mr_event_ops.sh >/dev/null 2>&1 ) || \
    echo "WARN: events-hq command ops build failed - mr_show_text/mr_scrolling_text etc. won't run"

echo "-- building file-explorer manager (needed by the File action) --"
( cd "$ROOT/&.widgits/file-explorer/ops" && bash build_file_explorer_manager.sh >/dev/null 2>&1 ) || \
    echo "WARN: file-explorer build failed - the File toolbar button won't work"

echo "-- launching piececraft-hq (builds the renderer + board engine on demand) --"
sh "$ROOT/@.apps/piececraft-hq/open_pchq_board.sh" "$ROOT"

echo "launched; board log = /tmp/pchq-board.log"

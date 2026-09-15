# seulgi-palcraft-15 — standalone piececraft-hq (PALCRAFT starting point)

A self-contained copy of piececraft-hq: the real-time voxel board game
app this house's PALCRAFT desk is being built on top of. Houses its
own house-root, both real engines it depends on (its own local
prisc+x/orchestrator stack, and a separate board-viewer engine session
for the 3D camera view), the shared X11 renderer, and the Common Event
compiler/player. See `docs/` for the full PALCRAFT design spec and the
Grok handoff note this package supports.

## Verified (2026-09-15)

Built from source inside this standalone tree (not copied pre-built
binaries — `find */+x/* -delete` before the first launch, then
`launch.sh` rebuilt everything on demand) and launched successfully:
both `khtpm_core_render` (the board window) and `pchq_board_projector`
stayed alive and stable for 5+ seconds with no crash, and the
published UI state confirmed REAL data flowing through the whole
pipeline.

**Correction, same day**: the "Player" tab was originally wired as a
position readback (`Player: hero_01 (x,y,z)`) — that was a wrong read
of the original stub note, caught and fixed later the same session
(see `docs/PALCRAFT-DESIGN.md` §1). It's now a real, clickable Play
Mode start/stop toggle — the same house-wide `#.desktop/khtpm_play_
mode.state.txt` flag the main house's own desktop taskbar already
uses, NOT the clock/tick daemon. This package has been re-synced with
that fix and rebuilt; `player_label` now publishes `Player: ON` or
`Player: OFF`.

**Honest limitation on this verification**: this environment's X11
window enumeration (`xdotool search`) has proven unreliable for
screenshot-based verification in this sandbox throughout this session
(documented earlier the same day) — process liveness + real published
state were checked instead of a screenshot. If you can get a
screenshot on your own machine, that's a stronger check than what's
been done here; this package has not been visually confirmed on
screen, only confirmed alive and producing correct data.

## 1. Tree layout

```
seulgi-palcraft-15/
  launch.sh                       # one-command start (see §4)
  dep-install.sh                  # apt deps (see §3)
  docs/
    PALCRAFT-DESIGN.md             # the full design spec
    GROK-HANDOFF.md                 # the original agent handoff note (co-lab-hai specifics don't apply to a human collaborator - read for the real technical content, skip the "join the co-lab room" section)
  44.xyz.01.00/                    # "house root" (everything resolves here)
    #.desktop/                     # runtime state (created on first run)
    @.apps/piececraft-hq/          # the app itself: world gen, menu input,
                                    # frame compose, clock daemon, its own
                                    # local prisc+x/orchestrator/renderer
                                    # engine stack (system/), maps/, and the
                                    # new common_events/palcraft_sign_onclick
                                    # template (see docs/PALCRAFT-DESIGN.md §2)
    &.widgits/board-viewer/        # SEPARATE engine session for the 3D
                                    # camera <canvas> - its own prisc+x VM,
                                    # copy-based session isolation at
                                    # runtime (pieces/sessions/<id>/)
    &.widgits/_shared-lib/         # shared renderer sources + prisc+x.c /
                                    # chtpm_parser_pal.c (piececraft-hq's
                                    # own system/ builds from these)
    &.widgits/events-hq/           # Common Event compiler/player -
                                    # needed for common_events/ to run
    &.widgits/file-explorer/       # needed by the toolbar's File action
    *.monads/*.livedesk-taskbar/    # (literal '*' in dir name - see §5)
                                    # the shared X11 renderer
    common_events/
      palcraft_sign_onclick/       # the real, working v1 template - copy
                                    # this shape for every other block
      cdda_beartrap_touch/         # the original reference example both
                                    # docs cite
    #.ref/menu/event-guides/       # the mineclonia tile catalog (metadata
                                    # only - see §6 for the texture gap)
    shared/
      MINECLONIA-ASSET-SOURCE-LOCATION.pdl  # where the real textures live
                                              # (NOT included - see §6)
```

## 2. What's a known stub or gap (confirmed this session, not guessed)

- **Player tab is a real, house-wide Play Mode start/stop toggle now**
  (`#.desktop/khtpm_play_mode.state.txt`, `mode=on|off` — same flag the
  main house's desktop taskbar already uses). What's still NOT built:
  pc-hq's own entities don't yet check this flag before acting, and
  there's no Play-Mode-specific context menu (edit-mode commands vs.
  game commands) — see `docs/PALCRAFT-DESIGN.md` §1 for the real, scoped
  next step and its own pointer to `PLAY-MODE-ENTITY-HARNESS-DESIGN.md`.
- **No live in-place map swap.** The toolbar's File/Desk buttons start
  a genuinely NEW world from the picked map (same as New Game) via
  `pieces/system/widget_cmds/inbox.txt` + `CONFIRM_START_MAP:<id>` -
  fixed this session (it used to write to two files the engine never
  read at all). There's still no way to hot-swap a *running* session's
  map without restarting the world.
- **Voxel removal exists; voxel placement does not yet** (see
  `docs/PALCRAFT-DESIGN.md` §3) — the real, symmetric gap for whoever
  picks this up next.

## 3. System dependencies

```bash
sudo ./dep-install.sh
```

Installs: gcc, pkg-config, X11/Xft dev headers, freeglut/GL/GLU dev
headers (board-viewer's optional `gl_mirror` — the build skips it
gracefully if these are missing, matching the main house's own
behavior), freetype dev (board-viewer's 2D tile renderer).

## 4. Running

```bash
cd seulgi-palcraft-15
./launch.sh
```

This builds events-hq + file-explorer (not built on demand by the
launcher itself), then delegates to piececraft-hq's own real launcher
(`open_pchq_board.sh`), which builds the renderer + board engine on
demand and starts everything else automatically — same single-instance
guard and orphan-session reaping the main house uses.

Stop by exact PID:
```bash
ps -eo pid,args | grep seulgi-palcraft-15 | grep -v grep
kill <pid> <pid> ...
```

Board window log: `/tmp/pchq-board.log`. Engine/world state lives
under `44.xyz.01.00/@.apps/piececraft-hq/pieces/` and
`44.xyz.01.00/@.apps/piececraft-hq/state/ui.txt` (the projector's own
published UI state - useful for confirming the app is alive without a
screenshot, same way this package's own build was verified).

## 5. Gotcha: literal `*` in directory names

Same as every other khtpm-family package - the monads directory is
literally named `*.monads`. Quote it when `cd`-ing manually:
```bash
cd "44.xyz.01.00/"'*.monads'/'*.livedesk-taskbar'/ops
```

## 6. Real gap: mineclonia textures are NOT included

`shared/MINECLONIA-ASSET-SOURCE-LOCATION.pdl` points at
`/home/no/Desktop/github/work/NNEST-12.00/#.NNEST_ASSETS/mineclonia/mods`
on the original machine — a **113MB** clone of the Mineclonia texture
pack, living outside the house zip entirely (same convention as RMMV's
own `img_root`). Too large to bundle into a lightweight handoff
package, so it's not here. The tile *catalog* (`#.ref/menu/event-guides/`
- which block IDs exist, their trigger types, command lists) is fully
included; only the actual PNG textures are missing. If you need real
rendered textures, either point your own `MINECLONIA-ASSET-SOURCE-
LOCATION.pdl` at a local clone of
https://codeberg.org/mineclonia/mineclonia, or work with the block
catalog/Common Event logic only (which is where the real PALCRAFT work
— see `docs/PALCRAFT-DESIGN.md` — actually lives) until textures matter.

## 7. What to do next

Read `docs/PALCRAFT-DESIGN.md` in full — it's the real spec, written
against this exact codebase, with a landed v1 example
(`common_events/palcraft_sign_onclick/`) to copy from. The three real,
concrete next pieces of work:
1. Design and build the edit/play-mode toggle (§1 - genuinely doesn't
   exist yet).
2. Port more mineclonia blocks into `common_events/palcraft_*`
   following the landed `sign` example's shape (§2).
3. Wire real voxel placement, symmetric to the existing removal
   handler (§3).

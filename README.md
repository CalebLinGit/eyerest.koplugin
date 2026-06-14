# Eye Rest — a KOReader break reminder

A [KOReader](https://github.com/koreader/koreader) plugin that reminds you to rest your eyes,
timed by **how long you actually read** — time in the file browser, in menus, or while the device
is asleep does not count.

It is a clean rewrite / enhanced alternative to KOReader's built-in **Read timer**.

## Features

- **One clear switch.** A single *Enable breaks* toggle — no overlapping alarm / interval / stop modes.
- **Mini & deep-rest breaks.** A short *mini break* every N minutes of reading; every few mini breaks
  becomes a longer *deep rest*.
- **A break screen you can't dismiss by accident.** When a break is due, a modal countdown appears —
  a stray tap won't close it. In *non-strict* mode you can **Skip** or **Read a bit more**; in
  *strict* mode you wait the countdown out.
- **E-ink friendly.** The countdown uses a 5-segment progress bar that only refreshes when a segment
  completes — about 5 screen refreshes per break instead of one per second.
- **Manual pause.** Pause breaks for 30 min / 1 h / 2 h / until tomorrow morning / indefinitely.

## Screenshots

<!-- Drop images into assets/ and reference them here, e.g.:
![Break screen](assets/break-screen.png)
![Menu](assets/menu.png)
-->

_Screenshots go in [`assets/`](assets/)._

## Install

The plugin is a single `eyerest.koplugin` folder that lives in KOReader's `plugins/` directory.

**Option A — clone directly into the plugins directory:**

```sh
git clone https://github.com/CalebLinGit/eyerest.koplugin.git \
  /path/to/koreader/plugins/eyerest.koplugin
```

**Option B — download and copy** the folder into `…/koreader/plugins/` so the path is
`…/koreader/plugins/eyerest.koplugin/`.

**On a Kindle / remote device over SSH** (KOReader's SSH server: *Tools → SSH server*):

```sh
scp -P <port> -i <your_key> -r eyerest.koplugin \
  root@<device-ip>:/mnt/us/koreader/plugins/
```

### Then: disable the built-in "Read timer"

Eye Rest replaces KOReader's built-in **Read timer** and occupies the same menu slot, so run them
one at a time:

1. **Tools → Plugin management** → untick **Read timer**.
2. Restart KOReader.

Eye Rest then appears under **Tools → Eye Rest** (where *Read timer* used to be). Nothing in
KOReader's own files needs editing — disabling is just an in-app toggle.

## Settings

Under **Tools → Eye Rest → Settings**:

| Setting | What it does |
|---------|--------------|
| Mini break interval | Minutes of reading between mini breaks |
| Mini break duration | Length of a mini break |
| Long break: every N mini breaks | How many mini breaks before a deep rest (0 = off) |
| Long break duration | Length of a deep rest |
| Strict mode | Hide Skip / Read-more on the break screen — wait the countdown out |
| Postpone | How long *Read a bit more* defers the break |
| Show countdown in header / footer | Show time-to-next-break in the status bars |

## Development

Pure break-cycle / timing logic lives in `breaklogic.lua` (no KOReader dependencies) and is
unit-tested. Run the tests with the luajit bundled inside KOReader:

```sh
/path/to/koreader/luajit tests/breaklogic_test.lua
```

| File | Responsibility |
|------|----------------|
| `breaklogic.lua` | Pure logic: break-cycle, stage math, pause timing (unit-tested) |
| `breakview.lua` | The modal staged-countdown break screen |
| `main.lua` | Wiring: settings, menu, status bars, lifecycle, scheduling |
| `_meta.lua` | KOReader plugin metadata |

## License

Add a license of your choice (KOReader itself is AGPL-3.0).

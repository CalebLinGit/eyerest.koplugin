# Eye Rest — a KOReader break reminder

A [KOReader](https://github.com/koreader/koreader) plugin that reminds you to rest your eyes,
timed by **how long you actually read** (time in the file browser, in menus, or while the device
is asleep does not count).

## Features

- **One clear switch.** A single *Enable breaks* toggle — no overlapping alarm / interval / stop modes.
- **Mini & deep-rest breaks.** Take a short *mini break* every N minutes; every few mini breaks
  becomes a longer *deep rest*.
- **A break screen you can't dismiss by accident.** When a break is due, a modal countdown screen
  appears. A stray tap won't close it. In *non-strict* mode you can **Skip** or **Read a bit more**;
  in *strict* mode you wait the countdown out.
- **E-ink friendly.** The break countdown uses a 5-segment progress bar that only refreshes when a
  segment completes — about 5 screen refreshes per break instead of one per second.
- **Manual pause.** Pause breaks for 30 min / 1 h / 2 h / until tomorrow morning / indefinitely.

## Install

Copy this folder into your KOReader plugins directory as `eyerest.koplugin`:

```sh
git clone https://github.com/CalebLinGit/eyerest.koplugin.git \
  /path/to/koreader/plugins/eyerest.koplugin
```

Then restart KOReader. The plugin appears under **Tools → Eye Rest**.

## Settings

Found under **Tools → Eye Rest → Settings**:

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

Pure break-cycle/timing logic lives in `breaklogic.lua` (no KOReader dependencies) and is unit-tested:

```sh
# uses the luajit bundled with KOReader
/path/to/koreader/luajit tests/breaklogic_test.lua
```

## License

Add a license of your choice (KOReader itself is AGPL-3.0).

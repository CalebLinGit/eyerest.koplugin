# Eye Rest

A [Stretchly](https://hovancik.net/stretchly/)-style break reminder for
[KOReader](https://github.com/koreader/koreader). It reminds you to rest your eyes with short *mini
breaks* and periodic *deep rests*, timed by how long you actually read. An enhanced alternative to
KOReader's built-in *Read timer*.

## Demo

<!-- Add a screen recording / screenshots here. Files live in assets/. -->

_Coming soon — see [`assets/`](assets/)._

## The difference

Compared with the built-in *Read timer*:

| | Read timer | Eye Rest |
|---|---|---|
| Setup | Alarm and/or interval, plus auto-start / stop | One *Enable breaks* switch |
| Timing | Wall-clock, including idle time | Only active reading time (pauses in menus, file browser, and sleep) |
| Break UI | A dismissable message popup | A full-screen countdown that ignores stray taps |
| Controls | — | Skip, postpone, or enforce with Strict mode |
| Break tiers | Basic | Mini breaks + periodic deep rests |
| Pause | — | 30 min … until morning … indefinitely |
| E-ink refreshes per break | One per second | ~5 (segmented countdown) |

## Install

Eye Rest is a single `eyerest.koplugin` folder placed in KOReader's `plugins/` directory.

**Clone into the plugins directory:**

```sh
git clone https://github.com/CalebLinGit/eyerest.koplugin.git \
  /path/to/koreader/plugins/eyerest.koplugin
```

Or copy the folder manually so the path is `…/koreader/plugins/eyerest.koplugin/`.

**On a Kindle / remote device** (enable KOReader's *Tools → SSH server* first):

```sh
scp -P <port> -i <your_key> -r eyerest.koplugin \
  root@<device-ip>:/mnt/us/koreader/plugins/
```

**Then disable the built-in Read timer** — the two share a menu slot, so run one at a time:

1. **Tools → Plugin management** → untick **Read timer**.
2. Restart KOReader.

Eye Rest appears under **Tools → Eye Rest**. No KOReader files need editing.

## Usage

Under **Tools → Eye Rest**:

- **Enable breaks** — the main switch.
- **Skip to next** — go to a mini break or deep rest now.
- **Pause breaks** — for a set time, or indefinitely.
- **Reset breaks** — restart the cycle.
- **Settings:**

| Setting | Description |
|---------|-------------|
| Mini break interval | Reading time between mini breaks |
| Mini break duration | Length of a mini break |
| Long break: every N mini breaks | Mini breaks before a deep rest (0 = off) |
| Long break duration | Length of a deep rest |
| Strict mode | Hide Skip / Read-more; the break must run out |
| Postpone | How long *Read a bit more* defers a break |
| Show countdown in header / footer | Show time-to-next-break in the status bar |

## License

Inspired by [Stretchly](https://hovancik.net/stretchly/); built on
[KOReader](https://github.com/koreader/koreader). Licensed under the GNU Affero General Public
License v3.0 — see [LICENSE](LICENSE). Copyright © 2026 Caleb Lin.

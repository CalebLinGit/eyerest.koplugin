# Eye Rest — eye-strain break reminder for KOReader

Eye Rest reminds you to look up and rest your eyes while reading on
[KOReader](https://github.com/koreader/koreader), so long sessions on a Kindle, Kobo, or other e-ink
reader don't leave your eyes aching. It's a [Stretchly](https://hovancik.net/stretchly/)-style break
reminder built around the **20-20-20 rule**: short *mini breaks* and periodic *long breaks*, paced by
how long you actually read. It also adds a one-shot **sleep timer** for bedtime reading. A
pomodoro-style, enhanced alternative to KOReader's built-in *Read timer*.

## Demo

<!-- Add a screen recording / screenshots here. Files live in assets/. -->

_Coming soon — see [`assets/`](assets/)._

## The difference

Compared with the built-in *Read timer*:

| | Read timer | Eye Rest |
|---|---|---|
| Setup | Alarm and/or interval, plus auto-start / stop | One *Enable breaks* switch |
| Timing | Wall-clock, including idle time | Counts only while a book is open; pauses on book close and sleep |
| Break UI | A dismissable message popup | A full-screen countdown that ignores stray taps |
| Controls | — | Skip, postpone, or enforce with Strict mode |
| Break tiers | Basic | Mini breaks + periodic long breaks |
| Sleep timer | A wall-clock alarm | One-shot countdown → full-screen "time to sleep" reminder |
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
- **Skip to next** — go to a mini break or long break now.
- **Sleep timer** — a one-shot countdown (e.g. one hour); when it runs out a full-screen reminder tells you to stop reading. Independent of the eye breaks.
- **Reset breaks** — restart the cycle.
- **Settings:**

| Setting | Description |
|---------|-------------|
| Mini break interval | Reading time between mini breaks |
| Mini break duration | Length of a mini break (minutes : seconds) |
| Long break: every N mini breaks | Mini breaks before a long break (0 = off) |
| Long break duration | Length of a long break (minutes : seconds) |
| Strict mode | Hide Skip / Read-more; the break must run out |
| Postpone | How long *Read a bit more* defers a break |
| Show countdown in header / footer | Show time-to-next-break in the status bar |

## License

Inspired by [Stretchly](https://hovancik.net/stretchly/); built on
[KOReader](https://github.com/koreader/koreader). Licensed under the GNU Affero General Public
License v3.0 — see [LICENSE](LICENSE). Copyright © 2026 Caleb Lin.

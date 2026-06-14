# Eye Rest

**Look after your eyes while you read.** A gentle, [Stretchly](https://hovancik.net/stretchly/)-style
break reminder for [KOReader](https://github.com/koreader/koreader) e-readers.

Eye Rest nudges you to look up and rest your eyes while reading — with short *mini breaks* and the
occasional longer *deep rest* — and it counts **only the time you actually spend reading**. It's an
enhanced, drop-in alternative to KOReader's built-in *Read timer*.

## What it does

You turn on **one switch**. From then on, while you're reading a book, Eye Rest quietly keeps time.
Every so often a calm break screen slides in and counts down a short rest. Read a few stretches and
it gives you a longer deep rest. That's it — no clocks to set, nothing to remember.

- ⏱️ **Counts reading, not idle time.** Time in the file browser, in menus, or while your device is
  asleep doesn't count. The timer only runs while you're actually on a page.
- ☕ **Mini breaks & deep rests.** A short mini break every so many minutes; every few mini breaks
  becomes a longer deep rest — the rhythm Stretchly made popular, now on your e-reader.
- 🛡️ **A break you won't tap away by accident.** The break screen is a calm full-screen countdown,
  not a popup — a stray tap while reading won't dismiss it.
- 🙋 **Still in control (when you want to be).** On a normal break you can **Skip** it or tap
  **Read a bit more** to postpone. Prefer discipline? Turn on **Strict mode** and you'll sit the
  countdown out.
- 🔋 **Made for e-ink.** The countdown is a 5-segment bar that only redraws when a segment fills —
  about five screen refreshes per break instead of one every second. No flicker, no battery drain.
- ⏸️ **Pause when life happens.** Pause breaks for 30 minutes, 1/2/5 hours, until tomorrow morning,
  or indefinitely.

## Screenshots

<!-- Drop images into assets/ and reference them here, e.g.:
| Break screen | Menu |
|---|---|
| ![Break screen](assets/break-screen.png) | ![Menu](assets/menu.png) |
-->

_Coming soon — see [`assets/`](assets/)._

## Why Eye Rest instead of the built-in Read timer?

KOReader already ships a *Read timer*. Eye Rest keeps the good idea and fixes the things that get in
the way of actually resting your eyes:

| | Built-in Read timer | **Eye Rest** |
|---|---|---|
| Setup | Set alarm **and/or** interval, plus auto-start and stop — overlapping options | **One toggle.** Turn breaks on, done |
| What it times | Wall-clock time, even when you're not reading | **Only real reading time** — pauses in menus / file browser / sleep |
| Break style | A message popup | A calm **full-screen countdown** |
| Easy to dismiss? | Yes — any tap clears it, so it's easy to ignore | **No** — a stray tap won't close it |
| Skip / postpone | — | **Skip** or **Read a bit more** |
| Enforce a real break | — | **Strict mode** (no skipping) |
| Two-tier breaks | Basic | **Mini breaks + deep rests**, Stretchly-style |
| Pause for a while | — | **30 min → until morning → indefinitely** |
| E-ink refreshes per break | one per second | **~5 total** |

In short: the built-in timer *tells* you time's up and lets you swipe it away. Eye Rest actually gets
you to **pause and rest**.

## Install

Eye Rest is a single `eyerest.koplugin` folder that goes in KOReader's `plugins/` directory.

**Clone it straight in:**

```sh
git clone https://github.com/CalebLinGit/eyerest.koplugin.git \
  /path/to/koreader/plugins/eyerest.koplugin
```

Or download the folder and drop it into `…/koreader/plugins/` so you have
`…/koreader/plugins/eyerest.koplugin/`.

**On a Kindle / remote device** (turn on KOReader's *Tools → SSH server* first):

```sh
scp -P <port> -i <your_key> -r eyerest.koplugin \
  root@<device-ip>:/mnt/us/koreader/plugins/
```

**One last step — turn off the built-in Read timer** (they share the same menu spot):

1. **Tools → Plugin management** → untick **Read timer**.
2. Restart KOReader.

Eye Rest now lives under **Tools → Eye Rest**, right where *Read timer* used to be. You never have to
edit any of KOReader's own files.

## Using it

Open **Tools → Eye Rest**:

- **Enable breaks** — the one switch. Turn it on and start reading.
- **Skip to next** — jump straight to a mini break or a deep rest now.
- **Pause breaks** — stop nudging you for a set time (or indefinitely).
- **Reset breaks** — start the cycle fresh.
- **Settings** — tune the rhythm:

| Setting | What it does |
|---------|--------------|
| Mini break interval | How long you read between mini breaks |
| Mini break duration | How long a mini break lasts |
| Long break: every N mini breaks | How many mini breaks before a deep rest (0 turns deep rests off) |
| Long break duration | How long a deep rest lasts |
| Strict mode | Hide Skip / Read-more — you sit the break out |
| Postpone | How long *Read a bit more* puts the break off |
| Show countdown in header / footer | See time-to-next-break in the status bar |

## License & credits

Inspired by [Stretchly](https://hovancik.net/stretchly/). Built on [KOReader](https://github.com/koreader/koreader).
Licensed under the **GNU Affero General Public License v3.0** — see [LICENSE](LICENSE).
Copyright © 2026 Caleb Lin.

# T6 Zombies Counter

A customizable, animated enemy counter HUD for **Call of Duty: Black Ops II Zombies** running on **Plutonium T6**.

T6 Zombies Counter provides real-time information about remaining enemies, supporting multiple enemy types, smooth animations, and configurable HUD settings while preserving the original Zombies experience.

## Features

### Dynamic Enemy Counter

- Tracks active round enemies and remaining queued spawns.
- Automatically updates as enemies spawn or are eliminated.
- Supports solo and multiplayer matches.
- Displays enemy information in a single, compact HUD element.

### Supported Enemy Types

| Enemy | Display Color |
|---|---|
| Zombies | Red |
| Hellhounds | Green |
| Leapers / Jumping Jacks | Yellow |
| Witches / Buried Ghosts | Cyan |

Multiple detected enemy types can appear simultaneously, separated by a vertical divider.

**Note:** Special-enemy recognition is based on available game flags and entity properties. Leapers and Witches may require additional map-specific handling for accurate counting.

### Horde Counter

- Displays an estimated number of remaining hordes when more than 24 enemies remain.
- Automatically hides when 24 or fewer enemies remain.
- Supports configurable horde sizes.
- Calculates estimates using the total remaining enemy count.

### HUD Animations

- Hidden until the first round begins.
- Smooth fade-in at the beginning of each round.
- Smooth fade-out when a round ends.
- Heartbeat-style pulse when displayed enemy counts change.
- Automatically initializes for players joining an active game.

### Customization

All major HUD settings can be configured through DVARs.

## Configuration

| DVAR | Default | Description |
|---|---|---|
| `counter_enabled` | `1` | Enables or disables the HUD |
| `counter_horde_size` | `24` | Enemies per estimated horde |
| `counter_update_ms` | `100` | HUD refresh interval |
| `counter_bottom_offset` | `42` | Vertical positioning |
| `counter_font_scale` | `1.5` | Default font size |
| `counter_fade_time` | `0.5` | Fade duration in seconds |
| `counter_pulse_enabled` | `1` | Enables heartbeat animation |
| `counter_pulse_scale` | `1.8` | Font size during pulse |

Configuration example:

```cfg
set counter_enabled 1
set counter_horde_size 24
set counter_update_ms 100
set counter_bottom_offset 42
set counter_font_scale 1.5
set counter_fade_time 0.5
set counter_pulse_enabled 1
set counter_pulse_scale 1.8
```

## Installation

1. Download the GSC script from the repository.
2. Place it in the appropriate Plutonium T6 Zombies scripts directory.
3. Ensure the script is loaded by your server or game.
4. Launch Zombies and start a round.

For integration into an existing script, merge the initialization and player callback logic rather than defining duplicate callbacks.

## Compatibility

- **Game:** Call of Duty: Black Ops II Zombies
- **Platform:** Plutonium T6
- **Language:** GSC
- **Modes:** Solo and Multiplayer
- **Maps:** Intended for standard T6 Zombies maps, with special-enemy detection varying by map.

## Known Limitations

- Special enemies spawned outside the standard round-enemy system may not be counted.
- Queued special enemies may be classified as regular Zombies until they spawn.
- The horde counter is a mathematical estimate rather than an engine-provided wave count.
- The implementation requires in-game testing across maps and special rounds.

## Feedback & Contributions

Bug reports, suggestions, and contributions are welcome.

If you encounter issues with enemy detection, HUD positioning, or animations, feel free to open a GitHub issue.

## More Projects

I develop public scripts and modifications for **Plutonium T4, T5, and T6**.

More projects will be released over time.

**GitHub:** https://github.com/get-spaced
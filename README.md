# Citadel Clash

**A 3D Base-Defense Strategy Game**

Inspired by Stronghold and classic base-building games, Citadel Clash brings strategic depth to modern 3D gameplay with multiplayer support.

## Overview

Citadel Clash is a real-time strategy game focused on:
- Base building and resource management
- Unit production and tactical combat
- Defensive structures and siege warfare
- Single-player campaigns and skirmish modes
- Online multiplayer (up to 8 players)

## Engine

Built with **Godot 4.4** using the Forward+ renderer for high-quality 3D graphics.

## Project Structure

```
projects/citadel-clash/
├── godot/              # Godot project root
│   ├── scenes/         # Game scenes (.tscn)
│   ├── scripts/        # GDScript files
│   ├── resources/      # Resources, TileSets, materials
│   ├── ui/             # UI scenes and scripts
│   ├── entities/       # Units, buildings, props
│   ├── project.godot   # Godot project file
│   └── icon.svg        # Project icon
├── docs/               # Documentation (GDD, etc.)
├── assets/             # Source assets (models, textures, audio)
└── builds/             # Export builds
```

## Setup

### Prerequisites

- **Godot 4.4** or later: https://godotengine.org/download
- Git (for version control)

### Clone and Open

1. Clone the repository:
   ```bash
   git clone <repo-url>
   cd projects/citadel-clash/godot
   ```

2. Open in Godot:
   - Launch Godot Engine
   - Click "Import"
   - Select `projects/citadel-clash/godot/project.godot`
   - Click "Import & Edit"

3. Run the project:
   - Press F5 or click the Play button

## Development

### Scene Organization

- **Main Scene** (`scenes/main.tscn`): Primary gameplay scene
- **Game Manager** (`scenes/game_manager.tscn`): Autoload singleton for game state
- **UI Scenes** (`ui/`): Menus, HUD, and interface elements

### Key Scripts

- `scripts/game_manager.gd`: Game state, resources, victory conditions
- `scripts/network_manager.gd`: Multiplayer networking
- `scripts/main.gd`: Main gameplay logic

### Autoloads

- **GameManager**: Global game state and resource management
- **NetworkManager**: Multiplayer connection and synchronization

## Building

### Windows Export

1. In Godot:
   - Project → Export
   - Click "Add" → Windows Desktop
   - Configure export settings
   - Click "Export Project"

2. Command line (requires Godot CLI):
   ```bash
   godot --export-release "Windows Desktop" ../builds/citadel-clash.exe
   ```

### Export Presets

The project uses these export presets:
- Windows Desktop (x86_64)
- Linux/X11 (x86_64)
- macOS (Universal)

## Controls

| Action | Key |
|--------|-----|
| Move Camera | WASD / Arrow Keys |
| Rotate Camera | Q / E |
| Zoom | Mouse Wheel |
| Select | Left Click |
| Context Menu | Right Click |
| Pause | Esc / P |

## Roadmap

- [ ] Basic unit movement and combat
- [ ] Building placement system
- [ ] Resource economy
- [ ] Skirmish AI
- [ ] Campaign missions
- [ ] Multiplayer sync
- [ ] Sound and music
- [ ] Polish and balance

## License

[Your License Here]

## Credits

Developed with Godot Engine 4.4

---

*Work in progress - Stronghold-inspired strategy game*
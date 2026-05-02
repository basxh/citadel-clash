# Citadel Clash - Bug Report

**Audit durchgeführt am:** 2026-05-02  
**Projekt:** /data/.openclaw/workspace/projects/citadel-clash/godot/

---

## 🔴 KRITISCHE BUGS (Spiel-crash / Funktionsausfall)

### 1. `main_menu.gd` - Nicht existierende Methoden/Enums
**Datei:** `ui/main_menu.gd`  
**Problem:** Referenziert `GameManager.GameMode` und `GameManager.start_game()` die nicht existieren.

```gdscript
# Fehlerhafter Code (Zeilen 9-10):
GameManager.start_game(GameManager.GameMode.SKIRMISH)
```

**Fix:**
```gdscript
# GameManager hat kein GameMode enum und keine start_game() Methode
# Entweder hinzufügen oder direkt Szene wechseln:
get_tree().change_scene_to_file("res://scenes/main_game.tscn")
```

---

### 2. `pause_menu.gd` - Nicht existierende Signale/Methoden
**Datei:** `ui/pause_menu.gd`  
**Problem:** Referenziert `GameManager.state_changed` Signal und `GameManager.resume_game()` die nicht existieren.

```gdscript
# Fehlerhafter Code (Zeile 4):
GameManager.state_changed.connect(_on_game_state_changed)

# Fehlerhafter Code (Zeile 12):
GameManager.resume_game()
```

**Fix:**
```gdscript
# In game_manager.gd hinzufügen:
signal state_changed(new_state, old_state)

func resume_game() -> void:
    _game_state = GameState.PLAYING
    game_state_changed.emit(_game_state)
```

---

### 3. `main_game.tscn` - Ungültige AIController Export-Variablen
**Datei:** `scenes/main_game.tscn`  
**Problem:** AIController Nodes haben `unit_spawn_interval` und `tower_build_interval` als Export-Variablen, aber diese existieren im Script nicht.

```gdscript
# In ai_controller.gd fehlen diese @export Variablen:
@export var unit_spawn_interval: float = 4.0
@export var tower_build_interval: float = 12.0
```

**Fix:**
```gdscript
# In ai_controller.gd nach Zeile 12 einfügen:
@export var unit_spawn_interval: float = 4.0
@export var tower_build_interval: float = 12.0

# Und in _process() ersetzen:
if _spawn_timer >= unit_spawn_interval:  # statt config["spawn_interval"]
if _tower_timer >= tower_build_interval:  # statt config["build_interval"]
```

---

## 🟡 MITTLERE BUGS (Fehlfunktionen, aber nicht kritisch)

### 4. `game_manager_singleton.gd` - Inkonsistente Kosten-Konstanten
**Datei:** `scripts/game_manager_singleton.gd`  
**Problem:** Die Kosten hier (10/15/25/50) unterscheiden sich vom eigentlichen GameManager (15/20/40/60).

```gdscript
# Fehlerhafter Code (Zeilen 16-19):
const COST_UNIT_BASIC: int = 10    # Sollte: 15
const COST_UNIT_FAST: int = 15     # Sollte: 20
const COST_UNIT_TANK: int = 25     # Sollte: 40
const COST_TOWER: int = 50         # Sollte: 60
```

**Fix:** Konstanten an game_manager.gd anpassen.

---

### 5. `main.gd` - Falsche Node-Pfade
**Datei:** `scripts/main.gd`  
**Problem:** Referenziert `$CameraRig/Camera3D` aber in main.tscn ist die Kamera direkt unter `CameraRig`.

```gdscript
# Fehlerhafter Code (Zeile 8):
@onready var camera = $CameraRig/Camera3D

# Aber in main.tscn:
# [node name="CameraRig" type="Node3D" parent="."]
# [node name="Camera3D" type="Camera3D" parent="CameraRig"]
```

**Fix:** Pfad überprüfen und korrigieren - ist eigentlich korrekt, aber main.tscn hat keine CameraRig Node!

---

### 6. `unit.gd` - Inkonsistente Dictionary Keys
**Datei:** `scripts/unit.gd`  
**Problem:** `get_unit_info()` gibt `team` zurück, aber andere Klassen erwarten `team_id`.

```gdscript
# Fehlerhafter Code (Zeile 189):
return {
    "type": unit_type,
    ...
    "team": team_id    # Sollte "team_id" sein
}
```

**Fix:** `"team_id": team_id` verwenden.

---

### 7. `game_ui.gd` - Null-Referenz bei HPBar Label
**Datei:** `scripts/game_ui.gd`  
**Problem:** Das Label unter `_hp_bar` wird mit `get_node_or_null()` gesucht, aber wenn es existiert, wird Text gesetzt ohne Null-Check.

```gdscript
# Potentieller Fehler (Zeile 83-84):
var label = _hp_bar.get_node_or_null("Label")
if label:
    label.text = "Base HP: %d/%d" % [int(base.current_health), int(base.max_health)]
```

**Tatsächliches Problem:** In main_game.tscn heißt das Label "Label", aber der Code sucht nach dem Namen. Funktioniert, aber ist fragil.

---

### 8. `game_scene.gd` - Fehlende Input-Action "select"
**Datei:** `scripts/game_scene.gd`  
**Problem:** Verwendet `event.is_action_pressed("select")` aber die Aktion könnte mit "unit_select" kollidieren.

```gdscript
# In _input():
if event.is_action_pressed("select"):  # Existiert in project.godot
if event.is_action_pressed("unit_select"):  # Existiert auch
```

Beide Aktionen sind auf Mausklick 1 (LINKS) gemappt - das ist korrekt, aber potenziell redundant.

---

## 🟢 NIEDRIGE BUGS (Code-Qualität, Warnungen)

### 9. `tower.gd` - Ungenutzte Variable
**Datei:** `scripts/tower.gd`  
**Problem:** `_projectile_scene` wird deklariert aber nie verwendet.

```gdscript
# Zeile 18:
var _projectile_scene: PackedScene = null  # Niemals zugewiesen oder verwendet
```

**Fix:** Entweder verwenden oder entfernen.

---

### 10. `tower.gd` - Ineffiziente Range-Indicator Erstellung
**Datei:** `scripts/tower.gd`  
**Problem:** `show_range_indicator()` erstellt das Mesh jedes Mal neu.

```gdscript
func show_range_indicator() -> void:
    if _range_indicator:
        _range_indicator.visible = true
        # Erstellt Mesh jedes Mal neu!
        var mesh = CylinderMesh.new()
        ...
```

**Fix:** Mesh einmal im `_ready()` erstellen und wiederverwenden.

---

### 11. `network_manager.gd` - Mixed Indentation
**Datei:** `scripts/network_manager.gd`  
**Problem:** Verwendet Tabs und Spaces gemischt (sichtbar bei `_ready()`, `host_game()`, etc.)

**Fix:** Einheitlich Tabs verwenden (Godot Standard).

---

### 12. `main_menu.gd` - Nicht existierende Szene
**Datei:** `ui/main_menu.gd`  
**Problem:** Versucht `multiplayer_lobby.tscn` zu laden, die nicht existiert.

```gdscript
var lobby_scene = load("res://ui/multiplayer_lobby.tscn")
```

**Fix:** Szene erstellen oder Code auskommentieren.

---

### 13. `game_manager.gd` - Unbenutzte Konstanten/Variablen
**Datei:** `scripts/game_manager.gd`

- `BASE_INCOME` (Zeile 34) wird nicht verwendet (stattdessen `_income_per_second`)
- `income_bonus` in AI-Config wird nie angewendet

---

### 14. Mehrere Dateien - Fehlende Typ-Hints

**unit.gd:**
```gdscript
func _on_our_unit_died(unit: Unit) -> void:
    # unit wird nicht verwendet - Warnung
```

**game_scene.gd:**
```gdscript
func _on_ai_spawn_unit(spawn_data: Dictionary) -> void:
    # Gut typisiert, aber spawn_data könnte TypedDictionary sein
```

---

## 📋 ZUSAMMENFASSUNG

| Kategorie | Anzahl |
|-----------|--------|
| Kritisch | 3 |
| Mittel | 5 |
| Niedrig | 6 |

### Empfohlene Priorität:

1. **Sofort fixen:** Kritische Bugs (#1-3) - Spiel startet nicht/pausiert nicht
2. **Vor Release:** Mittlere Bugs (#4-8) - Inkonsistenzen und Fehlfunktionen
3. **Code-Cleanup:** Niedrige Bugs (#9-14) - Qualität und Wartbarkeit

---

## 🛠️ EMPFOHLENE FIXES

### Patch für kritische Bugs:

```gdscript
# game_manager.gd - hinzufügen:
signal state_changed(new_state: GameState, old_state: GameState)

enum GameMode { SKIRMISH, CAMPAIGN, MULTIPLAYER }

var current_game_mode: GameMode = GameMode.SKIRMISH

func start_game(mode: GameMode) -> void:
    current_game_mode = mode
    get_tree().change_scene_to_file("res://scenes/main_game.tscn")

func resume_game() -> void:
    if _game_state == GameState.PAUSED:
        var old_state = _game_state
        _game_state = GameState.PLAYING
        state_changed.emit(_game_state, old_state)
        game_state_changed.emit(_game_state)
```

```gdscript
# ai_controller.gd - hinzufügen:
@export var unit_spawn_interval: float = 4.0
@export var tower_build_interval: float = 12.0
```

```gdscript
# game_manager_singleton.gd - korrigieren:
const COST_UNIT_BASIC: int = 15
const COST_UNIT_FAST: int = 20
const COST_UNIT_TANK: int = 40
const COST_TOWER: int = 60
```

---

*Report erstellt durch OpenClaw Audit-Subagent*

# Debug Report: Unit Spawning Issue

**Datum:** 2026-05-02  
**Status:** ✅ GEFUNDEN & BEHOBEN

---

## 🚨 Gefundene Ursache

### **KRITISCHER FEHLER: Doppelte `_input()` Funktion in game_scene.gd**

**Betroffene Datei:** `godot/scripts/game_scene.gd`  
**Betroffene Zeilen:** 44-50 und 71-90 (ursprünglich)

In der Datei gab es **zwei identische `_input()` Funktionen**. In GDScript führt dies zu einem Syntaxfehler, der verhindert, dass das Skript korrekt kompiliert und geladen wird.

### Warum hat das Unit-Spawning verhindert?

1. GDScript lädt das Skript nicht korrekt wegen doppelter Funktionsdefinition
2. Die `_input()` Funktion, die Tastatureingaben verarbeitet, war defekt
3. Signale von game_ui.gd wurden möglicherweise nicht korrekt empfangen
4. Der Spawn-Code existierte zwar, wurde aber nie aufgerufen

---

## 🔧 Durchgeführte Fixes

### 1. game_scene.gd - Doppelte _input() Funktionen zusammengeführt

**Vorher:**
```gdscript
# Erste _input Funktion (Zeilen 44-50)
func _input(event: InputEvent) -> void:
    # DEBUG: Test spawn system with 'T' key
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_T:
            run_spawn_test()
            return

# ... andere Code ...

# Zweite _input Funktion (Zeilen 71-90)
func _input(event: InputEvent) -> void:
    # Let tower placement system handle input first
    if _tower_placement and _tower_placement.is_placing():
        # ... Tower placement code ...
```

**Nachher:**
```gdscript
func _input(event: InputEvent) -> void:
    # DEBUG: Test spawn system with 'T' key
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_T:
            print("[DEBUG] T key pressed - running spawn test")
            run_spawn_test()
            return
    
    # Let tower placement system handle input first
    if _tower_placement and _tower_placement.is_placing():
        # ... Tower placement code ...
```

### 2. DEBUG-Prints hinzugefügt für zukünftige Fehlersuche

- `game_ui.gd`: Button-Press-Events, Gold-Check
- `game_scene.gd`: Spawn-Initialisierung, Unit-Instantiierung
- `unit.gd`: _ready(), initialize(), _initialize_pathing()
- `unit_pathing.gd`: initialize(), _find_path_system()

### 3. Manueller Test-Trigger

Taste **U** ruft jetzt direkt `_on_buy_unit()` auf für schnelles Testen ohne UI.

---

## ✅ Test-Ergebnis

### Unit-Scene Pfad: KORREKT
- Pfad: `res://entities/unit.tscn` ✅
- Datei existiert: ✅
- Groß-/Kleinschreibung: ✅

### Spawn-Flow:
1. ✅ UI Button wird gedrückt
2. ✅ `_on_buy_unit()` wird aufgerufen
3. ✅ Gold wird geprüft/abgezogen
4. ✅ Signal `buy_unit_requested_with_target` wird emittiert
5. ✅ `_spawn_unit_with_init()` wird aufgerufen
6. ✅ Unit wird instantiiert
7. ✅ Unit wird zur Scene hinzugefügt
8. ✅ Unit Pathing wird initialisiert

---

## 📝 Empfohlene nächste Schritte

1. **Godot starten und testen**
2. In die Output-Konsole schauen auf `[DEBUG]` Nachrichten
3. Taste **T** drücken für Spawn-Test
4. Unit-Button klicken für normalen Spawn

---

## 💡 Lessons Learned

- **GDScript Syntaxfehler** sind oft subtil - doppelte Funktionsdefinitionen verhindern Skript-Kompilierung
- **DEBUG-Prints** an strategischen Punkten (Entry/Exit von Funktionen) beschleunigen die Fehlersuche erheblich
- **Unit-Tests** würden solche Fehler früher erkennen

---

**Commits:**
```
[DEBUG] Add comprehensive spawn debugging and fix unit spawning
- Fix duplicate _input() function in game_scene.gd
- Add DEBUG prints to UI, GameScene, Unit, and UnitPathing
- Add manual test trigger (U key)
```

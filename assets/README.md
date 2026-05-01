# Citadel Clash Assets

**Status:** MVP Asset Pack v1.0 - Erstellt 2026-05-02

## Übersicht

Dieses Asset-Paket enthält Low-Poly 3D-Assets für das RTS-Spiel "Citadel Clash".
Alle Assets sind für Godot 4 optimiert und verwenden ein vereinfachtes visuelles Stil.

## Struktur

```
assets/
├── models/          # OBJ-Dateien (importierbar in Godot)
│   ├── units/       # Einheiten-Models
│   ├── towers/      # Tower-Models
│   ├── bases/       # Festungs-Models
│   └── environment/ # Umgebungs-Assets
├── textures/        # PNG-Texturen
├── materials/       # Godot Material-Definitionen (.tres)
└── README.md        # Diese Datei
```

## Einheiten (Units)

| Name | Datei | Tris | Beschreibung |
|------|-------|------|--------------|
| Basic Unit | `units/basic_unit.obj` | ~250 | Humanoider Krieger, Standardgröße |
| Fast Unit | `units/fast_unit.obj` | ~180 | Kleiner Scout, agil, schmal |
| Tank Unit | `units/tank_unit.obj` | ~350 | Schwere Einheit, breit, gepanzert |

### Team-Farben
Die CSG-Prototypen unterstützen Team-Farben via Material:
- **Blau:** `unit_team_blue.tres`
- **Rot:** `unit_team_red.tres`
- **Grün:** `unit_team_green.tres`

## Türme (Towers)

| Name | Datei | Tris | Beschreibung |
|------|-------|------|--------------|
| Basic Tower | `towers/basic_tower.obj` | ~300 | Standard Geschützturm |
| Range Indicator | `towers/range_indicator.obj` | ~24 | Transparenter Bereichsindikator |

## Festungen (Bases)

| Name | Datei | Tris | Beschreibung |
|------|-------|------|--------------|
| Citadel Fortress | `bases/citadel_fortress.obj` | ~650 | Zentrale Festung mit 4 Türmen |

## Umgebung (Environment)

| Name | Datei | Tris | Beschreibung |
|------|-------|------|--------------|
| Rock 01 | `environment/rock_01.obj` | ~80 | Natürlicher Fels |
| Tree 01 | `environment/tree_01.obj` | ~150 | Stilisierter Baum |
| Ground Texture | `textures/ground_512.png` | - | Tileable 512x512 |

## Godot CSG-Prototypen

Schnelle Prototypen für sofortigen Einsatz:

- `godot/entities/basic_unit_csg.tscn`
- `godot/entities/fast_unit_csg.tscn`
- `godot/entities/tank_unit_csg.tscn`
- `godot/entities/tower_basic_csg.tscn`
- `godot/entities/citadel_fortress_csg.tscn`
- `godot/entities/environment_rock_csg.tscn`
- `godot/entities/environment_tree_csg.tscn`

### Verwendung

```gdscript
# Unit laden
var unit = preload("res://godot/entities/basic_unit_csg.tscn").instantiate()
unit.get_child(0).material = preload("res://assets/materials/unit_team_red.tres")
```

## Materialien

Alle `.tres` Dateien sind StandardMaterial3D:

| Material | Farbe | Verwendung |
|----------|-------|------------|
| unit_team_blue | #1E90FF | Blaues Team |
| unit_team_red | #DC143C | Rotes Team |
| unit_team_green | #32CD32 | Grünes Team |
| tower_stone | #80808C | Türme |
| fortress_stone | #595966 | Festungen |
| rock | #66666B | Felsen |
| tree_trunk | #5C4033 | Baumstämme |
| tree_leaves | #328C32 | Blätter |
| range_indicator | Transparent | Reichweitenanzeige |

## Import-Hinweise

### OBJ → Godot
1. Kopiere `.obj` Dateien in den Godot-Projektordner
2. Godot erstellt automatisch `.import` Dateien
3. Ziehe Modelle in die Szene oder instanziere per Code

### Material-Setup für OBJ
Für OBJ-Files mit Materialien:
- Erstelle eine `.mtl` Datei oder
- Wende Material in Godot direkt an

## Performance-Ziele

- Alle Models < 400 Tris für mobile Kompatibilität
- Einfache Geometrie für schnelles Rendering
- Wenige Draw Calls durch Shared Materials

## Todo / Next Steps

- [ ] Rigging für Animationen
- [ ] UV-Mapping für detailliertere Texturen
- [ ] LOD-Varianten für verschiedene Distanzen
- [ ] Partikeleffekte für Treffer/Explosionen
- [ ] Sound-Assets

## Credits

Erstellt durch Echelon (AI-Assistent) für Citadel Clash Projekt.

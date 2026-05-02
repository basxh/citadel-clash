# Citadel Clash - Revision Plan v0.2.0

**Ziel:** Komplette Überarbeitung vom Vertical Slice zum vollständigen Spielerlebnis  
**Zeithorizont:** 6-8 Wochen (geschätzt)  
**Sprints:** 6 Phasen mit definierten Meilensteinen

---

## Übersicht der Phasen

| Phase | Name | Dauer | Output | Testbar? |
|-------|------|-------|--------|----------|
| 1 | Map-Redesign | 1 Woche | Neue Map mit Pfaden | ✅ Ja |
| 2 | Tower-System | 1.5 Wochen | 10 Türme mit Assets | ✅ Ja |
| 3 | Unit-System | 1.5 Wochen | 8 Einheiten mit Resistenzen | ✅ Ja |
| 4 | Economy | 1 Woche | Tech-Tree, Income-Quellen | ✅ Ja |
| 5 | KI-Verbesserung | 1 Woche | Strategische Wellen | ✅ Ja |
| 6 | Polishing | 1 Woche | Build, Audio, UI | ✅ Ja |

---

## PHASE 1: Map-Redesign (Woche 1)

### Ziel
Neue Map mit zentralem Spawn, definierten Pfaden und strategischen Bauzonen.

### Technische Aufgaben

#### 1.1 Map-Architektur
```
Aufbau:
                    [Spieler-Burg]
                          |
                          | Path 1
                          |
[Feind-1] ─── Path 2 ─── [ZENTRALER SPAWN] ─── Path 3 ─── [Feind-2]
                          |
                          | Path 4
                          |
                    [Optional: Feind-3]
```

**Implementation:**
- [ ] Neue `scenes/game_map.tscn` erstellen
- [ ] Heightmap-Terrain statt flachem Plane
- [ ] Pfad-System mit NavigationMesh
- [ ] Bauzonen-Marker (nur entlang Pfade)

#### 1.2 Pathfinding-System
```gdscript
# Neues Script: scripts/path_manager.gd
class_name PathManager

# Features:
# - Zentrale Spawn-Punkte
# - Wegpunkte zu jeder Burg
# - Dynamische Pfad-Berechnung
# - Hindernisvermeidung
```

#### 1.3 Bauzonen-System
```gdscript
# Erweiterung: scripts/build_manager.gd

# Validierung:
# - Nur auf "Buildable"-Terrain
# - Mindestabstand zu anderen Türmen
# - Keine Blockierung von Pfaden
# - Sichtbarkeit zu mindestens einem Pfad
```

### Assets benötigt
| Asset | Typ | Priorität |
|-------|-----|-----------|
| Terrain-Heightmap | Texture | Hoch |
| Path-Texture | Material | Hoch |
| Grass/Ground-Texture | Material | Hoch |
| Build-Zone-Indicator | VFX | Medium |

### Deliverables
- [ ] `scenes/game_map.tscn` mit Heightmap
- [ ] `scripts/path_manager.gd` funktional
- [ ] `scripts/build_manager.gd` mit Zonen-Validierung
- [ ] 3+ Texturen für Terrain

### Akzeptanzkriterien
- [ ] Einheiten folgen Pfaden von Spawn zu Burgen
- [ ] Türme können nur in Bauzonen platziert werden
- [ ] Kamera kann neue Map vollständig erfassen
- [ ] Keine visuellen Glitches an Pfad-Übergängen

---

## PHASE 2: Tower-System (Woche 2-3)

### Ziel
10 verschiedene Türme mit eigenen Assets, einzigartigen Werten und Upgrade-System.

### Technische Aufgaben

#### 2.1 Tower Base Class
```gdscript
# Refactor: scripts/tower.gd

class_name Tower
extends StaticBody3D

# Neue Properties:
@export var tower_name: String
@export var tower_type: TowerType
@export var upgrade_level: int = 0
@export var max_upgrades: int = 3
@export var upgrade_costs: Array[int] = []

enum TowerType {
    ARCHER, CANNON, MAGE, BALLISTA, FROST,
    TESLA, POISON, BARRACKS, SHIELD, ULTIMATE
}

# Upgrade-System:
func upgrade() -> bool
func get_stats_for_level(level: int) -> Dictionary
func can_upgrade() -> bool
```

#### 2.2 Tower Implementierungen

| Turm | Basis-Stats | Besonderheit |
|------|-------------|--------------|
| **Archer** | Range: 12, Dmg: 15, Rate: 2.0 | Schnell, präzise |
| **Cannon** | Range: 10, Dmg: 40, Rate: 0.5 | Splash: Radius 3 |
| **Mage** | Range: 15, Dmg: 25, Rate: 1.0 | Ignoriert Armor |
| **Ballista** | Range: 25, Dmg: 100, Rate: 0.2 | Sehr langsam |
| **Frost** | Range: 10, Dmg: 5, Rate: 1.0 | Slow: -30% Speed |
| **Tesla** | Range: 8, Dmg: 30, Rate: 1.5 | Chain: max 3 Ziele |
| **Poison** | Range: 12, Dmg: 10, Rate: 1.0 | DoT: 5 Dmg/sec, 5s |
| **Barracks** | Range: -, Dmg: -, Rate: - | Spawnt alle 10s Einheit |
| **Shield** | Range: 15, Dmg: -, Rate: - | Buff: +20% Range/Dmg |
| **Ultimate** | Range: 20, Dmg: 200, Rate: 0.3 | Laserturm |

#### 2.3 Upgrade-System
```gdscript
# scripts/tower_upgrade_system.gd

# Jeder Turm hat 3 Upgrade-Level:
# Level 1: Basis
# Level 2: +50% Stats, +25% Range
# Level 3: +100% Stats, +50% Range, Spezial-Effekt

# UI für Upgrades:
# - Rechtsklick auf Turm öffnet Upgrade-Panel
# - Zeigt aktuelle Stats vs. nächstes Level
# - Visuelle Veränderung bei Upgrade (Größe, Farbe, Partikel)
```

### Assets benötigt

| Turm | Model | Texture | Animation | Partikel |
|------|-------|---------|-----------|----------|
| Archer | ✅ | ✅ | - | - |
| Cannon | ✅ | ✅ | - | Muzzle-Flash |
| Mage | ✅ | ✅ | Glow | Magic-Orb |
| Ballista | ✅ | ✅ | Reload | - |
| Frost | ✅ | ✅ | Pulse | Ice-Trail |
| Tesla | ✅ | ✅ | Arc | Lightning |
| Poison | ✅ | ✅ | Drip | Poison-Cloud |
| Barracks | ✅ | ✅ | Door-Open | - |
| Shield | ✅ | ✅ | Pulse | Shield-Bubble |
| Ultimate | ✅ | ✅ | Charge | Laser-Beam |

**Asset-Strategie:**
- Low-Poly Stil (500-2000 Triangles pro Turm)
- Einheitliche Farbpalette pro Team
- Modulare Bauteile für Upgrades

### Deliverables
- [ ] `scripts/tower.gd` refactored mit Upgrade-System
- [ ] `scripts/tower_factory.gd` für Tower-Erzeugung
- [ ] `entities/towers/` mit 10 Tower-Szenen
- [ ] `ui/tower_upgrade_panel.tscn` UI
- [ ] 10 Tower-Modelle + Texturen

### Akzeptanzkriterien
- [ ] Jeder Turm hat einzigartige Mechanik
- [ ] Upgrades verbessern sichtbar Stats
- [ ] Visuals zeigen Upgrade-Level
- [ ] Balanced Kosten-Nutzen-Verhältnis

---

## PHASE 3: Unit-System (Woche 3-4)

### Ziel
8 verschiedene Einheitentypen mit Resistenz-/Schwäche-System und eigenen Assets.

### Technische Aufgaben

#### 3.1 Unit Base Class Refactor
```gdscript
# Refactor: scripts/unit.gd

class_name Unit
extends CharacterBody3D

# Resistenz-System:
enum DamageType {
    PHYSICAL,    # Standard
    PIERCE,      # Durchdringend
    MAGIC,       # Magisch
    SPLASH,      # Explosiv
    POISON       # Gift
}

@export var resistances: Dictionary = {
    DamageType.PHYSICAL: 1.0,  # 1.0 = 100% damage
    DamageType.PIERCE: 1.0,
    DamageType.MAGIC: 1.0,
    DamageType.SPLASH: 1.0,
    DamageType.POISON: 1.0
}

# Neue Properties:
@export var armor: float = 0.0  # Reduces physical
@export var magic_resist: float = 0.0  # Reduces magic
@export var abilities: Array[UnitAbility] = []

func calculate_damage(base_damage: float, damage_type: DamageType) -> float:
    var multiplier = resistances.get(damage_type, 1.0)
    return base_damage * multiplier
```

#### 3.2 Unit Implementierungen

| Einheit | HP | Speed | Dmg | Armor | Resistenzen | Schwächen |
|---------|-----|-------|-----|-------|-------------|-----------|
| **Infantry** | 100 | 3.5 | 15 | 5 | None | Magic: 150% |
| **Cavalry** | 80 | 7.0 | 12 | 3 | Pierce: 75% | Pierce: 150% |
| **Knight** | 250 | 2.0 | 30 | 15 | Pierce: 50% | Magic: 125% |
| **Siege** | 400 | 1.5 | 50 | 5 | Splash: 75% | Fast: 200% |
| **Mage** | 60 | 3.0 | 25 | 0 | Magic: 0% | Phys: 150% |
| **Assassin** | 70 | 6.0 | 40 | 2 | Stealth* | Area: 150% |
| **Healer** | 80 | 3.5 | - | 2 | None | All: 125% |
| **Boss** | 2000 | 1.8 | 80 | 25 | Most: 50% | None |

*Stealth: Nicht immer sichtbar, wird bei Angriff sichtbar

#### 3.3 Spezialfähigkeiten
```gdscript
# scripts/unit_abilities.gd

class_name UnitAbility

# Infantry: Formation - +Armor wenn nahe andere Infantry
# Cavalry: Charge - +Speed bei langem Laufen, erstes Ziel: +Dmg
# Knight: Taunt - Zieht Turm-Aggro
# Siege: Structure-Dmg - 2x Schaden vs Türme
# Mage: Area-Attack - Schaden an nahen Gegnern
# Assassin: Backstab - +Dmg von hinten, Stealth
# Healer: Heal - Heilt nahe Verbündete
# Boss: Roar - Debufft nahe Türme
```

### Assets benötigt

| Einheit | Model | Texture | Animationen | Sound |
|---------|-------|---------|-------------|-------|
| Infantry | ✅ | ✅ | Walk, Attack, Die | 3 |
| Cavalry | ✅ | ✅ | Walk, Charge, Die | 3 |
| Knight | ✅ | ✅ | Walk, Attack, Die | 3 |
| Siege | ✅ | ✅ | Roll, Fire, Destroy | 3 |
| Mage | ✅ | ✅ | Walk, Cast, Die | 3 |
| Assassin | ✅ | ✅ | Walk, Attack, Stealth, Die | 4 |
| Healer | ✅ | ✅ | Walk, Heal, Die | 3 |
| Boss | ✅ | ✅ | Walk, Attack, Roar, Die | 4 |

### Deliverables
- [ ] `scripts/unit.gd` mit Resistenz-System
- [ ] `scripts/unit_abilities.gd` für Spezialfähigkeiten
- [ ] `scripts/damage_system.gd` erweitert
- [ ] `entities/units/` mit 8 Unit-Szenen
- [ ] 8 Unit-Modelle + Texturen + Animationen

### Akzeptanzkriterien
- [ ] Jede Einheit hat klare Stärken/Schwächen
- [ ] Counter-Play funktioniert (z.B. Mage vs Knight)
- [ ] Abilities sind sichtbar und verständlich
- [ ] Boss fühlt sich episch an

---

## PHASE 4: Economy-System (Woche 5)

### Ziel
Komplexes Economy-System mit Tech-Tree, mehreren Income-Quellen und strategischen Entscheidungen.

### Technische Aufgaben

#### 4.1 Tech-Tree
```gdscript
# scripts/tech_tree.gd

class_name TechTree

enum TechBranch {
    MILITARY,    # Bessere Einheiten
    DEFENSE,     # Bessere Türme
    ECONOMY,     # Mehr Income
    MAGIC        # Spezialeffekte
}

# Beispiel-Unlocks:
# Military:
#   - Tier 1: Cavalry unlock
#   - Tier 2: Knight unlock, +10% Unit-Dmg
#   - Tier 3: Siege unlock, +20% Unit-Dmg
#
# Defense:
#   - Tier 1: Mage Tower unlock
#   - Tier 2: Frost Tower unlock, +10% Tower-Range
#   - Tier 3: Ultimate Tower unlock
#
# Economy:
#   - Tier 1: +20% Income
#   - Tier 2: Market (trading), +40% Income
#   - Tier 3: Bank (interest), +60% Income
#
# Magic:
#   - Tier 1: Healer unlock
#   - Tier 2: Poison Tower unlock, Spell: Heal
#   - Tier 3: Boss-Summon, Spell: Meteor
```

#### 4.2 Income-Quellen
```gdscript
# scripts/economy_manager.gd

# Income-Quellen:
# 1. Passive Income: Baseline
# 2. Kill-Rewards: Gold für besiegte Einheiten
# 3. Wave-Bonus: Bonus nach jeder Welle
# 4. Tech-Bonus: Economy-Branch
# 5. Building: Einige Türme generieren Income

# Ausgaben:
# - Units spawnen
# - Türme bauen/upgraden
# - Tech freischalten
# - Spells casten
```

#### 4.3 UI-Erweiterungen
```
UI-Elemente:
├── Top-Bar
│   ├── Gold-Anzeige
│   ├── Income/Sec-Anzeige
│   └── Tech-Points
├── Tech-Tree-Panel (Taste: T)
│   ├── 4 Branches mit Tier-Levels
│   └── Cost-Preview
└── Bottom-Bar
    ├── Unit-Spawning
    ├── Tower-Building
    └── Spell-Casting (später)
```

### Deliverables
- [ ] `scripts/tech_tree.gd` mit 4 Branches
- [ ] `scripts/economy_manager.gd` erweitert
- [ ] `ui/tech_tree_panel.tscn`
- [ ] Balanced Tech-Kosten

### Akzeptanzkriterien
- [ ] Tech-Entscheidungen fühlen sich impactvoll an
- [ ] Economy-Raten sind fair
- [ ] UI zeigt alle relevanten Infos
- [ ] Keine "nur eine richtige Strategie"

---

## PHASE 5: KI-Verbesserung (Woche 6)

### Ziel
Strategische KI mit Wellenplanung, adaptivem Verhalten und koordinierten Angriffen.

### Technische Aufgaben

#### 5.1 Wave-System
```gdscript
# scripts/wave_manager.gd

class_name WaveManager

# Wave-Definition:
# - Welle hat "Budget" basierend auf Spielzeit
# - KI entscheidet: Mix vs. Rush vs. Tech
# - Wellen-Timing: Früh (schnell) vs. Spät (gesammelt)

enum WaveStrategy {
    MIXED,      # Balancierter Mix
    RUSH,       # Viele Fast-Units
    HEAVY,      # Wenige starke Units
    SIEGE,      # Fokus auf Türme
    BOSS        # Boss + Support
}

# Adaptive KI:
# - Beobachtet Spieler-Aufbau
# - Countert dominante Strategie
# - Reagiert auf Aggression
```

#### 5.2 AI Controller V2
```gdscript
# Refactor: scripts/ai_controller.gd

class_name AIControllerV2

# Strategie-Phasen:
# 1. Early (0-5 min): Economy, Basic Defense
# 2. Mid (5-15 min): Tech, Harassment
# 3. Late (15+ min): Full Assault, Boss

# Entscheidungs-Logik:
# - Scanne: Was hat der Spieler?
# - Evaluiere: Welche Strategie ist effektiv?
# - Executiere: Baue Türme, sende Wellen
# - Adapte: Reagiere auf Verluste
```

#### 5.3 Koordination (Multi-Enemy)
```gdscript
# scripts/ai_coordinator.gd

class_name AICoordinator

# Koordiniert mehrere KI-Gegner:
# - Zeitversetzte Angriffe (nicht gleichzeitig)
# - Unterschiedliche Strategien (einer rush, einer tech)
# - Hilfe bei Bedarf (einer verteidigt, einer greift an)
```

### Deliverables
- [ ] `scripts/wave_manager.gd` mit Wave-System
- [ ] `scripts/ai_controller.gd` refactored
- [ ] `scripts/ai_coordinator.gd` für Multi-KI
- [ ] 20+ vordefinierte Wave-Konfigurationen

### Akzeptanzkriterien
- [ ] KI fühlt sich "intelligent" an
- [ ] Wellen haben erkennbare Muster
- [ ] Unterschiedliche Gegner verhalten sich unterschiedlich
- [ ] Schwierigkeitsgrade machen merklichen Unterschied

---

## PHASE 6: Polishing & Build (Woche 7-8)

### Ziel
Fertiges Spiel-Paket mit Audio, Polishing und Release-Build.

### Technische Aufgaben

#### 6.1 Audio
```
Audio-Kategorien:
├── SFX
│   ├── Unit: Spawn, Move, Attack, Die
│   ├── Tower: Build, Upgrade, Fire
│   ├── UI: Click, Hover, Error, Success
│   └── Ambient: Map-Atmosphäre
├── Music
│   ├── Menu-Theme
│   ├── Gameplay-Theme (Layered)
│   └── Victory/Defeat-Stinger
└── Voice
    └── Optional: Unit-Responses, Announcements
```

#### 6.2 UI Polishing
```
Verbesserungen:
├── Hauptmenü
│   ├── Animierter Hintergrund
│   ├── Hover-Effekte
│   └── Settings-Panel
├── In-Game
│   ├── Health-Bar-Animationen
│   ├── Damage-Numbers (floating)
│   └── Minimap
└── Feedback
    ├── Screen-Shake bei großen Treffern
    ├── Slow-Mo bei kritischen Momenten
    └── Victory/Defeat-Sequenz
```

#### 6.3 Performance-Optimierung
```
Optimierungen:
├── Rendering
│   ├── LOD für Einheiten (entfernt = niedriger)
│   ├── Object Pooling für Projectiles
│   └── Frustum Culling
├── Logic
│   ├── Pathfinding: Nur alle X Frames
│   ├── Targeting: Nur bei Bewegung
│   └── Physics: Layer-Optimierung
└── Memory
    ├── Texture-Compression
    ├── Mesh-Instancing
    └── Object-Pooling
```

#### 6.4 Build-Setup
```
Export-Targets:
├── Windows (x64)
├── Linux (x64)
├── macOS (Universal)
└── Web (optional)

Build-Versionen:
├── Demo (1-2 Karten, begrenzte Units)
├── Standard (Full Game)
└── Deluxe (Extra Skins, Soundtrack)
```

### Deliverables
- [ ] Vollständiger Sound-Set
- [ ] Polished UI mit Animationen
- [ ] Performance: 60 FPS bei 100+ Einheiten
- [ ] Export für alle Ziel-Plattformen
- [ ] Steam-Seite (optional)

### Akzeptanzkriterien
- [ ] Keine bekannten Bugs
- [ ] Audio ist immersiv
- [ ] UI ist intuitiv
- [ ] Build läuft auf Ziel-Hardware

---

## ZEITPLAN ZUSAMMENFASSUNG

```
Woche 1:  ████████░░░░░░░░░░░░  Phase 1: Map
Woche 2:  ░░████████░░░░░░░░░░  Phase 2: Towers (Start)
Woche 3:  ░░░░████████░░░░░░░░  Phase 2: Towers (End) + Phase 3: Units (Start)
Woche 4:  ░░░░░░████████░░░░░░  Phase 3: Units (End)
Woche 5:  ░░░░░░░░████████░░░░  Phase 4: Economy
Woche 6:  ░░░░░░░░░░████████░░  Phase 5: AI
Woche 7:  ░░░░░░░░░░░░████████  Phase 6: Polish (Start)
Woche 8:  ░░░░░░░░░░░░░░██████  Phase 6: Polish (End) + Release
```

---

## RISIKEN & MITIGATION

| Risiko | Wahrscheinlichkeit | Impact | Mitigation |
|--------|-------------------|--------|------------|
| Asset-Erstellung dauert länger | Hoch | Hoch | Placeholder-Assets für Early-Testing |
| Balancing komplex | Mittel | Hoch | Automatisierte Tests, Parameter-Tuning |
| Performance-Probleme | Mittel | Hoch | Früh profilen, LOD-System |
| Scope Creep | Hoch | Mittel | Strikte Phase-Gates, MVP-Mindset |
| KI zu vorhersehbar | Mittel | Mittel | Randomisierung, mehrere Strategien |

---

## NÄCHSTE SCHRITTE

1. **Diesen Plan reviewen** mit Stakeholdern
2. **Asset-Pipeline** einrichten (Blender → Godot)
3. **Phase 1 starten** mit Map-Redesign
4. **GitHub Issues** erstellen für jede Phase (separates Dokument)

---

*Generated: 2026-05-02*  
*Version: 1.0*

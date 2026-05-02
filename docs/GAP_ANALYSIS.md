# Citadel Clash - Gap Analysis

**Datum:** 2026-05-02  
**Autor:** Echelon (AI-Assistent)  
**Version:** v0.1.0 → v0.2.0 (Major Revision)

---

## Zusammenfassung

Eine detaillierte Analyse des aktuellen Stands versus der Zielvision für Citadel Clash. Das Spiel hat solide Grundlagen, aber es fehlt signifikant an Content und Design-Tiefe für die angestrebte 20-30 Minuten Spielerfahrung.

---

## AKTUELLER STAND

### Was Existiert

#### 1. Core Systems (✅ Basis vorhanden)
- **GameManager:** Autoload-Singleton mit Gold-System, Team-Management, Game-State
- **Economy:** Passives Income (3/sec, wächst um 15%/min), Startgold 80
- **Combat:** Schadenssystem, HP-Balken, Tod/Respawn-Logik
- **Camera:** WASD-Bewegung, Zoom, Orthogonal-Projektion

#### 2. Türme (⚠️ Nur 1 Typ - Placeholder)
| Aspekt | Status | Details |
|--------|--------|---------|
| Tower-Entitäten | ✅ | `tower.tscn` existiert |
| Anzahl Typen | ❌ | Nur 1 generischer Typ |
| Visuelle Assets | ⚠️ | CSG-Primitive (BoxMesh, Cylinder) |
| Upgrades | ❌ | Kein System implementiert |
| Spezialisierungen | ❌ | Keine Unterschiede zwischen Türmen |

**Tower-Stats aktuell:**
- Range: 10.0
- Damage: 25.0
- Fire Rate: 1.2/sec
- Projectile Speed: 20.0

#### 3. Einheiten (⚠️ Nur 3 Typen - Unzureichend)
| Einheit | Status | HP | Speed | Damage | Besonderheit |
|---------|--------|-----|-------|--------|--------------|
| Basic | ✅ | 80 | 4.0 | 12 | Standard |
| Fast | ✅ | 50 | 7.0 | 8 | Schnell, schwach |
| Tank | ✅ | 250 | 2.0 | 35 | Langsam, stark |

**Fehlend:**
- Resistenz-/Schwäche-System
- Spezialfähigkeiten
- Eigene visuelle Assets (nur CSG-Primitives)
- Pathfinding mit Hindernisvermeidung

#### 4. Map-Layout (❌ Nicht der Vision entsprechend)
**Aktuell:**
- 100x100 flaches Terrain
- 3 Basen im Dreieck angeordnet
- 3 einfache "Lanes" (Zylinder) zwischen Basen
- Keine zentraler Spawn-Punkt
- Keine definierten Bauzonen

**Koordinaten aktuell:**
- PlayerBase: (-35, 1.5, -20)
- EnemyBase1: (35, 1.5, -20)
- EnemyBase2: (0, 1.5, 40)

#### 5. Economy-System (⚠️ Basic)
**Existiert:**
- Passives Gold-Income
- Einheitenkosten: Basic(15), Fast(20), Tank(40)
- Tower-Kosten: 60

**Fehlt:**
- Ressourcen-Entscheidungen (nur Gold)
- Tech-Tree/Progression
- Income-Quellen variieren
- Kosten-Nutzen-Tradeoffs

#### 6. KI-Gegner (⚠️ Basic AI)
**Implementiert:**
- 3 Schwierigkeitsgrade (Easy/Normal/Hard)
- Zeitbasiertes Spawnen
- Türme-Platzierung basierend auf Distanz
- "Defense Mode" wenn Basis angegriffen

**Fehlt:**
- Strategische Wellenplanung
- Koordinierte Angriffe
- Adaptive Strategie
- Einheiten-Mix basierend auf Spieler-Aufbau

#### 7. Assets (❌ Fast keine eigenen Assets)
**Zählen:**
- 29 Godot-Dateien (.tscn, .gd)
- 1 echtes Asset (icon.svg)
- Rest: CSG-Primitive (prozedural generiert)

**Asset-Liste:**
```
entities/basic_unit_csg.tscn      - CSG-Primitive
entities/tank_unit_csg.tscn       - CSG-Primitive
entities/fast_unit_csg.tscn       - CSG-Primitive
entities/tower_basic_csg.tscn     - CSG-Primitive
entities/citadel_fortress_csg.tscn - CSG-Primitive
entities/environment_rock_csg.tscn - CSG-Primitive
entities/environment_tree_csg.tscn - CSG-Primitive
```

---

## ZIELVISION

### Map-Design
- **Zentraler Spawn:** Alle Einheiten spawnen zentral
- **Verbindungspfade:** 3+ Pfade zu den Burgen
- **Bauzonen:** Nur entlang der Pfade bebaubar
- **Strategische Positionen:** Engstellen, Hochgebiete

### Türme (10+ verschiedene)
| Turm | Rolle | Besonderheit |
|------|-------|--------------|
| 1. Archer Tower | Basic DPS | Schnell, geringer Schaden |
| 2. Cannon Tower | Splash | Langsam, Bereichsschaden |
| 3. Mage Tower | Magic | Ignoriert Rüstung |
| 4. Ballista | Sniper | Sehr langsam, extrem hoher Schaden |
| 5. Frost Tower | CC | Verlangsamt Gegner |
| 6. Tesla Tower | Chain | Kettenblitze |
| 7. Poison Tower | DoT | Gift über Zeit |
| 8. Barracks | Spawner | Produziert eigene Einheiten |
| 9. Shield Tower | Support | Bufft nahe Türme |
| 10. Ultimate | Late Game | Hohe Kosten, massiver Impact |

### Einheiten (8+ verschiedene)
| Einheit | Klasse | Resistenzen | Schwächen |
|---------|--------|-------------|-----------|
| 1. Infantry | Light | - | Magic |
| 2. Cavalry | Fast | Light | Pierce |
| 3. Knight | Heavy | Pierce | Magic |
| 4. Siege | Structure | Splash | Fast |
| 5. Mage | Magic | Heavy | Physical |
| 6. Assassin | Stealth | - | Area |
| 7. Healer | Support | - | All |
| 8. Boss | Elite | Most | None |

### Economy
- Mehrere Ressourcen oder komplexeres Gold-System
- Tech-Tree mit Entscheidungen
- Income aus verschiedenen Quellen
- Tradeoffs zwischen Defense und Economy

### Spieltiefe
- **Early Game (0-5 min):** Economy-Aufbau, erste Türme
- **Mid Game (5-15 min):** Tech-Entscheidungen, Angriffe
- **Late Game (15-25 min):** Ultimate-Türme, Boss-Wellen
- **Endgame (25-30 min):** Finale Wellen, Sieg/Niederlage

---

## GAP ÜBERSICHT

| Bereich | Existiert | Ziel | Gap | Priorität |
|---------|-----------|------|-----|-----------|
| **Türme** | 1 | 10+ | 9+ | 🔴 KRITISCH |
| **Einheiten** | 3 | 8+ | 5+ | 🔴 KRITISCH |
| **Map** | Basic | Zentraler Spawn | Komplett neu | 🔴 KRITISCH |
| **Assets** | CSG-Only | Eigene Assets | 20+ Assets | 🟡 HOCH |
| **Economy** | Basic Gold | Komplex | Erweitern | 🟡 HOCH |
| **KI** | Zeitbasiert | Strategisch | Verbessern | 🟡 HOCH |
| **UI** | Funktional | Polished | Überarbeiten | 🟢 MEDIUM |
| **Audio** | Keins | Full SFX | Alles | 🟢 MEDIUM |
| **Tutorial** | Keins | Integriert | Alles | 🟢 MEDIUM |

---

## QUANTIFIZIERTE GAPS

### Code/Content
```
Skripte:           11 GDScript-Dateien (aktuell)
                   → ~25+ für Zielvision

Szenen:            12 .tscn Dateien (aktuell)
                   → ~35+ für Zielvision

Assets benötigt:
- Tower Assets:    10 Modelle + Texturen
- Unit Assets:     8 Modelle + Animationen
- Map Assets:      5+ Umgebungsmodelle
- UI Assets:       Icon-Set, Fonts
- FX Assets:       Partikel, Effekte
                   ─────────────────────
Total:             ~30+ neue Assets
```

### Gameplay-Tiefe
```
Spielzeit aktuell:  5-10 Minuten
Spielzeit Ziel:    20-30 Minuten
Gap:               2-3x Verlängerung nötig

Strategie aktuell: Einheiten spam, Türme bauen
Strategie Ziel:    Tech-Tree, Counter-Play, Wellen-Timing
Gap:               Komplett neues Design nötig
```

---

## RISIKEN & HERAUSFORDERUNGEN

1. **Asset-Erstellung:** 30+ 3D-Assets sind zeitintensiv
2. **Balancing:** 10 Türme × 8 Einheiten = komplexe Matrix
3. **KI-Design:** Strategische KI erfordert viel Iteration
4. **Scope Creep:** Gefahr, das Projekt zu überladen
5. **Performance:** Mehr Einheiten/Türme = Optimierung nötig

---

## EMPFEHLUNG

Die Lücke zwischen aktuellem Stand und Zielvision ist **signifikant**. Eine komplette Überarbeitung ist sinnvoll, sollte aber in **phasenweise** angegangen werden, um Fortschritt sichtbar zu halten und früh testen zu können.

Siehe `REVISION_PLAN.md` für detaillierten Umsetzungsplan.

---

*Generated: 2026-05-02*

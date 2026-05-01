# Third-Party Assets & Lizenzen

Dieses Dokument listet alle externen Assets, Software und Bibliotheken, die in Citadel Clash verwendet werden.

---

## Game Engine

### Godot Engine 4.4
- **Lizenz:** MIT License
- **Quelle:** https://godotengine.org/
- **Repository:** https://github.com/godotengine/godot
- **Copyright:** 2007-2026 Juan Linietsky, Ariel Manzur, Godot Engine contributors

**Verwendung:** Primäre Game Engine für Entwicklung und Export.

---

## Godot Plugins/Addons

### GodotSteam (optional, falls verwendet)
- **Lizenz:** MIT License
- **Quelle:** https://github.com/Gramps/GodotSteam
- **Copyright:** Gramble/Greenworks

**Verwendung:** Steamworks-Integration für Multiplayer, Achievements, Cloud Saves.

---

## Software Tools

### Entwicklungs-Tools
| Tool | Version | Lizenz | Verwendung |
|------|---------|--------|------------|
| Git | 2.x | GPL-2.0+ | Versionskontrolle |
| VS Code | - | MIT | Code Editor |
| Blender | 4.x | GPL-2.0+ | 3D Modeling |
| GIMP | 2.x | GPL-3.0+ | Texturen/Icons |

---

## Audio Assets

### Musik
| Track | Artist | Lizenz | Quelle |
|-------|--------|--------|--------|
| [Name] | [Artist] | [Lizenz] | [URL] |

### Sound Effects
| SFX | Pack/Quelle | Lizenz | Quelle |
|-----|-------------|--------|--------|
| [Name] | [Source] | [Lizenz] | [URL] |

---

## Visual Assets

### 3D Models
| Modell | Creator | Lizenz | Quelle |
|--------|---------|--------|--------|
| [Name] | [Creator] | [Lizenz] | [URL] |

### Texturen
| Textur | Pack/Quelle | Lizenz | Quelle |
|--------|-------------|--------|--------|
| [Name] | [Source] | [Lizenz] | [URL] |

### Fonts
| Font | Designer | Lizenz | Quelle |
|------|----------|--------|--------|
| [Name] | [Designer] | [Lizenz] | [URL] |

### UI Elements
| Element | Quelle | Lizenz | Quelle |
|---------|--------|--------|--------|
| [Name] | [Source] | [Lizenz] | [URL] |

---

## Code & Bibliotheken

### Godot-native
Godot Engine enthält verschiedene Third-Party Bibliotheken:
- **ENet:** UDP Networking Library (MIT License)
- **mbed TLS:** TLS/SSL Library (Apache License 2.0)
- **FreeType:** Font Rendering (FreeType License)
- **libpng:** PNG Image Format (libpng License)

Siehe Godot-Dokumentation für vollständige Liste:  
https://github.com/godotengine/godot/blob/master/COPYRIGHT.txt

### Zusätzliche Bibliotheken (falls verwendet)
| Bibliothek | Lizenz | Verwendung |
|------------|--------|------------|
| [Name] | [Lizenz] | [Zweck] |

---

## Asset Store Inhalte

### Godot Asset Store
| Asset | Author | Version | Lizenz |
|-------|--------|---------|--------|
| [Name] | [Author] | [Version] | [Lizenz] |

### Unity Asset Store (falls konvertiert)
| Asset | Author | Lizenz |
|-------|--------|--------|
| [Name] | [Author] | [Lizenz] |

### itch.io Assets
| Asset | Creator | Lizenz |
|-------|---------|--------|
| [Name] | [Creator] | [Lizenz] |

---

## Lizenz-Zusammenfassung

### MIT License
Erlaubt freie Nutzung, Modifikation und Distribution mit Attribution.

### GPL License
Erfordert, dass abgeleitete Werke ebenfalls unter GPL lizenziert werden.

### CC0 / Public Domain
Keine Einschränkungen, freie Nutzung.

### CC-BY
Namensnennung erforderlich.

### CC-BY-SA
Namensnennung + ShareAlike (abgeleitete Werke unter gleicher Lizenz).

### Proprietär
Individuelle Lizenzbedingungen, oft Einkauf erforderlich.

---

## Compliance-Checkliste

Vor Release prüfen:

- [ ] Alle Assets haben dokumentierte Lizenz
- [ ] Attribution korrekt in Credits
- [ ] ShareAlike-Assets identifiziert
- [ ] Kommerzielle Nutzung erlaubt
- [ ] Lizenz-Dateien im Build enthalten (wenn gefordert)

---

## Updates

**Letzte Überprüfung:** 2026-05-02

Bei Hinzufügen neuer Assets:
1. Asset in Tabelle eintragen
2. Lizenz prüfen und dokumentieren
3. Attribution aktualisieren
4. Compliance-Checkliste durchführen

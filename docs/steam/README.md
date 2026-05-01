# Steam Preparation - Citadel Clash

Dieses Verzeichnis enthält alle Materialien und Dokumentation für den Steam-Release von Citadel Clash.

## 📁 Verzeichnisstruktur

```
docs/steam/
├── README.md                    # Diese Datei
├── store_page_content.md        # Store Page Texte (DE/EN)
├── visual_assets_concepts.md    # Asset-Spezifikationen
├── trailer_concept.md           # 60s Trailer Storyboard
├── legal/                       # Rechtliche Dokumente
│   ├── LICENSE.md              # Spiel-Lizenz + Godot MIT
│   ├── CREDITS.md              # Credits-Datei
│   └── THIRDPARTY.md           # Third-Party Assets
└── assets/                      # Asset-Konzepte
    ├── GENERATED_ASSETS.md     # Übersicht generierter Bilder
    └── generated/               # KI-generierte Konzeptbilder
        ├── 01_capsule_main_concept_460x215.png
        ├── 02_screenshot_building_concept.png
        ├── 03_library_capsule_concept_600x900.png
        └── 04_screenshot_siege_weapons.png
```

## 📋 Hauptdokumente

### 1. Store Page Content (`store_page_content.md`)
- Kurzbeschreibung (150 Zeichen)
- Langbeschreibung (DE/EN)
- 6 Key Features (DE/EN)
- Systemanforderungen (Minimal/Empfohlen)
- Steam Tags & SEO Keywords

### 2. Visual Assets (`visual_assets_concepts.md`)
- Main Capsule (460x215) Spezifikation
- Library Capsule (600x900) Spezifikation
- Small Capsule (231x87) Spezifikation
- Screenshot-Konzepte (6 Stück)
- Asset-Erstellungs-Workflow

### 3. Trailer Konzept (`trailer_concept.md`)
- 60-Sekunden Storyboard (Akt für Akt)
- Musik-Vorschläge
- Sound-Design Pflichtmomente
- Technische Spezifikationen

### 4. STEAM_CHECKLIST.md (im docs/ Ordner)
- Vollständige Launch-Checkliste
- Phasen: Setup → Assets → Build → Legal → Marketing → Launch
- Timeline-Schätzung (10 Wochen)
- Marketing-Texte für Discord/Reddit

### 5. Legal Docs (`legal/`)
- LICENSE.md: Godot MIT Lizenz + Spiel-Lizenz
- CREDITS.md: Team und Danksagungen
- THIRDPARTY.md: Asset-Lizenzen Übersicht

## 🖼️ Generierte Konzeptbilder

Im `assets/generated/` Verzeichnis befinden sich KI-generierte Konzeptbilder als Referenz für die finale Asset-Erstellung:

1. **Main Capsule** - Belagerungsszene mit Festung
2. **Screenshot Building** - Base-Building Gameplay
3. **Library Capsule** - Monumentale Festung Portrait
4. **Screenshot Siege** - Nächtliche Belagerung

## ⚠️ Wichtige Hinweise

### Vor Steam-Upload prüfen:
- [ ] Alle Texte finalisiert und Korrektur gelesen
- [ ] Screenshots aus echtem Spiel erstellen
- [ ] Capsules professionell designen
- [ ] Trailer produzieren/fertigstellen
- [ ] Rechtsberatung bei Lizenzfragen

### Steamworks:
- App ID bei Steam registrieren
- Steamworks SDK integrieren (GodotSteam empfohlen)
- Build-Pipeline einrichten

## 📅 Timeline Schätzung

Von Steamworks-Account bis Launch: **~10 Wochen**

1. **Woche 1-2:** Steamworks Setup, Account-Erstellung
2. **Woche 3-4:** Asset-Erstellung, Store Page Content
3. **Woche 5-6:** Trailer-Produktion, Build-Integration
4. **Woche 7-8:** Beta-Testing, Feinschliff
5. **Woche 9:** Marketing-Vorbereitung
6. **Woche 10:** LAUNCH

## 🔗 Externe Ressourcen

- **Steamworks:** https://partner.steamgames.com/
- **GodotSteam:** https://github.com/Gramps/GodotSteam
- **Steam Asset Guidelines:** https://partner.steamgames.com/doc/store/assets

---

**Erstellt:** 2026-05-02  
**Status:** 🚧 Dokumentation fertig, Assets in Entwicklung

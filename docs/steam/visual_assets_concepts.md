# Citadel Clash - Visual Assets Concepts

## Übersicht Steam Asset Anforderungen

| Asset | Abmessungen | Format | Zweck |
|-------|-------------|--------|-------|
| **Main Capsule** | 460x215px | JPG/PNG | Hauptbanner auf Store Page |
| **Library Capsule** | 600x900px (2:3) | JPG/PNG | Steam Library Grid View |
| **Small Capsule** | 231x87px | JPG/PNG | Empfohlen-Listen, Discovery Queue |
| **Header** | 1920x620px | JPG/PNG | Store Page Header (optional) |
| **Screenshots** | 1920x1080px | JPG/PNG | Store Page Gallery (min. 5) |
| **Background** | 1920x1080px | JPG/PNG | Store Page Hintergrund |

---

## 1. Main Capsule (460x215px)

### Layout-Konzept
```
┌─────────────────────────────────────────────────────────┐
│  ┌─────────┐                              [LOGO]       │
│  │  Stone  │                                            │
│  │ Fortress│     [Belagerungsszene]                   │
│  │  3D     │        Feuer, Rauch, Action              │
│  └─────────┘                                            │
│  LINKS:          ZENTRUM:             RECHTS:           │
│  Massive        Mittelalterliche      "Citadel Clash"   │
│  Festung        Schlacht              Logo + Subtitle   │
│  (Dramatic      (Dynamisch,          "Base Defense     │
│  Lighting)      Bewegung)             Strategy"        │
└─────────────────────────────────────────────────────────┘
```

### Farbpalette
- **Primary:** Dunkles Steingrau (#2C2C2C) + Goldakzente (#D4AF37)
- **Secondary:** Feuer-Orange (#FF6B35) für Action-Elemente
- **Atmosphere:** Bläulicher Dämmerungsverlauf (#1A1A2E → #16213E)

### Key Elements
- **Zentrale Festung** (links platziert, 40% der Breite)
- **Belagerungsszene** (rechts mit dynamischen Elementen)
- **Logo** oben rechts, gut lesbar
- **Subtle particles** für Atmosphäre (Feuerfunken, Staub)
- **Kein UI-Text** (außer Logo)

### Mood
Episch, dramatisch, mittelalterliche Belagerung bei Dämmerung. Lodernde Feuer, rauchige Atmosphäre, massive Steinstrukturen.

---

## 2. Library Capsule (600x900px - Portrait)

### Layout-Konzept
```
┌─────────────────────────┐
│                         │
│    ┌───────────────┐    │
│    │   MASSIVE     │    │
│    │   CITADEL     │    │
│    │   [Burg in    │    │
│    │    Vollansicht│    │
│    │   dramatic    │    │
│    │   angle]      │    │
│    └───────────────┘    │
│                         │
│    ┌───────────────┐    │
│    │  CITADEL      │    │
│    │    CLASH      │    │
│    │  ─────────    │    │
│    │  Base Defense │    │
│    │  Strategy     │    │
│    └───────────────┘    │
│                         │
└─────────────────────────┘
```

### Design-Details
- **Fokus:** Eine einzelne, beeindruckende Festung im Zentrum
- **Kamera-Angle:** Leicht von unten für monumentale Wirkung
- **Hintergrund:** Dramatischer Himmel (Sonnenuntergang/Sturm)
- **Logo-Platzierung:** Unterer Bereich, deutlich vom Hintergrund abgehoben
- **Aspect Ratio:** Nutzt vertikalen Raum optimal

### Alternative Idee
Belagerungsturm, der auf eine Festung zufährt – vertikale Dynamik, Blick von unten nach oben.

---

## 3. Small Capsule (231x87px)

### Layout-Konzept
```
┌─────────────────────────────────────┐
│  ┌───┐                              │
│  │ 🏰│  CITADEL CLASH               │
│  └───┘                              │
│                                     │
│  [Stilisierter Turm]   [Kompakt]    │
│  [+ Logo-Text]       [Lesbar]      │
└─────────────────────────────────────┘
```

### Anforderungen
- **Extrem lesbar** bei kleiner Größe
- **Einfache Komposition** – weniger Details als Main Capsule
- **Icon-artiger Ansatz** – erkennbare Silhouette
- **Logo deutlich** – entweder Text oder stilisiertes Symbol

### Implementation
- Verkleinerte Version des Main Capsules
- Oder: Eigenständiges Design mit Fokus auf Logo
- Testen bei verschiedenen Skalierungen (Steam UI)

---

## 4. Store Page Screenshots (5-6 Stück)

### Screenshot 1: Hauptmenü / UI Showcase
**Konzept:** Poliertes Hauptmenü mit dramatischer Hintergrundszene
- Zeigt UI-Qualität und Stil
- „Citadel Clash" Logo prominent
- Game Mode Selection (Campaign, Skirmish, Multiplayer)
- Atmosphärische Beleuchtung

### Screenshot 2: Base Building / Construction
**Konzept:** Spieler platziert Gebäude, Bau-UI sichtbar
- Grid-System für Bauplatzierung
- Verschiedene Gebäudetypen (Wohnhäuser, Produktion, Verteidigung)
- Ressourcen-Overlay
- Tageslicht, klare Sicht

### Screenshot 3: Epic Battle / Combat
**Konzept:** Große Schlacht mit vielen Einheiten
- Belagerungsszene: Rammbock gegen Tor
- Bogenschützen auf Mauern
- Nahkampfeinheiten
- Partikeleffekte (Pfeile, Staub)
- Dramatische Kamera-Position

### Screenshot 4: Economy Management
**Konzept:** Ressourcen-UI und Wirtschaftssystem
- Ressourcen-Balken (Holz, Stein, Nahrung, Gold)
- Arbeiter bei der Arbeit (holzen, Stein brechen)
- Gebäude-Produktions-Queues
- Übersicht über die Basis

### Screenshot 5: Multiplayer / Multiple Bases
**Konzept:** Mehrere Spielerbases auf einer Karte
- Unterschiedliche Architektur-Stile
- Karte mit Fog of War
- Mini-Map sichtbar
- Team-Farben (Rot vs. Blau)

### Screenshot 6: Siege Weapons / Late Game
**Konzept:** Spätes Spiel mit fortgeschrittenen Belagerungswaffen
- Katapulte, Ballisten
- Explodierende Gebäude
- Massive Festungsmauern
- Nacht- oder Abendstimmung

### Screenshot-Technische Details
- **Auflösung:** 1920x1080 (16:9) oder 2560x1440
- **Format:** JPG (Qualität 90-95%) oder PNG
- **Kein UI in mindestens 1-2 Screenshots** für Immersion
- **Captions** für jeden Screenshot planen (mehrsprachig)

---

## 5. Store Page Hintergrund (Optional)

### Konzept
- **Stil:** Erweitertes Capsule-Artwork
- **Elemente:** Nebelige Landschaft, ferne Berge, Ruinen
- **Farben:** Dunkle, stimmungsvolle Töne
- **Fokus:** Kein visueller Konflikt mit Store-UI-Elementen
- **Parallax:** Unterstützt Steam's parallax scrolling

---

## Asset-Erstellungs-Workflow

### Phase 1: Konzept & Sketches
1. Moodboards sammeln (Stronghold, Age of Empires, andere RTS)
2. Schnelle Skizzen für alle Assets
3. Feedback-Runde mit Team

### Phase 2: 3D-Rendering (falls vorhandene Assets)
1. Szenen in Godot/Unreal/Blender aufbauen
2. Dramatische Kamera-Winkel
3. Beleuchtung optimieren
4. Screenshots bei 4K, dann Downsizen

### Phase 3: 2D-Polish
1. Photoshop/GIMP für Compositing
2. Farbkorrektur
3. Logo-Integration
4. Export in alle benötigten Formate

### Phase 4: Validierung
1. Test in Steam-ähnlichen Layouts
2. Lesbarkeit bei kleinen Größen
3. Kontrast-Check für Barrierefreiheit

---

## Quell-Dateien Verzeichnisstruktur

```
/docs/steam/assets/source/
├── capsules/
│   ├── main_capsule_460x215.psd/.xcf
│   ├── library_capsule_600x900.psd/.xcf
│   └── small_capsule_231x87.psd/.xcf
├── screenshots/
│   ├── screenshot_01_menu.psd/.xcf
│   ├── screenshot_02_building.psd/.xcf
│   ├── screenshot_03_combat.psd/.xcf
│   ├── screenshot_04_economy.psd/.xcf
│   ├── screenshot_05_multiplayer.psd/.xcf
│   └── screenshot_06_siege.psd/.xcf
└── backgrounds/
    └── store_background_1920x1080.psd/.xcf
```

---

## Tools & Ressourcen

### Empfohlene Software
- **3D Rendering:** Godot Engine (eigene Assets), Blender
- **2D Editing:** Photoshop, GIMP, Affinity Photo
- **Logo Design:** Illustrator, Inkscape, Figma

### Ressourcen
- Steamworks Dokumentation: https://partner.steamgames.com/doc/store/assets
- Steam Capsule Guidelines
- Aspect Ratio Calculator: https://andrew.hedges.name/experiments/aspect_ratio/

---

## Checkliste Asset-Erstellung

- [ ] Main Capsule 460x215 entworfen
- [ ] Library Capsule 600x900 entworfen  
- [ ] Small Capsule 231x87 entworfen
- [ ] Mindestens 5 Screenshots geplant
- [ ] Store Background konzipiert (optional)
- [ ] Alle Assets für 4K-Displays skalierbar
- [ ] Logo in allen Assets konsistent
- [ ] Farbpalette durchgehend
- [ ] Test bei verschiedenen Größen
- [ ] Final Export für Steam Upload bereit

# Citadel Clash - Steam Release Checklist

## Übersicht

Dieses Dokument enthält die vollständige Checkliste für den Steam-Release von Citadel Clash.

**Projekt:** Citadel Clash  
**Engine:** Godot 4.4  
**Geplanter Release:** TBA 2026  
**Release-Typ:** [ ] Early Access / [ ] Full Release (zu entscheiden)

---

## Phase 1: Steamworks Setup (VOR App-Config)

### Account & Legal
- [ ] Steamworks Developer Account erstellt
- [ ] $100 Steam Direct Fee bezahlt
- [ ] Bankkonto & Steuerinformationen hinterlegt
- [ ] EULA/TOS für Spiel erstellt
- [ ] Datenschutzerklärung (Privacy Policy)
- [ ] Impressum/Legal Notice

### App-Configuration
- [ ] Spiel in Steamworks registriert
- [ ] App ID erhalten
- [ ] Depot-Konfiguration erstellt
- [ ] Build-Branches eingerichtet:
  - [ ] `default` (Public)
  - [ ] `beta` (Testing)
  - [ ] `internal` (Dev-Only)

---

## Phase 2: Store Page Assets

### Pflicht-Assets (Steam)

| Asset | Abmessungen | Status | Dateiname |
|-------|-------------|--------|-----------|
| **Main Capsule** | 460x215px | [ ] Erstellt | `header_capsule.jpg` |
| **Small Capsule** | 231x87px | [ ] Erstellt | `small_capsule.jpg` |
| **Main Capsule Alt.** | 467x181px | [ ] Erstellt | `header_capsule_alt.jpg` |
| **Vertical Capsule** | 374x448px | [ ] Erstellt | `vertical_capsule.jpg` |
| **Page Background** | 1920x1080px | [ ] Erstellt | `page_bg.jpg` |
| **Library Hero** | 1920x620px | [ ] Erstellt | `library_hero.jpg` |
| **Library Capsule** | 600x900px | [ ] Erstellt | `library_capsule.jpg` |
| **Community Icon** | 184x184px | [ ] Erstellt | `community_icon.jpg` |

### Screenshots (Minimum 5, Maximum 15)

| # | Inhalt | Status | Dateiname |
|---|--------|--------|-----------|
| 1 | Hauptmenü / UI | [ ] | `screenshot_01.jpg` |
| 2 | Base Building | [ ] | `screenshot_02.jpg` |
| 3 | Combat / Battle | [ ] | `screenshot_03.jpg` |
| 4 | Economy / Management | [ ] | `screenshot_04.jpg` |
| 5 | Multiplayer | [ ] | `screenshot_05.jpg` |
| 6 | Siege Weapons | [ ] | `screenshot_06.jpg` |
| 7 | [Optional] | [ ] | `screenshot_07.jpg` |
| 8 | [Optional] | [ ] | `screenshot_08.jpg` |

### Trailer & Video

- [ ] 60-Second Trailer erstellt (siehe `trailer_concept.md`)
- [ ] Trailer in 1080p gerendert
- [ ] Trailer in 4K gerendert (optional)
- [ ] YouTube-Version erstellt
- [ ] Thumbnail für Trailer (1280x720)

### Store Page Content

- [ ] Spiel-Name finalisiert: **Citadel Clash**
- [ ] Kurzbeschreibung (150 Zeichen)
- [ ] Langbeschreibung (siehe `store_page_content.md`)
- [ ] 5-6 Key Features
- [ ] Systemanforderungen (Minimal)
- [ ] Systemanforderungen (Empfohlen)
- [ ] Steam-Tags ausgewählt
- [ ] Genre klassifiziert
- [ ] Controller-Support dokumentiert

---

## Phase 3: Build & Distribution

### Godot Export

- [ ] Export Presets konfiguriert:
  - [ ] Windows (x86_64)
  - [ ] Linux (x86_64)
  - [ ] macOS (Universal)
- [ ] Debug-Symbole separat gespeichert
- [ ] Version in `project.godot` aktualisiert
- [ ] Icon für Executable eingebettet

### Steamworks Integration

- [ ] Steamworks SDK integriert (Godot-Steam oder ähnlich)
- [ ] Steam App ID konfiguriert
- [ ] Steam-Overlay funktioniert
- [ ] Steam-Input konfiguriert (falls Controller-Support)
- [ ] Steam Cloud Save konfiguriert
- [ ] Steam Achievements definiert
- [ ] Steam Leaderboards (optional)
- [ ] Steam Multiplayer Lobby-System

### Build Pipeline

- [ ] Automatisiertes Build-Script
- [ ] CI/CD Pipeline (GitHub Actions/GitLab CI)
- [ ] Build-Upload zu Steam (SteamCMD)
- [ ] Beta-Branch für interne Tests

---

## Phase 4: Rechtliches & Credits

### Lizenzen (siehe `legal/`)

- [ ] Godot MIT-Lizenz-Hinweis
- [ ] Drittanbieter-Assets dokumentiert
- [ ] Font-Lizenzen
- [ ] Music/Sound-Lizenzen
- [ ] Eigene Lizenz festgelegt

### Credits-Datei

- [ ] `CREDITS.txt` erstellt
- [ ] Alle Contributors gelistet
- [ ] Drittanbieter-Tools gelistet
- [ ] Öffnen im Spiel implementiert

### Rechtliche Dokumente

- [ ] `PRIVACY_POLICY.md`
- [ ] `TERMS_OF_SERVICE.md`
- [ ] Impressum in Spiel integriert

---

## Phase 5: Marketing-Vorbereitung

### Discord

- [ ] Server eingerichtet
- [ ] #announcements Kanal
- [ ] #feedback Kanal
- [ ] Community-Rollen definiert
- [ ] Marketing-Texte geschrieben (siehe unten)

### Reddit

- [ ] Account für Entwickler erstellt
- [ ] Subreddit-Recherche:
  - [ ] r/RealTimeStrategy
  - [ ] r/BaseBuildingGames
  - [ ] r/IndieDev
  - [ ] r/IndieGaming
  - [ ] r/Steam
  - [ ] r/Godot
- [ ] Launch-Posts vorbereitet

### Social Media

- [ ] Twitter/X Account
- [ ] YouTube Kanal
- [ ] TikTok (optional)
- [ ] Instagram (optional)
- [ ] Bluesky (optional)

### Presse & Influencer

- [ ] Pressekit erstellt (Screenshots, Trailer, Beschreibung)
- [ ] Influencer-Liste (RTS-YouTuber/Streamer)
- [ ] Review-Keys generierbar

---

## Phase 6: Launch-Vorbereitung

### Pre-Launch

- [ ] Steam-Seite im "Coming Soon"-Modus
- [ ] Wishlist-Tracking aktiviert
- [ ] Beta-Tester rekrutiert
- [ ] Launch-Datum festgelegt

### Launch-Tag

- [ ] Finaler Build hochgeladen
- [ ] Store Page veröffentlicht
- [ ] Launch-Trailer live
- [ ] Social-Posts geplant
- [ ] Discord-Ankündigung
- [ ] Reddit-Posts veröffentlicht

### Post-Launch

- [ ] Bug-Tracking aktiv
- [ ] Community-Feedback sammeln
- [ ] Schneller Patch 1.1 geplant
- [ ] Roadmap kommuniziert

---

## Release-Timeline Schätzung

| Phase | Aufwand | Zeitraum | Milestone |
|-------|---------|----------|-------------|
| Steamworks Setup | 1-2 Tage | Woche 1 | Account ready |
| Asset Creation | 2-3 Wochen | Woche 1-3 | Alle Assets fertig |
| Store Page Build | 3-5 Tage | Woche 3-4 | Page live |
| Build Integration | 1-2 Wochen | Woche 4-5 | Steamworks SDK |
| Beta Testing | 2-3 Wochen | Woche 6-8 | Beta-Branch |
| Launch Prep | 1 Woche | Woche 9 | Marketing ready |
| **LAUNCH** | - | **Woche 10** | **Go Live** |

**Gesamtschätzung:** 10 Wochen ab Steamworks-Account-Erstellung

---

## Marketing-Texte für Discord/Reddit

### Discord-Ankündigung (Short)

```
🏰 **Citadel Clash - Now on Steam!**

Build. Defend. Conquer.

Unser 3D Base-Defense RTS ist jetzt auf Steam verfügbar!
- Belagerungen mit bis zu 8 Spielern
- Classic Stronghold-Style Gameplay
- Kostenloses Demo verfügbar

**[Steam-Link]**
**[Trailer]**

#indiegame #rts #basebuilding
```

### Reddit-Post Template (r/RealTimeStrategy)

```
**Citadel Clash - A 3D Base-Defense RTS inspired by Stronghold**

Hey r/RealTimeStrategy!

Wir sind ein kleines Indie-Team und haben Citadel Clash entwickelt – 
ein Echtzeit-Strategiespiel mit Fokus auf Festungsbau und Belagerungen.

**Was erwartet euch:**
- Base Building mit komplexer Wirtschaft
- Vertikales Gameplay (Mauern, Türme)
- Multiplayer für bis zu 8 Spieler
- Solo-Kampagne + Skirmish

**Steam:** [Link]
**Trailer:** [YouTube]

Fragen? AMA!
```

### Twitter/X Launch Post

```
🏰 IT'S HERE! 🏰

Citadel Clash is NOW AVAILABLE on Steam!

⚔️ Build massive fortresses
🛡️ Defend against epic sieges  
👥 Battle up to 7 friends

Wishlist: [Link]
Trailer: 🎬 [Link]

#IndieGame #RTS #Steam #GameLaunch
```

---

## Checkliste: Pre-Flight Final

- [ ] Alle Store-Assets hochgeladen
- [ ] Build auf allen Plattformen getestet
- [ ] Steam-Overlay funktioniert
- [ ] Achievements funktionieren
- [ ] Cloud Save getestet
- [ ] Multiplayer getestet
- [ ] Rechtliche Dokumente verlinkt
- [ ] Credits sichtbar
- [ ] Keine Platzhalter-Texte mehr
- [ ] Preis festgelegt
- [ ] Regionale Preise geprüft
- [ ] Launch-Rabatt definiert
- [ ] Team bereit für Launch-Day

---

## Nach Launch

### Tag 1
- [ ] Store-Performance überwachen
- [ ] Erste Reviews antworten
- [ ] Kritische Bugs priorisieren
- [ ] Community-Feedback sammeln

### Woche 1
- [ ] Hotfix released (falls nötig)
- [ ] Launch-Zahlen analysieren
- [ ] Marketing-Performance reviewen

### Monat 1
- [ ] Erster Content-Update geplant
- [ ] Community-Events geplant
- [ ] Roadmap kommuniziert

---

**Letzte Aktualisierung:** 2026-05-02  
**Verantwortlich:** [Name]  
**Status:** 🚧 IN ARBEIT

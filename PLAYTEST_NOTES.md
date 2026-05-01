# Citadel Clash - Playtest Notes
## Vertical Slice Gameplay Polishing

### Completed Changes

#### 1. **Balancing**

| Element | Old Value | New Value | Reason |
|---------|-----------|-----------|--------|
| Base HP | 1000 | 500 | Faster matches (5-10 min target) |
| Starting Gold | 100 | 80 | More tactical early game |
| Base Income | 5/sec | 3/sec | Slower economy growth |
| Income Growth | Flat | +15%/min | Escalation as game progresses |

**Unit Costs:**
- Basic Unit: 10 → 15 gold
- Fast Unit: 15 → 20 gold  
- Tank Unit: 25 → 40 gold
- Tower: 50 → 60 gold

**Unit Stats Rebalanced:**
| Type | HP | Speed | Damage | Attack Rate |
|------|-----|-------|--------|-------------|
| Basic | 100→80 | 3.0→4.0 | 10→12 | 1.0→1.5/s |
| Fast | 60→50 | 6.0→7.0 | 7→8 | 1.5→2.0/s |
| Tank | 300→250 | 1.5→2.0 | 25→35 | 0.5→0.6/s |

#### 2. **AI Improvements**

**Difficulty Levels Implemented:**
- **Easy**: Spawn every 6s, build every 20s, 40% randomness, 70% basic units, 20% income
- **Normal**: Spawn every 4s, build every 12s, 25% randomness, 50/35/15 unit mix
- **Hard**: Spawn every 2.5s, build every 8s, 15% randomness, 30% tanks, 130% income

**Tactical Improvements:**
- AI now tracks base health and enters "defense mode" when under attack
- Towers placed tactically between base and enemies when threatened
- Tower placement uses scoring system based on:
  - Distance to base (closer = better)
  - Distance to enemies (closer = better)
  - Avoidance of clustering with other towers
- Units spawn towards enemies when base is under attack

#### 3. **QoL Features**

**Camera Controls:**
- WASD movement with smooth interpolation
- Mouse wheel zoom (20-100 range)
- Keyboard zoom (][ keys as backup)
- Camera bounds to keep in game area

**Unit/Tower Selection:**
- Click to select units or towers
- Yellow selection ring appears
- Entity info panel shows stats
- Click empty space to deselect

**Build Mode Improvements:**
- Visual preview of tower placement
- Range indicator shows tower coverage
- Red/Green color indicates valid/invalid placement
- Right-click or Esc to cancel build
- Message feedback for insufficient gold

#### 4. **Bug Fixes**

**Fixed Issues:**
- Fixed duplicate `parent="."` entries in scene file
- Fixed deprecated signal connection syntax
- Fixed camera zoom for orthogonal projection
- Fixed HP bar label reference in game_ui.gd
- Fixed unit selection signal connections

**Potential Issues Found:**
- Unit pathfinding is direct-line only (no obstacle avoidance)
- No maximum unit cap (could cause performance issues in long games)
- Tower projectiles use hitscan (instant damage) - may need proper projectile physics
- No unit-on-unit collision (units stack on top of each other)

### Testing Recommendations

1. **Playtest Match Duration**: Verify matches complete in 5-10 minutes
2. **AI Difficulty**: Test all three difficulty levels
3. **Late Game Performance**: Monitor FPS with 50+ units on screen
4. **Economy Balance**: Ensure income feels fair and strategic

### Known Limitations

- AI doesn't coordinate attacks between enemy teams
- No fog of war - all units visible at all times
- Tower placement validation is basic (only distance checks)
- No save/load functionality

### Next Steps (Future Polish)

1. **Advanced AI**: Formation-based unit movement
2. **Additional Units**: More unit types with special abilities
3. **Visual Polish**: Particle effects, screen shake on damage
4. **Sound Design**: Unit movement, attack, and death sounds
5. **Tutorial**: Interactive onboarding for new players

---
*Generated during overnight polishing session*

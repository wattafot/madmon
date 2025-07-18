# Menschenmon Development Guide

## Server Commands

### Start Development Server
```bash
cd /Users/friedervibrans/madmon/web-version/export/web && npx serve -p 8000
```

### Export to Web
1. Export to web from Godot editor
2. Run the server command above
3. Access at http://localhost:8000

## Project Structure

- `scripts/` - GDScript files
- `scenes/` - Godot scene files
- `data/` - JSON data files (items, enemies, etc.)
- `export/web/` - Web export output

## Battle System Features

### Flucht-System (Escape System)
Das Flucht-System implementiert eine realistische Flucht-Mechanik basierend auf Geschwindigkeits-Unterschieden:

#### Funktionalität
- **Wilde Kämpfe**: Flucht ist immer möglich (mit Wahrscheinlichkeit)
- **Trainer-Kämpfe**: Flucht ist komplett blockiert
- **Geschwindigkeits-basierte Formel**: Schnellere Spieler = höhere Flucht-Chance
- **Mehrfache Versuche**: Jeder gescheiterte Versuch erhöht die Chance beim nächsten Mal

#### Verwendung
```gdscript
# Wilden Kampf starten (Flucht erlaubt)
battle_manager.set_wild_battle("wild_mario")

# Trainer-Kampf starten (Flucht nicht erlaubt)
battle_manager.set_trainer_battle("benedikt")

# Flucht-System testen
battle_manager.test_escape_system()
```

#### Geschwindigkeitswerte
- **Spieler (FRIEDER)**: 73 (Base: 65 + Level 9 Bonus)
- **Bene**: 22 (Base: 30 + Level 1 Bonus) - Sehr leicht zu entkommen
- **MARIO**: 76 (Base: 70 + Level 8 Bonus) - Mittelschwer
- **FEIERBIEST**: 96 (Base: 80 + Level 13 Bonus) - Schwer zu entkommen
- **WIRBELWIND**: 113 (Base: 95 + Level 14 Bonus) - Sehr schwer zu entkommen

#### Flucht-Formel
```
F = ((Spieler_Speed * 32) / (Gegner_Speed mod 256)) + 30 * Flucht_Versuche
Chance = clamp(F / 256, 0.05, 0.95)
```

### Gegner-Datenbank
Die Gegner-Datenbank unterstützt jetzt `base_speed` für realistische Flucht-Berechnungen.

#### Neue Gegner hinzufügen
```gdscript
var new_enemy = {
    "trainer_name": "Wilder LUIGI",
    "fighter_name": "LUIGI",
    "fighter_level": 10,
    "title": "Der Grüne",
    "fighter_type": AttackType.NORMAL,
    "base_speed": 75,  # Wichtig für Flucht-Mechanik
    "attacks": [...]
}
battle_manager.add_enemy_to_database("wild_luigi", new_enemy)
```

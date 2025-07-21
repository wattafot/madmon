# Menschenmon Development Guide

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Menschenmon is a Godot-based battle game with comprehensive battle systems, status effects, and escape mechanics. Built with Godot Engine and exported for web deployment.

## WORKFLOW - CRITICAL: ALWAYS FOLLOW THIS PROCESS

**Trello Board:** https://trello.com/b/CKruqXNP/madmon

**Trello API Configuration:** The `.env` file contains `TRELLO_API_KEY` and `TRELLO_TOKEN` for API access.

### Task Management Process (MANDATORY)

1. **Check Trello Board Status**
   - Use WebFetch or Task tool to check current board status
   - Identify tasks in READY column ordered by priority (HIGH > MEDIUM > LOW)
   - Never start work without checking board first

2. **Take Next Task**
   - Select highest priority task from READY column
   - Move ticket from READY → IN_PROGRESS in Trello
   - Create new feature branch: `feature/task-name`
   - NEVER work on main branch directly

3. **Implementation**
   - Use TodoWrite tool to plan and track implementation steps
   - Follow git best practices with descriptive commits
   - Update Trello ticket with progress and any blockers

4. **Testing & Validation (MANDATORY)**
   - Test in Godot editor before exporting
   - Export to web and test in browser
   - Verify all battle mechanics work correctly
   - Test new features thoroughly
   - Check for GDScript errors in debugger
   - Fix any issues before proceeding

5. **Completion**
   - CRITICAL: Ensure ALL acceptance criteria are met before marking complete
   - If any requirements cannot be fulfilled, MUST document reasons in Trello ticket
   - Move ticket from IN_PROGRESS → IN_REVIEW in Trello with complete status update
   - Commit all changes with proper commit message format
   - Push feature branch to remote: `git push -u origin feature/task-name`
   - Create Pull Request via GitHub CLI: `gh pr create`
   - Add PR link to Trello ticket description
   - Update ticket description with:
     - [x] Completed requirements
     - [ ] Incomplete requirements with explanations
     - Technical implementation details
     - Status summary

6. **Next Iteration**
   - Wait for PR review/approval before starting new tasks
   - If dependencies exist, communicate blockers in tickets
   - Repeat process with next highest priority READY task

### Git Branch Strategy

- `main`: Production-ready code only
- `feature/*`: Individual feature branches for each Trello ticket
- Always create separate branches for each ticket
- No direct pushes to main - everything goes through PR review

### Dependencies & Blockers

- If a ticket depends on another ticket still in IN_REVIEW, STOP and notify user
- Document any missing assets or external dependencies in ticket
- Prioritize unblocked tasks from READY column

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

## Development Guidelines

- Test all battle mechanics in Godot editor before exporting
- Use GDScript's built-in debugging tools
- Follow existing code patterns in scripts/
- Maintain save compatibility when updating game systems
- Test web exports thoroughly in multiple browsers

## Important Instruction Reminders

- Do what has been asked; nothing more, nothing less
- NEVER create files unless they're absolutely necessary for achieving your goal
- ALWAYS prefer editing an existing file to creating a new one
- NEVER proactively create documentation files (*.md) or README files unless explicitly requested
- Follow the Trello workflow process for all development tasks

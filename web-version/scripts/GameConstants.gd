class_name GameConstants
extends Resource

# Game Constants for Menschenmon
# Centralizes all magic numbers and configuration values

# =============================================================================
# PLAYER CONSTANTS
# =============================================================================

const PLAYER_SPEED: float = 300.0
const PLAYER_LEVEL: int = 9
const PLAYER_NAME: String = "FRIEDER"
const PLAYER_TRAINER_NAME: String = "Kleines Pokemon"

# =============================================================================
# ANIMATION CONSTANTS
# =============================================================================

const WALK_FRAME_DURATION: float = 0.2
const BATTLE_ANIMATION_DURATION: float = 0.1
const UI_ANIMATION_DURATION: float = 0.3
const FLOATING_TEXT_DURATION: float = 2.0

# =============================================================================
# SCREEN & UI CONSTANTS
# =============================================================================

const SCREEN_CENTER: Vector2 = Vector2(640, 360)
const VIEWPORT_SIZE: Vector2 = Vector2(1280, 720)
const UI_PADDING: int = 10
const BUTTON_MARGIN: int = 5
const CATEGORY_BUTTON_WIDTH: int = 120

# =============================================================================
# INVENTORY CONSTANTS
# =============================================================================

const MAX_INVENTORY_SLOTS: int = 300
const MAX_MONEY: int = 999999
const DEFAULT_STACK_SIZE: int = 99
const ITEMS_PER_PAGE: int = 20
const INVENTORY_CATEGORIES: Array[String] = ["medizin", "fanggeraete", "sonstiges"]

# =============================================================================
# BATTLE CONSTANTS
# =============================================================================

const CRITICAL_HIT_CHANCE: float = 0.0625  # 1/16
const CRITICAL_HIT_MULTIPLIER: float = 2.0
const STATUS_EFFECT_DURATION: int = 3
const ESCAPE_BASE_CHANCE: float = 0.05
const ESCAPE_MAX_CHANCE: float = 0.95

# Battle phases
enum BattlePhase {
	INTRO,
	PLAYER_TURN,
	ENEMY_TURN,
	BATTLE_END
}

# Menu modes
enum MenuMode {
	ATTACK,
	INVENTORY,
	DIALOGUE
}

# =============================================================================
# ATTACK TYPE CONSTANTS
# =============================================================================

enum AttackType {
	ALKOHOL,
	NORMAL,
	GEMUTLICH,
	PARTY,
	CHAOS
}

enum AttackCategory {
	PHYSICAL,
	SPECIAL,
	STATUS
}

# =============================================================================
# HEALING CONSTANTS
# =============================================================================

const HEAL_SMALL: int = 20
const HEAL_MEDIUM: int = 50
const HEAL_LARGE: int = 100
const HEAL_FULL: int = 9999

# =============================================================================
# PARTICLE SYSTEM CONSTANTS
# =============================================================================

const PARTICLE_LIFETIME: float = 2.0
const SCREEN_SHAKE_INTENSITY: float = 8.0
const SCREEN_SHAKE_DURATION: float = 0.4
const TRAUMA_DECAY_RATE: float = 1.0

# =============================================================================
# AUDIO CONSTANTS
# =============================================================================

const MASTER_VOLUME: float = 1.0
const MUSIC_VOLUME: float = 0.7
const SFX_VOLUME: float = 0.8
const UI_VOLUME: float = 0.6

# =============================================================================
# FILE PATHS
# =============================================================================

const ITEMS_DATABASE_PATH: String = "res://data/items.json"
const SAVE_FILE_PATH: String = "user://savegame.save"
const AUDIO_SETTINGS_PATH: String = "user://audio_settings.save"
const CONFIG_PATH: String = "user://config.cfg"

# =============================================================================
# COLORS
# =============================================================================

const COLOR_HEALTHY: Color = Color("#32CD32")      # Forest green for 51-100%
const COLOR_WARNING: Color = Color("#FFFF00")      # Bright yellow for 21-50%
const COLOR_CRITICAL: Color = Color("#FF0000")     # Alert red for 0-20%
const COLOR_BACKGROUND: Color = Color("#2C2C2C")   # Dark gray background
const COLOR_PANEL: Color = Color("#3C3C3C")        # Lighter gray for panels
const COLOR_BORDER: Color = Color("#5C5C5C")       # Border color
const COLOR_TEXT: Color = Color("#FFFFFF")         # White text
const COLOR_ACCENT: Color = Color("#4CAF50")       # Green accent

# Attack type colors
const COLOR_ALKOHOL: Color = Color("#1a1a2e")      # Dark blue
const COLOR_NORMAL: Color = Color("#636e72")       # Gray
const COLOR_GEMUTLICH: Color = Color("#26de81")    # Soft green
const COLOR_PARTY: Color = Color("#ff6b6b")        # Bright red
const COLOR_CHAOS: Color = Color("#a55eea")        # Purple

# =============================================================================
# GAME STATE CONSTANTS
# =============================================================================

enum GameState {
	EXPLORING,
	DIALOGUE,
	BATTLE,
	INVENTORY,
	MENU,
	PAUSED
}

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

static func get_type_color(attack_type: AttackType) -> Color:
	match attack_type:
		AttackType.ALKOHOL: return COLOR_ALKOHOL
		AttackType.NORMAL: return COLOR_NORMAL
		AttackType.GEMUTLICH: return COLOR_GEMUTLICH
		AttackType.PARTY: return COLOR_PARTY
		AttackType.CHAOS: return COLOR_CHAOS
		_: return COLOR_NORMAL

static func get_hp_color(hp_percent: float) -> Color:
	if hp_percent > 0.5:
		return COLOR_HEALTHY
	elif hp_percent > 0.2:
		return COLOR_WARNING
	else:
		return COLOR_CRITICAL

static func get_category_display_name(category: String) -> String:
	match category:
		"medizin": return "Medizin"
		"fanggeraete": return "Fanggeräte"
		"sonstiges": return "Sonstiges"
		_: return category.capitalize()

static func is_valid_item_category(category: String) -> bool:
	return category in INVENTORY_CATEGORIES

static func clamp_money(amount: int) -> int:
	return clamp(amount, 0, MAX_MONEY)

static func clamp_inventory_quantity(quantity: int) -> int:
	return clamp(quantity, 0, DEFAULT_STACK_SIZE)

# =============================================================================
# DEBUG CONSTANTS
# =============================================================================

const DEBUG_MODE: bool = false
const SHOW_FPS: bool = false
const SHOW_COLLISION_SHAPES: bool = false
const ENABLE_CHEATS: bool = false
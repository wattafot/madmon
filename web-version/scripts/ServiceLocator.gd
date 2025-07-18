extends Node

# ServiceLocator - Dependency Management for Menschenmon
# Provides centralized service registration and retrieval

# =============================================================================
# PRIVATE VARIABLES
# =============================================================================

var _services: Dictionary = {}
var _service_types: Dictionary = {}
var _initialization_order: Array[String] = []

# =============================================================================
# SERVICE REGISTRATION
# =============================================================================

func register_service(service_name: String, service: Node, service_type: String = ""):
	"""Register a service with optional type checking."""
	if service_name in _services:
		push_warning("ServiceLocator: Service '%s' is already registered, replacing..." % service_name)
	
	_services[service_name] = service
	_service_types[service_name] = service_type
	_initialization_order.append(service_name)
	
	if GameConstants.DEBUG_MODE:
		print("ServiceLocator: Registered service '%s' of type '%s'" % [service_name, service_type])
	
	# Emit event for service registration
	EventBus.emit_safe("service_registered", [service_name, service])

func unregister_service(service_name: String):
	"""Unregister a service."""
	if service_name not in _services:
		push_warning("ServiceLocator: Service '%s' is not registered" % service_name)
		return
	
	var service = _services[service_name]
	_services.erase(service_name)
	_service_types.erase(service_name)
	_initialization_order.erase(service_name)
	
	if GameConstants.DEBUG_MODE:
		print("ServiceLocator: Unregistered service '%s'" % service_name)
	
	# Emit event for service unregistration
	EventBus.emit_safe("service_unregistered", [service_name, service])

# =============================================================================
# SERVICE RETRIEVAL
# =============================================================================

func get_service(service_name: String) -> Node:
	"""Get a service by name."""
	if service_name not in _services:
		push_error("ServiceLocator: Service '%s' is not registered" % service_name)
		return null
	
	return _services[service_name]

func get_service_safe(service_name: String) -> Node:
	"""Get a service by name with null safety."""
	return _services.get(service_name, null)

func has_service(service_name: String) -> bool:
	"""Check if a service is registered."""
	return service_name in _services

func get_service_type(service_name: String) -> String:
	"""Get the type of a registered service."""
	return _service_types.get(service_name, "")

func get_services_of_type(service_type: String) -> Array[Node]:
	"""Get all services of a specific type."""
	var result: Array[Node] = []
	for service_name in _services:
		if _service_types.get(service_name, "") == service_type:
			result.append(_services[service_name])
	return result

# =============================================================================
# TYPED SERVICE GETTERS
# =============================================================================

func get_game_state_manager() -> Node:
	"""Get the GameStateManager service."""
	return get_service("GameStateManager")

func get_inventory_manager() -> Node:
	"""Get the InventoryManager service."""
	return get_service("InventoryManager")

func get_audio_manager() -> Node:
	"""Get the AudioManager service."""
	return get_service("AudioManager")

func get_particle_manager() -> Node:
	"""Get the ParticleManager service."""
	return get_service("ParticleManager")

func get_camera_effects() -> Node:
	"""Get the CameraEffects service."""
	return get_service("CameraEffects")

func get_floating_text_manager() -> Node:
	"""Get the FloatingTextManager service."""
	return get_service("FloatingTextManager")

func get_battle_manager() -> Node:
	"""Get the BattleManager service."""
	return get_service("BattleManager")

# =============================================================================
# SERVICE INITIALIZATION
# =============================================================================

func initialize_services():
	"""Initialize all services in the correct order."""
	for service_name in _initialization_order:
		var service = _services[service_name]
		if service.has_method("initialize"):
			if GameConstants.DEBUG_MODE:
				print("ServiceLocator: Initializing service '%s'" % service_name)
			service.initialize()

func initialize_service(service_name: String):
	"""Initialize a specific service."""
	var service = get_service_safe(service_name)
	if service and service.has_method("initialize"):
		if GameConstants.DEBUG_MODE:
			print("ServiceLocator: Initializing service '%s'" % service_name)
		service.initialize()

# =============================================================================
# SERVICE LIFECYCLE
# =============================================================================

func start_services():
	"""Start all services."""
	for service_name in _initialization_order:
		var service = _services[service_name]
		if service.has_method("start"):
			if GameConstants.DEBUG_MODE:
				print("ServiceLocator: Starting service '%s'" % service_name)
			service.start()

func stop_services():
	"""Stop all services."""
	# Stop in reverse order
	var reverse_order = _initialization_order.duplicate()
	reverse_order.reverse()
	
	for service_name in reverse_order:
		var service = _services[service_name]
		if service.has_method("stop"):
			if GameConstants.DEBUG_MODE:
				print("ServiceLocator: Stopping service '%s'" % service_name)
			service.stop()

func restart_service(service_name: String):
	"""Restart a specific service."""
	var service = get_service_safe(service_name)
	if service:
		if service.has_method("stop"):
			service.stop()
		if service.has_method("start"):
			service.start()

# =============================================================================
# DEPENDENCY INJECTION
# =============================================================================

func inject_dependencies(target: Node):
	"""Inject dependencies into a target node."""
	if not target.has_method("get_dependencies"):
		return
	
	var dependencies = target.get_dependencies()
	if typeof(dependencies) != TYPE_DICTIONARY:
		push_error("ServiceLocator: get_dependencies() must return a Dictionary")
		return
	
	for property_name in dependencies:
		var service_name = dependencies[property_name]
		var service = get_service_safe(service_name)
		if service:
			target.set(property_name, service)
			if GameConstants.DEBUG_MODE:
				print("ServiceLocator: Injected '%s' into '%s'" % [service_name, target.name])
		else:
			push_error("ServiceLocator: Could not inject service '%s' into '%s'" % [service_name, target.name])

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

func get_all_services() -> Dictionary:
	"""Get all registered services."""
	return _services.duplicate()

func get_service_names() -> Array:
	"""Get all service names."""
	return _services.keys()

func get_service_count() -> int:
	"""Get the number of registered services."""
	return _services.size()

func clear_services():
	"""Clear all registered services."""
	_services.clear()
	_service_types.clear()
	_initialization_order.clear()
	
	if GameConstants.DEBUG_MODE:
		print("ServiceLocator: Cleared all services")

func print_services():
	"""Print all registered services for debugging."""
	print("ServiceLocator: Registered services:")
	for service_name in _services:
		var service = _services[service_name]
		var service_type = _service_types.get(service_name, "unknown")
		print("  - %s (%s): %s" % [service_name, service_type, service])

# =============================================================================
# VALIDATION
# =============================================================================

func validate_services() -> bool:
	"""Validate all registered services."""
	var valid = true
	
	for service_name in _services:
		var service = _services[service_name]
		if not is_instance_valid(service):
			push_error("ServiceLocator: Service '%s' is not valid" % service_name)
			valid = false
		elif service.is_queued_for_deletion():
			push_error("ServiceLocator: Service '%s' is queued for deletion" % service_name)
			valid = false
	
	return valid

func validate_service(service_name: String) -> bool:
	"""Validate a specific service."""
	var service = get_service_safe(service_name)
	if not service:
		return false
	
	if not is_instance_valid(service):
		push_error("ServiceLocator: Service '%s' is not valid" % service_name)
		return false
	
	if service.is_queued_for_deletion():
		push_error("ServiceLocator: Service '%s' is queued for deletion" % service_name)
		return false
	
	return true

# =============================================================================
# INITIALIZATION
# =============================================================================

func _ready():
	# Register self as a service
	register_service("ServiceLocator", self, "core")
	
	if GameConstants.DEBUG_MODE:
		print("ServiceLocator: Initialized")

func _exit_tree():
	# Clean up services
	stop_services()
	clear_services()
	
	if GameConstants.DEBUG_MODE:
		print("ServiceLocator: Shutdown complete")

# =============================================================================
# AUTO-REGISTRATION
# =============================================================================

func auto_register_singletons():
	"""Automatically register common singletons."""
	# Register common autoload singletons
	var autoloads = [
		"GameStateManager",
		"InventoryManager", 
		"AudioManager"
	]
	
	for autoload_name in autoloads:
		var node = get_node_or_null("/root/" + autoload_name)
		if node:
			register_service(autoload_name, node, "singleton")

func auto_register_scene_services(scene: Node):
	"""Automatically register services from a scene."""
	# Look for nodes with the 'service' group
	var service_nodes = scene.get_tree().get_nodes_in_group("service")
	
	for service_node in service_nodes:
		var service_name = service_node.name
		var service_type = service_node.get_meta("service_type", "scene")
		register_service(service_name, service_node, service_type)
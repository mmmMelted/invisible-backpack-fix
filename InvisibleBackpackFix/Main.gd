extends Node
## Invisible Backpack Fix: dead AI no longer drop a pile of invisible backpacks, a dead AI's backpack stays on its back
## without sinking into the ground, and more AI carry a backpack (tier by faction).
##
## Why: every AI carries one of each backpack model. At spawn vanilla SelectBackpack() gives 5% of AI a backpack (shows
## it, deletes the rest); for the other 95% it does nothing, so all the spare backpacks stay on. On death, Death()
## switches physics and collision on for every backpack the AI carries, so those AI drop several invisible, lootable
## backpacks. The worn backpack is a frozen pickup welded to the back, and the ragdoll doesn't know it's there, so a
## body that falls backward pushes it into the ground (out of reach).
##
## This mod makes the backpack choice itself: chance_percent (default 25, in user://rtv_backpackfix.cfg) of a backpack
## by faction (bandits/Nomads low-tier, Guards mid, Military high), every other copy deleted. On death the worn
## backpack becomes part of the ragdoll: a box the size of the backpack is added to the bone it hangs from, so a body
## falling backward lies on top of it. Bosses keep vanilla behaviour.


const VERSION := "1.3.2"
const TAG := "[InvisibleBackpackFix] "
const CONFIG := "user://rtv_backpackfix.cfg"
## Backpacks each faction may spawn with (item file prefix -> weight): bandits and Nomads get low-tier ones, Guards
## lean to mid-tier, Military to high-tier. "Backpack_Jaeger" covers all its colour variants.
const LOW_TIER := {"Duffel_Retro": 45.0, "Backpack_Nomad": 40.0, "Backpack_Patrol": 15.0}
const PICKS := {
	AIData.Faction.Guard: {"Backpack_Patrol": 40.0, "Backpack_Jaeger": 35.0, "Backpack_Nomad": 15.0, "Duffel_Retro": 5.0, "Backpack_Kantamus": 5.0},
	AIData.Faction.Military: {"Backpack_Jaeger": 45.0, "Backpack_Kantamus": 30.0, "Backpack_Patrol": 25.0},
}
## Ragdoll collider for the worn backpack: fallback size (m) if its mesh can't be measured, and the spine bones to try
## when the backpack's own bone has no physics bone.
const DEFAULT_SIZE := Vector3(0.35, 0.45, 0.22)
const SPINE_BONES := ["Spine_03", "Spine_04", "Spine_02", "Spine_01"]


var _lib = null
var _chance := 25.0
var _worn := 0
var _total := 0
var _removed := 0
var _reportQueued := false



func _ready():
	var cfg := ConfigFile.new()
	if cfg.load(CONFIG) != OK:
		cfg.set_value("backpacks", "chance_percent", 25.0)
		cfg.save(CONFIG)
	_chance = clamp(float(cfg.get_value("backpacks", "chance_percent", 25.0)), 0.0, 100.0)
	print(TAG + "v" + VERSION + " loaded (backpack chance " + str(_chance) + "%)")
	if Engine.has_meta("RTVModLib"):
		var lib = Engine.get_meta("RTVModLib")
		if lib._is_ready: _on_lib_ready()
		else: lib.frameworks_ready.connect(_on_lib_ready)
	else:
		push_warning(TAG + "RTVModLib not found, is Metro Mod Loader installed?")

func _on_lib_ready():
	_lib = Engine.get_meta("RTVModLib")
	if _lib.hook("ai-selectbackpack", _on_select_backpack) == -1:
		push_warning(TAG + "AI.SelectBackpack is replaced by another mod; only the death fixes are active")
	_lib.hook("ai-death-pre", _on_death)
	_lib.hook("ai-death-post", _on_death_post)



## ------------------------------------------------------------------------------------------------ spawning

## Replaces vanilla SelectBackpack() (runs once per pooled AI when the map loads): one backpack by faction, or none,
## every other copy deleted. Bosses keep vanilla behaviour.
func _on_select_backpack():
	var ai = _lib._caller
	if ai.variant != null && ai.variant.faction == AIData.Faction.Boss: return
	_lib.skip_super()
	if ai.backpacks == null: return


	var chosen = null
	# Dev Tools "every AI gets a backpack" (testing) forces 100%.
	var chance: float = 100.0 if Engine.get_meta("rtv_force_backpacks", false) else _chance
	if randf() * 100.0 < chance: chosen = _pick(ai.backpacks.get_children(), PICKS.get(ai.variant.faction, LOW_TIER))
	ai.backpack = chosen
	for child in ai.backpacks.get_children():
		if child == chosen: continue
		ai.backpacks.remove_child(child)
		child.queue_free()
		_removed += 1
	if chosen != null:
		chosen.show()
		var mesh = chosen.get_node_or_null("Mesh")
		if mesh: mesh.visibility_range_end = 400.0
		_worn += 1
	_total += 1


	if !_reportQueued:
		_reportQueued = true
		get_tree().create_timer(5.0, false).timeout.connect(_report)

## Weighted pick among the backpacks this AI model has (matched by the pickup's item file, or its node name).
func _pick(bags: Array, table: Dictionary):
	var options := []
	var total := 0.0
	for bag in bags:
		var weight := 0.0
		var file := ""
		if "slotData" in bag && bag.slotData != null && bag.slotData.itemData != null: file = str(bag.slotData.itemData.file)
		for key in table:
			if file.begins_with(key) || str(bag.name).contains(key): weight = table[key]
		if weight > 0.0:
			options.append([bag, weight])
			total += weight
	if options.is_empty(): return null
	var roll := randf() * total
	for option in options:
		roll -= option[1]
		if roll <= 0.0: return option[0]
	return options[-1][0]

func _report():
	_reportQueued = false
	print(TAG + str(_worn) + " of " + str(_total) + " AI got a backpack; removed " + str(_removed) + " unused copies")
	_worn = 0
	_total = 0
	_removed = 0



## ------------------------------------------------------------------------------------------------ death

## Safety net: any hidden backpack other than the worn one (e.g. an AI set up before this mod could act) is removed
## before Death() can make it a physical, invisible item.
func _on_death(_direction, _force):
	var ai = _lib._caller
	if ai.backpacks == null: return
	var worn = ai.get("backpack")
	for child in ai.backpacks.get_children():
		if child == worn || child.visible: continue
		ai.backpacks.remove_child(child)
		child.queue_free()

## After Death() started the ragdoll: the worn backpack becomes part of it (falls back to setting it down beside the
## body if no ragdoll bone is found).
func _on_death_post(_direction, _force):
	var ai = _lib._caller
	var holder = ai.get("backpacks")
	if holder == null: return
	for bag in holder.get_children():
		if bag is RigidBody3D && bag.visible && !_attach_to_ragdoll(ai, holder, bag): _set_down(ai, bag)

## Add a box the size of the backpack's mesh, at the backpack's place, to the ragdoll bone it hangs from; the ragdoll
## bones ignore the backpack's own collider so they can't push each other. Once per death, no per-frame cost.
func _attach_to_ragdoll(ai, holder, bag) -> bool:
	var skeleton = ai.get("skeleton")
	if skeleton == null: return false
	var bones := {}
	for child in skeleton.get_children():
		if child is PhysicalBone3D: bones[str(child.bone_name)] = child
	var bone = bones.get(str(holder.get("bone_name")))
	if bone == null:
		for spine in SPINE_BONES:
			if bones.has(spine):
				bone = bones[spine]
				break
	if bone == null: return false


	var size := DEFAULT_SIZE
	var center: Transform3D = bag.global_transform
	var mesh = bag.get_node_or_null("Mesh")
	if mesh is MeshInstance3D && mesh.mesh != null:
		var box: AABB = mesh.get_aabb()
		size = (box.size * mesh.global_transform.basis.get_scale()).clamp(Vector3(0.1, 0.1, 0.08), Vector3(0.7, 0.8, 0.45))
		center = mesh.global_transform * Transform3D(Basis(), box.get_center())
	var shape := CollisionShape3D.new()
	var boxShape := BoxShape3D.new()
	boxShape.size = size
	shape.shape = boxShape
	shape.name = "BackpackCollider"
	bone.add_child(shape)
	shape.global_transform = Transform3D(center.basis.orthonormalized(), center.origin)
	for child in bones.values(): child.add_collision_exception_with(bag)
	# Looting the backpack removes it: take the box away too, or the body keeps lying on nothing.
	bag.tree_exiting.connect(_on_bag_removed.bind(ai, shape), CONNECT_ONE_SHOT)
	return true

## The backpack left the body (looted): remove its ragdoll box. A body still simulating (vanilla stops the ragdoll
## after 10 s) settles onto the ground by itself. A frozen body is left exactly as it lies: restarting a frozen ragdoll
## makes the game rebuild the bones at the AI's original death spot (a collapsed "ghost" body), so it's not done.
func _on_bag_removed(_ai, shape):
	if is_instance_valid(shape): shape.queue_free()

## Fallback: take the backpack off and let it fall onto the floor beside the body.
func _set_down(ai, bag):
	var scene = get_tree().current_scene
	if scene == null || !bag.is_inside_tree(): return
	bag.reparent(scene, true)
	var side: Vector3 = ai.global_transform.basis.x
	side.y = 0.0
	side = side.normalized() if side.length() > 0.01 else Vector3.RIGHT
	var from: Vector3 = ai.global_position + side * 0.7 + Vector3.UP * 1.2
	var query := PhysicsRayQueryParameters3D.create(from, from + Vector3.DOWN * 4.0)
	var exclude := [bag.get_rid()]
	if "collision" in ai && ai.collision != null && ai.collision.has_method("get_rid"): exclude.append(ai.collision.get_rid())
	query.exclude = exclude
	var hit: Dictionary = bag.get_world_3d().direct_space_state.intersect_ray(query)
	bag.global_position = (hit["position"] + Vector3.UP * 0.35) if !hit.is_empty() else ai.global_position + side * 0.7 + Vector3.UP * 0.5
	bag.linear_velocity = Vector3.ZERO
	bag.angular_velocity = Vector3.ZERO
	# Pickups are frozen (they'd hang in the air): let it fall the way the game drops a player's item.
	if bag.has_method("Unfreeze"): bag.Unfreeze()
	else: bag.freeze = false
	bag.continuous_cd = true

class_name WeaponMountProfile
extends Resource

## Saved calibration offsets for gear mounted on BoneAttachment3D nodes.
## Authoritative source of truth: loaded on ready, never overwritten by runtime gameplay.

@export var position_offset: Vector3 = Vector3.ZERO
@export var rotation_degrees_offset: Vector3 = Vector3.ZERO
@export var scale_factor: Vector3 = Vector3.ONE


func apply_to(node: Node3D) -> void:
	node.position = position_offset
	node.rotation_degrees = rotation_degrees_offset
	node.scale = scale_factor

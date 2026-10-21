class_name WaveEnemy
extends Resource

@export var scene: PackedScene
@export_range(1, 20) var cost: int = 1       # how much of the wave this costs
@export var min_wave: int = 1                # first wave it can appear in
@export var weight: float = 1.0              # pick chance among affordable enemies

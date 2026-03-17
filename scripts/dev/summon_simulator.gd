extends Node

# Run this script via `godot --script res://scripts/dev/summon_simulator.gd`
# It prints summon probability distribution for given pond levels.

func _run():
	var levels = [1, 5, 10, 20]
	var trials = 1000
	for level in levels:
		var results = PondManager.debug_simulate_summons(level, trials)
		print("--- Level %d (%d trials) ---" % [level, trials])
		for grade in results["counts"].keys().sort():
			var count = results["counts"][grade]
			print("grade %d: %d (%.2f%%)" % [grade, count, count * 100.0 / trials])

func _ready():
	_run()
	get_tree().quit()

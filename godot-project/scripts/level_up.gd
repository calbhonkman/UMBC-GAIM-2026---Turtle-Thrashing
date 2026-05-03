extends Node2D

@onready var upgrade_description = $"Upgrade Description"

@export var num_upgrade_option: int = 3
@export var upgradeables: Array[Node2D]
@export var upgrade_buttons: Array[Button]

var selected_upgrades = []
var chosen_upgrade = null

var ready_to_upgrade = false

var selected = false

var group := ButtonGroup.new()

func _ready():
	for button in upgrade_buttons:
		button.button_group = group

func _process(delta):
	if not ready_to_upgrade:
		pass
	
	chosen_upgrade = null
	upgrade_description.text = "Select An Upgrade."
	
	for i in upgrade_buttons.size():
		if upgrade_buttons[i].button_pressed:
			selected = true
			chosen_upgrade = selected_upgrades[i]
			upgrade_description.text = upgradeables[selected_upgrades[i].x].get_upgrade_description(selected_upgrades[i].y)
			upgrade_buttons[i].icon = upgradeables[selected_upgrades[i].x].upgrade_icon_selected
			for j in upgrade_buttons.size():
				if j != i:
					upgrade_buttons[j].icon = upgradeables[selected_upgrades[j].x].upgrade_icon
		elif upgrade_buttons[i].is_hovered() and selected == false:
			chosen_upgrade = selected_upgrades[i]
			upgrade_description.text = upgradeables[selected_upgrades[i].x].get_upgrade_description(selected_upgrades[i].y)

func prepare_to_upgrade():
	select_upgrades()
	for i in upgrade_buttons.size():
		upgrade_buttons[i].icon = upgradeables[selected_upgrades[i].x].upgrade_icon
	visible = true
	ready_to_upgrade = true
	selected = false
	AudioManager.levelUp.play()

func select_upgrades():
	selected_upgrades = []
	var available_upgradeables = upgradeables.duplicate()
	for i in range(min(available_upgradeables.size(), num_upgrade_option)):
		var rand_index = randi_range(0, available_upgradeables.size()-1)
		var rand_upgradeable = available_upgradeables.pop_at(rand_index)
		selected_upgrades.append(rand_upgradeable.get_random_upgrade(upgradeables.find(rand_upgradeable)))

func _on_confirm_pressed():
	if chosen_upgrade != null:
		upgradeables[chosen_upgrade.x].upgrade(chosen_upgrade.y)
		for button in upgrade_buttons:
			button.button_pressed = false
		get_parent().get_parent().resume()
		AudioManager.resume_all_sounds()

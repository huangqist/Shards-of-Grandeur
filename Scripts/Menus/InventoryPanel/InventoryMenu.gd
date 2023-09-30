extends Node2D
class_name InventoryMenu

@export_category("InventoryPanel - Filters")
@export var selectedFilter: Item.Type = Item.Type.ALL
@export var battleFilter: bool = false
@export var lockFilters: bool = false

@export_category("InventoryPanel - Shops")
@export var inShop: bool = false
@export var showPlayerInventory = false
var shopInventory: Inventory = null

@onready var vboxViewport = get_node("InventoryPanel/Panel/ScrollContainer/VBoxContainer")
@onready var inventoryTitle: RichTextLabel = get_node("InventoryPanel/Panel/InventoryTitle")
@onready var goldCount: RichTextLabel = get_node("InventoryPanel/Panel/GoldCountGroup/GoldCount")
@onready var toggleShopButton: Button = get_node("InventoryPanel/Panel/ToggleShopInventoryButton")

@onready var healingFilterBtn: Button = get_node("InventoryPanel/Panel/HBoxContainer/HealingButton")
@onready var shardFilterBtn: Button = get_node("InventoryPanel/Panel/HBoxContainer/ShardsButton")
@onready var weaponFilterBtn: Button = get_node("InventoryPanel/Panel/HBoxContainer/WeaponsButton")
@onready var armorFilterBtn: Button = get_node("InventoryPanel/Panel/HBoxContainer/ArmorButton")
@onready var keyItemFilterBtn: Button = get_node("InventoryPanel/Panel/HBoxContainer/KeyItemsButton")
@onready var backButton: Button = get_node("InventoryPanel/Panel/BackButton")
@onready var itemDetailsPanel: ItemDetailsPanel = get_node("ItemDetailsPanel")

var currentInventory: Inventory

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func toggle():
	visible = not visible
	if visible:
		get_display_inventory()
		check_filters()
		load_inventory_panel()
	else:
		itemDetailsPanel.visible = false

func get_display_inventory():
	currentInventory = PlayerResources.inventory
	if inShop and not showPlayerInventory:
		currentInventory = shopInventory
	#else:
		#currentInventory.add_item(load("res://GameData/Items/Weapon/StdIssueSword.tres"))

func load_inventory_panel():
	get_display_inventory()
	update_toggle_inv_button()
	update_filter_buttons()
	
	for panel in get_tree().get_nodes_in_group("InventorySlotPanel"):
		panel.queue_free()
	
	inventoryTitle.text = '[center]Inventory[/center]'
	goldCount.text = TextUtils.NumToCommaString(PlayerResources.playerInfo.gold)
	if inShop:
		if not showPlayerInventory:
			inventoryTitle.text = '[center]Shop Inventory[/center]'
		else:
			inventoryTitle.text = '[center]Your Inventory[/center]'

	var invSlotPanel = load("res://Prefabs/UI/Inventory/InventorySlotPanel.tscn")
	for slot in currentInventory.inventorySlots:
		if selectedFilter == Item.Type.ALL or selectedFilter == slot.item.itemType:
			var instantiatedPanel: InventorySlotPanel = invSlotPanel.instantiate()
			instantiatedPanel.isShopItem = inShop
			instantiatedPanel.isPlayerItem = showPlayerInventory or not inShop
			instantiatedPanel.isEquipped = currentInventory.is_equipped(slot.item)
			instantiatedPanel.inventoryMenu = self
			instantiatedPanel.inventorySlot = slot
			vboxViewport.add_child(instantiatedPanel)
	
func buy_item(slot: InventorySlot):
	PlayerResources.inventory.add_item(slot.item)
	PlayerResources.playerInfo.gold -= slot.item.cost
	shopInventory.trash_item(slot)
	
func sell_item(slot: InventorySlot):
	PlayerResources.inventory.trash_item(slot)
	PlayerResources.playerInfo.gold += slot.item.cost
	shopInventory.add_item(slot.item)

func view_item_details(slot: InventorySlot):
	backButton.disabled = true
	itemDetailsPanel.item = slot.item
	itemDetailsPanel.count = slot.count
	itemDetailsPanel.visible = true
	itemDetailsPanel.load_item_details()

func filter_by(type: Item.Type = Item.Type.ALL):
	selectedFilter = type
	load_inventory_panel()
	
func update_toggle_inv_button():
	toggleShopButton.visible = inShop
	toggleShopButton.text = "Show Shop's Inventory" if showPlayerInventory else 'Show Your Inventory'
	
func check_filters():
	var count: int = 0
	for slot in currentInventory.inventorySlots:
		if selectedFilter == Item.Type.ALL or selectedFilter == slot.item.itemType:
			count += 1
	
	if count == 0: # reset filter if no items would be shown
		selectedFilter = Item.Type.ALL

func update_filter_buttons():
	healingFilterBtn.button_pressed = selectedFilter == Item.Type.HEALING
	shardFilterBtn.button_pressed = selectedFilter == Item.Type.SHARD
	weaponFilterBtn.button_pressed = selectedFilter == Item.Type.WEAPON
	armorFilterBtn.button_pressed = selectedFilter == Item.Type.ARMOR
	keyItemFilterBtn.button_pressed = selectedFilter == Item.Type.KEY_ITEM
	
	healingFilterBtn.disabled = lockFilters
	shardFilterBtn.disabled = lockFilters
	weaponFilterBtn.disabled = lockFilters
	armorFilterBtn.disabled = lockFilters
	keyItemFilterBtn.disabled = lockFilters

func _on_toggle_shop_inventory_button_pressed():
	showPlayerInventory = not showPlayerInventory
	load_inventory_panel()

func _on_back_button_pressed():
	toggle() # hide inventory panel
	
func _on_details_back_button_pressed():
	backButton.disabled = false

func _on_healing_button_toggled(button_pressed):
	if button_pressed:
		filter_by(Item.Type.HEALING)
	elif selectedFilter == Item.Type.HEALING:
		filter_by()

func _on_shards_button_toggled(button_pressed):
	if button_pressed:
		filter_by(Item.Type.SHARD)
	elif selectedFilter == Item.Type.SHARD:
		filter_by()

func _on_weapons_button_toggled(button_pressed):
	if button_pressed:
		filter_by(Item.Type.WEAPON)
	elif selectedFilter == Item.Type.WEAPON:
		filter_by()
	
func _on_armor_button_toggled(button_pressed):
	if button_pressed:
		filter_by(Item.Type.ARMOR)
	elif selectedFilter == Item.Type.ARMOR:
		filter_by()

func _on_key_items_button_toggled(button_pressed):
	if button_pressed:
		filter_by(Item.Type.KEY_ITEM)
	elif selectedFilter == Item.Type.KEY_ITEM:
		filter_by()

extends Node
var config = {
	"BOOT_TO": Boot_Type.PC,
	"BOOT_CHAPTER": ScenePoints.SAVE,
	"PLAYER_NAME": "player",
	"WORLD_TYPE": WORLD_TYPE.FIELD,
	"WORLD_SEASON": World_Season.SUMMER,
	"BED_COLOUR": Colour.RED,
	"PET_TYPE": "Axolotl",
	"PET_NAME": "Kinito",
	"HOUSE_SUPER": "fly anywhere",
	"HOUSE_FOOD": "bread",
	"HOUSE_GAME": "KinitoPET",
	"PLAYER_BIRTHDAY": false,
	"GAME_SPEED": false
}
var config_loaded = false

func _ready():
	config_handler()
	print("[no-boot] KinitoNoBoot installed")
	
	pass

func config_handler():
	var dir = Directory.new()
	dir.open("user://Mods")
	if (dir.file_exists("ModConfiguration.zip")):

		while config_loaded == false:
			if get_parent().has_node("Config_Scene"):
				var config_node = get_parent().get_node("Config_Scene")
				var config_file = config_node.MakeConfig("kinitonoboot",config)
				config = config_node.values
				config_loaded = true
			yield(get_tree().create_timer(0.1,false),"timeout")
	else:
		print("[no-boot] Can not find Mod Configuration, using default settings")
		config_loaded = true
	pass

var ran_no_boot = false
var in_pc_scene = false
func _process(delta):
	while !config_loaded: # _ready() has to wait up before the config is fully loaded
		yield(get_tree().create_timer(0.1,false),"timeout")
	if !in_pc_scene:
		if "PC" in get_parent().get_parent().get_node("0").get_child(0).name:
			in_pc_scene = true
			if config["GAME_SPEED"] and get_parent().get_parent().get_node("0").get_child(0).has_node("Aspect/DEVCONSOL"):
				if !get_parent().get_parent().get_node("0").get_child(0).get_node("Aspect/DEVCONSOL/LineEdit").speedTime:
					print("[no-boot] Turning on speed mode")
					get_parent().get_parent().get_node("0").get_child(0).get_node("Aspect/DEVCONSOL/LineEdit").speedTime = true
	if in_pc_scene and !("PC" in get_parent().get_parent().get_node("0").get_child(0).name):
		in_pc_scene = false
	if get_parent().get_parent().has_node("0/NROOT") and !ran_no_boot:
		if config["BOOT_TO"] == Boot_Type.PC:
			desktop_boot()
		elif config["BOOT_TO"] == Boot_Type.FUNFAIR:
			funfair_boot()
		elif config["BOOT_TO"] == Boot_Type.YOUR_HOME:
			your_home_boot()
	pass
	
func desktop_boot():
	print("[no-boot] detected boot screen, skipping to PC")
	ran_no_boot = true # we don't want to run this any more than once..
	get_parent().get_parent().get_node("0/NROOT/Aspect/Sprite").visible = false
	Tab.set_window_position(0, Vector2(0,0))
	App._load()
	if App.data["dskhide"] == 0:
		Desktop.ToggleDesktopIcons()
	yield(get_tree().create_timer(0.5), "timeout")
	print("[no-boot] Chapter = " + str(config["BOOT_CHAPTER"]))
	if config["BOOT_CHAPTER"] == str(ScenePoints.SAVE):
		print("[no-boot] Going to saved state")
		Tab.scene("res://-Scenes/Application000/Main/PC.tscn")
	elif config["BOOT_CHAPTER"] != str(ScenePoints.SAVE):
		print("[no-boot] Selected Chapter: " + config["BOOT_CHAPTER"])
		Data._save("sp",int(config["BOOT_CHAPTER"]))
		yield(get_tree().create_timer(0.5), "timeout")
		print("[no-boot] Saved chapter: " + Tab.sp)
		Tab.scene("res://-Scenes/Application000/Main/PC.tscn")
	pass
	
func funfair_boot():
	print("[no-boot] detected boot screen, starting your_world")
	ran_no_boot = true # we don't want to run this any more than once..
	get_parent().get_parent().get_node("0/NROOT/Aspect/Sprite").visible = false
	Tab.set_window_position(0, Vector2(0,0))
	App._load()
	
	if config["PLAYER_NAME"] != "":
		print("[no-boot] replacing player name")
		Data.data["name"] = config["PLAYER_NAME"]
	if App.data["dskhide"] == 0:
		Desktop.ToggleDesktopIcons()
	yield(get_tree().create_timer(0.5), "timeout")
	App._externalAction(10,0)
	App._yourworldData("FUNFAIR_StartReady")
	while str(App.data["data"][4]) != "FUNFAIR_move":
		yield(get_tree(), "idle_frame")
	App._yourworldData("FUNFAIR_TrainAppear")
	pass
	
func your_home_boot():
	print("[no-boot] detected boot screen, starting your_world")
	ran_no_boot = true # we don't want to run this any more than once..
	get_parent().get_parent().get_node("0/NROOT/Aspect/Sprite").visible = false
	Tab.set_window_position(0, Vector2(0,0))
	Settings.settings.Recording == true
	App._load()
	
	if App.data["dskhide"] == 0:
		Desktop.ToggleDesktopIcons()
	yield(get_tree().create_timer(0.5), "timeout")
	$SaveFriends._saveFriends()
	
	# Since this mod can't communicate with the your_world / second monitor window.
	# The game has to constantly save and reload the Active data
	App._externalAction(10,0)
	App._yourworldData("FUNFAIR_StartReady")
	while str(App.data["data"][4]) != "FUNFAIR_StartGame":
		yield(get_tree(), "idle_frame")
	yield(get_tree().create_timer(2), "timeout")
	App._yourworldData("FUNFAIR_TrainAppear")
	yield(get_tree().create_timer(2), "timeout")
	App._yourworldData("FUNFAIR_CoasterGo")
	yield(get_tree().create_timer(4), "timeout")
	App._yourworldData("FUNFAIR_CoasterStart")
	# Here, we set the config values...
	yield(get_tree().create_timer(29), "timeout") # it takes 30 seconds for the coaster to do it's thing and an extra 10 seconds for it to enter into the world
	_set_house_vars()
	# You will have to wait like 30 seconds for the coaster to run in the background...
	print("[no-boot] world type: " + Vars.get("HOUSE_world"))
	# During the coaster tunnel in the world
	while str(App.data["data"][4]) != "HOUSE_land":
		yield(get_tree(), "idle_frame")

	yield(get_tree().create_timer(1), "timeout")
	App._yourworldData("HOUSE_Xready")
	App.recording = true
	yield(get_tree().create_timer(2), "timeout")
	print("[no-boot] recording: " + str(App.recording))
	App._yourworldData("HOUSE_houseready")
	yield(get_tree().create_timer(10.0), "timeout")
	pass

func _set_house_vars():
	if config["WORLD_TYPE"] != "":
		print("[no-boot] Setting world type: " + config["WORLD_TYPE"])
		Vars.set("HOUSE_world", str(config["WORLD_TYPE"]))
	if config["WORLD_SEASON"] != "":
		print("[no-boot] Setting world season")
		Vars.set("HOUSE_season", str(config["WORLD_SEASON"]))
	if config["BED_COLOUR"] != "":
		print("[no-boot] Setting bed / player colour")
		Vars.set("HOUSE_favcolour", config["BED_COLOUR"])
	if config["PET_TYPE"] != "":
		print("[no-boot] Setting pet type")
		Vars.set("HOUSE_pettype", config["PET_TYPE"])
	if config["PET_NAME"] != "":
		print("[no-boot] Setting pet name")
		Vars.set("HOUSE_petname", config["PET_NAME"])
	if config["HOUSE_SUPER"] != "":
		print("[no-boot] Setting player's superpower")
		Vars.set("HOUSE_superpower", config["HOUSE_SUPER"])
	if config["HOUSE_FOOD"] != "":
		print("[no-boot] Setting player's favourate food")
		# Add a little web api search and return them into logs.
		Vars.set("HOUSE_favfood", config["HOUSE_FOOD"])
	if config["HOUSE_GAME"] != "":
		print("[no-boot] Setting player's favourate game")
		# Add start menu shortcut check here.
		Vars.set("HOUSE_favgame", config["HOUSE_GAME"])
	if config["PLAYER_BIRTHDAY"] != "":
		print("[no-boot] Setting player's birthday to: " + config["PLAYER_BIRTHDAY"] == "True")
		Vars.set("HOUSE_birthday", config["PLAYER_BIRTHDAY"] == "True")
	pass

class Colour:
	const RED = "Red"
	
class WORLD_TYPE:
	const FIELD = "Field"
	const ISLAND = "Island"
	const FOREST = "Forest"
class World_Season:
	const AUTUMN = "Autumn"
	const SUMMER = "Summer"
	const WINTER = "Winter"
class Boot_Type:
	const PC = "PC"
	const FUNFAIR = "FUNFAIR"
	const YOUR_HOME = "YOUR_HOME"
	
class ScenePoints:
	enum {
		PROLOUGE,
		HATCH_KINITO,
		INTRODUCTIONS, # I'm kinito, and i am your super duper... then name and color and Story
		WEB_WORLD, # Includes Ready Repair
		FACTORY_FRENZY,
		HIDE_AND_SEEK,
		FEEDBACK_HUB,
		SURVEY, # Includes MS Paint Scare (Officially called "Painting Problems")
		BUILD_A_WORLD,
		PERSONAL_QUESTIONS, # Possibly rename this, this is the OBS / webcam scare and useless questions.
		FRIENDSHIP_CLUB,
		PERMISSIONS, # the game doesn't like to keep on this save point for too long...
		YOUR_WORLD,
		SAVE
	}

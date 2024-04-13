extends Node
var steamdata = {}

func _saveFriends():
	if(App.steamWorking == true):
		var dir := Directory.new()
		dir.make_dir("user://.steam/")
		var friendCount = Steam.getFriendCount()
		if friendCount > 1:
			for i in clamp(friendCount,0,8):
				var steam_id = Steam.getFriendByIndex((i),Steam.FRIEND_FLAG_ALL)
				var name = str(Steam.getFriendPersonaName(steam_id))
				steamdata[str(i)] = name
				
				_id_to_image(steam_id).get_data().save_png("user://.steam/"+str(i)+".data")
		save_data()



func save_data():
	var file = File.new()
	file.open("user://.steam/friends.data", File.WRITE)
	file.store_line(to_json(steamdata))
	file.close()

func _id_to_image(steam_id):
	var IMAGE: Dictionary = Steam.getImageSize(Steam.getMediumFriendAvatar(steam_id))
	var IMAGE_DATA: Dictionary = Steam.getImageRGBA(Steam.getMediumFriendAvatar(steam_id))

	var AVATAR: Image = Image.new()
	var AVATAR_TEXTURE: ImageTexture = ImageTexture.new()
	AVATAR.create(IMAGE['width'], IMAGE['height'], false, Image.FORMAT_RGBAF)
	var size = 64
	AVATAR.lock()
	if IMAGE_DATA.has("buffer"):
		for y in range(0, size):
			for x in range(0, size):
				var pixel: int = 4 * (x + y * size)
				var r: float = float(IMAGE_DATA['buffer'][pixel]) / 255
				var g: float = float(IMAGE_DATA['buffer'][pixel+1]) / 255
				var b: float = float(IMAGE_DATA['buffer'][pixel+2]) / 255
				var a: float = float(IMAGE_DATA['buffer'][pixel+3]) / 255
				AVATAR.set_pixel(x, y, Color(r, g, b, a))
	AVATAR.unlock()
	AVATAR_TEXTURE.create_from_image(AVATAR)
	return AVATAR_TEXTURE

package;

/*
	Aw hell yeah! something I can actually work on!
 */
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import meta.CoolUtil;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import sys.FileSystem;
import sys.io.File;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import openfl.display3D.textures.Texture;

class Paths
{
	// Here we set up the paths class. This will be used to
	// Return the paths of assets and call on those assets as well.
	inline public static var SOUND_EXT = "ogg";

	// level we're loading
	static var currentLevel:String;

	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
	public static var uniqueRAMImages:Array<String> = [];
    public static var uniqueVRMImages:Array<String> = [];
	public static var expectedMemoryBytes:Float = 0;
	public static var localTrackedAssets:Array<String> = [];
	public static var dumpExclusions:Array<String> =
	[
		'assets/music/freakyMenu.$SOUND_EXT',
		'assets/shared/music/breakfast.$SOUND_EXT',
		'assets/shared/music/foreverMenu.$SOUND_EXT',
	];

	// set the current level top the condition of this function if called
	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	//
	static function getPath(file:String, type:AssetType, library:Null<String>)
	{
		/*
				Okay so, from what I understand, this loads in the current path based on the level
				we're in (if a library is not specified), say like week 1 or something, 
				then checks if the assets you're looking for are there.
				if not, it checks the shared assets folder.
			// */

		// well I'm rewriting it so that the library is the path and it looks for the file type
		// later lmao I don't really wanna rn

		if (library != null)
			return getLibraryPath(file, library);

		/*
			if (currentLevel != null)
			{
				levelPath = getLibraryPathForce(file, currentLevel);
				if (OpenFlAssets.exists(levelPath, type))
					return levelPath;

				levelPath = getLibraryPathForce(file, "shared");
				if (OpenFlAssets.exists(levelPath, type))
					return levelPath;
		}*/

		var levelPath = getLibraryPathForce(file, "mods");
		if (OpenFlAssets.exists(levelPath, type))
			return levelPath;

		return getPreloadPath(file);
	}

	// files!
	// this is how I'm gonna do it, considering it's much cleaner in my opinion

	/*
		inline static public function returnFileType(fileName:String, ?library:String, fileExtension:String)
		{
			// I don't really use haxe so bare with me
			var returnFile:String = "$" + fileName + "." + fileExtension;
			return getPath()
	}//*/
	/*  
		actually I could just combine all of these main functions into one and really call it a day
		it's similar and would use one function with a switch case
		for now I'm more focused on getting this to run than anything and I'll clean out the code later as I do want to organise
		everything later 
	 */
	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library/$file';
	}

	public inline static function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function offsetTxt(key:String, ?library:String)
	{
		return getPath('images/characters/$key.txt', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('songs/$key.json', TEXT, library);
	}

	inline static public function songJson(song:String, secondSong:String, ?library:String)
		return getPath('songs/${song.toLowerCase()}/${secondSong.toLowerCase()}.json', TEXT, library);

	static public function sound(key:String, ?library:String)
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String)
	{
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function voices(song:String)
	{
		var voicePath = 'songs/${song.toLowerCase()}/Voices.$SOUND_EXT';
		if (!FileSystem.exists(getPath(voicePath, MUSIC, null)))
		{
			voicePath = 'songs/${CoolUtil.swapSpaceDash(song.toLowerCase())}/Voices.$SOUND_EXT';
		}
		return getPath(voicePath, MUSIC, null);
	}

	inline static public function inst(song:String)
	{
		var instPath = 'songs/${song.toLowerCase()}/Inst.$SOUND_EXT';
		if (!FileSystem.exists(getPath(instPath, MUSIC, null)))
		{
			instPath = 'songs/${CoolUtil.swapSpaceDash(song.toLowerCase())}/Inst.$SOUND_EXT';
		}
		return getPath(instPath, MUSIC, null);
	}

	inline static public function image(key:String, ?library:String)
	{
		return getPath('images/$key.png', IMAGE, library);
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		return (FlxAtlasFrames.fromSparrow(image(key, library), File.getContent(file('images/$key.xml', library))));
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		return (FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library)));
	}

	inline static public function getContent(asset:String):Null<String>
	{
		#if sys
		if (FileSystem.exists(asset))
			return File.getContent(asset);
		#else
		if (Assets.exists(asset))
			return Assets.getText(asset);
		#end

		return null;
	}


	static function getExpectedMemory(){
		expectedMemoryBytes = 0;

		var processed:Array<FlxGraphic> =[];

		@:privateAccess
		for (key in FlxG.bitmap._cache.keys())
		{
			var obj = FlxG.bitmap._cache.get(key);
			if (processed.contains(obj) || uniqueVRMImages.contains(key))continue;
			expectedMemoryBytes += obj.width * obj.height * 4;
			processed.push(obj);
		}
		for (key in currentTrackedAssets.keys())
		{
			var obj = currentTrackedAssets.get(key);
			if (processed.contains(obj) || uniqueVRMImages.contains(key))continue;
			expectedMemoryBytes += obj.width * obj.height * 4;
			processed.push(obj);
		}
		processed = null;
    }

	public static function returnGraphic(key:String, ?library:String, throwToGPU:Bool = false, ?prefix:String = 'images')
		{
			// if (!ClientPrefs.useGPUCaching)
			// 	throwToGPU = false;
	
			var path = getPath('$prefix/$key.png', IMAGE, library);
			var bitmap:BitmapData = null;
	
			if(currentTrackedAssets.exists(path)){
				if (throwToGPU && !uniqueVRMImages.contains(path)){
					if (!localTrackedAssets.contains(path) && !dumpExclusions.contains(path))
					{
						// get rid of it
						var obj = currentTrackedAssets.get(path);
						@:privateAccess
						if (obj != null)
						{
							openfl.Assets.cache.removeBitmapData(path);
							FlxG.bitmap._cache.remove(path);
							obj.destroy();
							currentTrackedAssets.remove(path);
							if (uniqueRAMImages.contains(path))uniqueRAMImages.remove(path);
							if (uniqueVRMImages.contains(path))uniqueVRMImages.remove(path);
						}
					}
				}else{
					localTrackedAssets.push(path);
					return currentTrackedAssets.get(path);
				}
			}
			
			if(OpenFlAssets.exists(path, IMAGE))
				bitmap = OpenFlAssets.getBitmapData(path);
			
			if(bitmap != null){
				if(throwToGPU){
					// based on what smokey learnt + my own research
					// should be fine? idk lole
					var tex:Texture = FlxG.stage.context3D.createTexture(bitmap.width, bitmap.height, BGRA, false);
					tex.uploadFromBitmapData(bitmap);
					// free mem
					bitmap.dispose();
					bitmap.disposeImage();
					// push shit
					bitmap = BitmapData.fromTexture(tex);
					if (!uniqueVRMImages.contains(path))uniqueVRMImages.push(path);
					uniqueRAMImages.remove(path);
				}else{
					if (!uniqueRAMImages.contains(path))uniqueRAMImages.push(path);
					
					uniqueVRMImages.remove(path);
				}
	
				@:privateAccess
				var grafic = FlxGraphic.createGraphic(bitmap, key, false, false);
				grafic.persist = true;
				grafic.destroyOnNoUse = false;
				localTrackedAssets.push(path);
				currentTrackedAssets.set(path, grafic);
				getExpectedMemory();
				return grafic;
			}
			return null;
		}
}

package gameObjects.userInterface;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import sys.FileSystem;
import flixel.math.FlxMath;

using StringTools;

class HealthIcon extends FlxSprite
{
	// rewrite using da new icon system as ninjamuffin would say it
	public var sprTracker:FlxSprite;
	public var initialWidth:Float = 0;
	public var initialHeight:Float = 0;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		updateIcon(char, isPlayer);
	}

	public function updateIcon(char:String = 'bf', isPlayer:Bool = false)
	{
		var trimmedCharacter:String = char;
		if (trimmedCharacter.contains('-'))
			trimmedCharacter = trimmedCharacter.substring(0, trimmedCharacter.indexOf('-'));

		var iconPath = char;
		while (!FileSystem.exists(Paths.image('icons/icon-' + iconPath))) {
			if (iconPath != trimmedCharacter)
				iconPath = trimmedCharacter;
			else
				iconPath = 'face';
		}

		antialiasing = true;
		var iconGraphic:FlxGraphic = FlxG.bitmap.add(Paths.image('icons/icon-' + iconPath));
		loadGraphic(iconGraphic, true, Std.int(iconGraphic.width / 2), iconGraphic.height);

		initialWidth = width;
		initialHeight = height;

		animation.add('icon', [0, 1, 2], 0, false, isPlayer);
		animation.play('icon');
		scrollFactor.set();
	}

	public function bop(elapsed:Float)
	{
		var mult:Float = FlxMath.lerp(1, scale.x, FlxMath.bound(1 - (elapsed * 9), 0, 1));
		scale.set(mult, mult);
		updateHitbox();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}

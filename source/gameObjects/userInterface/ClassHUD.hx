package gameObjects.userInterface;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import meta.CoolUtil;
import meta.InfoHud;
import meta.data.Conductor;
import meta.data.Timings;
import meta.state.PlayState;
import Main;

using StringTools;

class ClassHUD extends FlxTypedGroup<FlxBasic>
{
	// set up variables and stuff here
	var infoBar:FlxText; // small side bar like kade engine that tells you engine info
	var scoreBar:FlxText;

	var scoreLast:Float = -1;
	var scoreDisplay:String;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var SONG = PlayState.SONG;
	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	private var stupidHealth:Float = 0;
	var icon_Zoom_Lerp = 0.045;

	// eep
	public function new()
	{
		// call the initializations and stuffs
		super();

		// fnf mods
		var scoreDisplay:String = 'beep bop bo skdkdkdbebedeoop brrapadop';

		// le healthbar setup
		var barY = FlxG.height * 0.875;
		if (Init.trueSettings.get('Downscroll'))
			barY = 64;

		healthBarBG = new FlxSprite(0,
			barY).loadGraphic(Paths.image(ForeverTools.returnSkinAsset('healthBar', PlayState.assetModifier, PlayState.changeableSkin, 'UI')));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8));
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		// healthBar
		add(healthBar);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		scoreBar = new FlxText(FlxG.width / 2, healthBarBG.y + 40, 0, scoreDisplay, 20);
		scoreBar.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		updateScoreText();
		scoreBar.scrollFactor.set();
		add(scoreBar);

		// small info bar, kinda like the KE watermark
		// based on scoretxt which I will set up as well
		var infoDisplay:String = CoolUtil.dashToSpace(PlayState.SONG.song) + ' - ' + CoolUtil.difficultyFromNumber(PlayState.storyDifficulty);
		var engineDisplay:String = "Forever Engine BETA v" + Main.gameVersion;
		var engineBar:FlxText = new FlxText(0, FlxG.height - 30, 0, engineDisplay, 16);
		engineBar.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		engineBar.updateHitbox();
		engineBar.x = FlxG.width - engineBar.width - 5;
		engineBar.scrollFactor.set();
		add(engineBar);

		infoBar = new FlxText(5, FlxG.height - 30, 0, infoDisplay, 20);
		infoBar.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		infoBar.scrollFactor.set();
		add(infoBar);
	}

	override public function update(elapsed:Float)
	{
		// pain, this is like the 7th attempt
		healthBar.percent = (PlayState.health * 50);

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (iconP1.width == 450)
			iconP1.animation.curAnim.curFrame = healthBar.percent < 20 ? 1 : healthBar.percent > 80 ? 2 : 0;
		else if (iconP1.width == 300)
			iconP1.animation.curAnim.curFrame = healthBar.percent < 20 ? 1 : 0;
		else if (iconP1.width == 150)
			iconP1.animation.curAnim.curFrame = 0;

		if (iconP2.width == 450)
			iconP2.animation.curAnim.curFrame = healthBar.percent > 20 ? 1 : healthBar.percent < 20 ? 2 : 0;
		else if (iconP2.width == 300)
			iconP2.animation.curAnim.curFrame = healthBar.percent > 20 ? 1 : 0;
		else if (iconP2.width == 150)
			iconP2.animation.curAnim.curFrame = 0;

		iconP1.bop(elapsed);
		iconP2.bop(elapsed);
	}

	private final divider:String = ' - ';

	public function updateScoreText()
	{
		var importSongScore = PlayState.songScore;
		var importPlayStateCombo = PlayState.combo;
		var importMisses = PlayState.misses;
		scoreBar.text = 'Score: $importSongScore';
		// testing purposes
		var displayAccuracy:Bool = Init.trueSettings.get('Display Accuracy');
		if (displayAccuracy)
		{
			scoreBar.text += divider + 'Accuracy: ' + Std.string(Math.floor(Timings.getAccuracy() * 100) / 100) + '%' + Timings.comboDisplay;
			scoreBar.text += divider + 'Combo Breaks: ' + Std.string(PlayState.misses);
			scoreBar.text += divider + 'Rank: ' + Std.string(Timings.returnScoreRating().toUpperCase());
		}

		scoreBar.x = ((FlxG.width / 2) - (scoreBar.width / 2));

		// update playstate
		PlayState.detailsSub = scoreBar.text;
		PlayState.updateRPC(false);
	}

	public function beatHit()
	{
		if (!Init.trueSettings.get('Reduced Movements'))
		{
			iconP1.setGraphicSize(Std.int(iconP1.width + 30));
			iconP1.updateHitbox();
			iconP2.setGraphicSize(Std.int(iconP2.width + 30));
			iconP2.updateHitbox();
		}
		//
	}
}

package meta.scripting;


import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import haxe.ds.StringMap;
import meta.scripting.HScript.Script;
import meta.scripting.HScript.ScriptManager;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxBasic;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import sys.io.File;
import flixel.util.FlxColor;
import gameObjects.userInterface.notes.Note;
import meta.state.PlayState;

enum abstract AssetType(String) to String {
    var IMAGE = 'image';
    var ATLAS = 'atlas';
    var SOUND = 'sound';
    var TEXT = 'text';
}

class ScriptConstructor extends FlxTypedGroup<FlxBasic>
{
    // Attach some metadata to the new Stage
    public var script:Script;
    public var foreground : FlxTypedGroup<FlxBasic>;

    // Incase you aren't aware already of what this is gonna do, its basically just gonna allow for hscript functionality with stages lol.
    public function new(dir : String, file : String)
    {
        super();

        foreground = new FlxTypedGroup<FlxBasic>();

        var additionalParams : StringMap<Dynamic> = new StringMap<Dynamic>();
        additionalParams.set('add', add);
        additionalParams.set('stage', this);
        additionalParams.set('foreground', foreground);
        additionalParams.set('PlayState', PlayState.instance);
        additionalParams.set('retrieveAsset', function(path : String, assetType : AssetType, ?useGPU:Bool):Dynamic {
            // this is retarded lol
            switch (assetType) {
                case IMAGE:
					return Paths.returnGraphic(path, null, useGPU == null ? false : useGPU, dir);
                case ATLAS:
					//return Paths.getSparrowAtlas(path, null, useGPU == null ? true : useGPU, dir);
                    return Paths.getSparrowAtlas(path, null);
                case SOUND:
                    return Paths.sound(path, null);
                case TEXT:
                    return Paths.getContent('assets/$dir/$path');
            }
        });

        // additionalParams.set('triggerEvent', function(name:String, arg1:Dynamic, arg2:Dynamic) {
        //     var value1:String = arg1;
        //     var value2:String = arg2;
        //     PlayState.instance.triggerEventNote(name, value1, value2);
        // });

        // additionalParams.set('debugPrint', function(text:String) {
        //     PlayState.instance.addTextToDebug(text, FlxColor.RED);
        // });

		additionalParams.set('getScript', PlayState.instance.getScript);
		additionalParams.set('getScriptVar', PlayState.instance.getScriptVar);

        script = ScriptManager.loadScript('assets/${dir}/${file}.hx', null, additionalParams); // Change the file extension here to change what file extension scripts use.

        try{
            if (script != null && script.exists("onCreate"))
                script.get("onCreate")();
        }catch(e:Dynamic){
            trace(e);
        }
    }

    override function update(elapsed:Float) 
        {
            super.update(elapsed);
            if (script != null && script.exists("update"))
                script.get("update")(elapsed);
        }

    public function onCreate()
        if (script != null && script.exists("create"))
            script.get("create")();

    public function onEvent(event:String, value1:String, value2:String)
        if (script != null && script.exists("onEvent"))
            script.get("onEvent")(event, value1, value2);

    public function opponentNoteHit(index:Int, dir:Float, isSus:Bool)
        if (script != null && script.exists("opponentNoteHit"))
            script.get("opponentNoteHit")(index, dir, isSus);

    public function goodNoteHit(index:Int, dir:Float, isSus:Bool)
        if (script != null && script.exists("goodNoteHit"))
            script.get("goodNoteHit")(index, dir, isSus);

    public function noteMiss(note:Note)
        if (script != null && script.exists("noteMiss"))
            script.get("noteMiss")(note);

    public function onStepHit(curStep : Int)
        if (script != null && script.exists("stepHit"))
            script.get("stepHit")(curStep);
    
    public function onBeatHit(curBeat : Int)
        if (script != null && script.exists("beatHit"))
            script.get("beatHit")(curBeat);
    public function onStartCountdown()
        if (script != null && script.exists("startCountdown"))
            script.get("startCountdown")();
    public function onSongStart()
        if (script != null && script.exists("songStart"))
            script.get("songStart")();
    public function onEndSong()
        if (script != null && script.exists("endSong"))
            script.get("endSong")();
    public function onPause()
        if (script != null && script.exists("pause"))
            {
                script.get("pause")();
                FlxTween.globalManager.forEach(function( tween : FlxTween ) {
                    tween.active = false;
                });
            }
    public function onResume()
        if (script != null && script.exists("onResume"))
            {
                script.get("onResume")();
                FlxTween.globalManager.forEach(function( tween : FlxTween ) {
                    tween.active = true;
                });
            }
    public function onGameOver()
        if (script != null && script.exists("gameOver"))
            script.get("gameOver")();
    public function onMoveCamera(focus : String)
        if (script != null && script.exists("onMoveCamera"))
            script.get("onMoveCamera")(focus);
    public function onCountdownTick(counter : Int)
        if (script != null && script.exists("countdownTick"))
            script.get("countdownTick")(counter);
}
package flixel.addons.ui;

import flixel.FlxSprite;
import flixel.addons.ui.interfaces.IFlxUIWidget;

class FlxUIPopup extends FlxSprite implements IFlxUIWidget
{
    public var name:String = "";
    public var groupName:String = "";
    public var broadcastToFlxUI:Bool = false;

    public var callback:Void->Void;

    public function new(callback:Void->Void = null)
    {
        super();
        this.callback = callback;

        // Example setup for the popup sprite (optional)
        makeGraphic(100, 50, 0xFF000000); // A black box by default
        scrollFactor.set(0, 0);
        visible = false;
    }

    public function show():Void
    {
        visible = true;
        if (callback != null) callback();
    }

    public function hide():Void
    {
        visible = false;
    }

    // Optional: if you want to toggle the popup
    public function toggle():Void
    {
        visible = !visible;
        if (visible && callback != null) callback();
    }
}

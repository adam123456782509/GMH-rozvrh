import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

var screenMessage;
var lastText;

class RozvrhhodinKeyboard extends WatchUi.View {


    var textPicker;
    var text;
    var typedtext;

    function initialize() {
        WatchUi.View.initialize();
        if(Toybox.Application.getApp().getProperty("API_KEY") != null) {
            typedtext = Toybox.Application.getApp().getProperty("API_KEY");
        } else {
            typedtext = "";
        }
    }

    function onShow() {

        textPicker = new WatchUi.TextPicker(typedtext);

        WatchUi.switchToView(textPicker,new RozvrhhodinKeyboardDelegate(),SLIDE_IMMEDIATE);
    }
}

class RozvrhhodinKeyboardDelegate extends WatchUi.PickerDelegate {
    function initialize() {
        PickerDelegate.initialize();
    }


    function onTextEntered(text, changed) as Void {
        Toybox.Application.getApp().setProperty("API_KEY", text);
        WatchUi.switchToView(
            new RozvrhhodinConfirmIntegrated(),
            new RozvrhhodinConfirmIntegratedDelegate(),
            WatchUi.SLIDE_LEFT
        );
    }
    

    function onCancel() as Boolean {//TODO: přidat funkci pro zjištění zda bylo stisknuto tlačítko zpět a pokud ano vrátit se na nastavení
        switchToView(
            new RozvrhhodinSettingsButton(),
            new RozvrhhodinSettingsButtonBehaviorDelagate(),
            WatchUi.SLIDE_RIGHT
        );
    
        return true;
    }
}
import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

class RozvrhhodinConfirmIntegrated extends WatchUi.View {

    var dialog;
    var typedtext;

    function initialize()
    {
        View.initialize();
        if(Toybox.Application.getApp().getProperty("API_KEY") != null)
        {
            typedtext = Toybox.Application.getApp().getProperty("API_KEY");
        }else{
            typedtext = "";
        }
    }

    function onShow() as Void {//TODO: přidat klíč a vylepšit otázku
        var message = "Zadaný klíč je: " + typedtext;
        dialog = new WatchUi.Confirmation(message);
        WatchUi.switchToView(
        dialog,
        new RozvrhhodinConfirmIntegratedDelegate(),
        WatchUi.SLIDE_IMMEDIATE
        );
    }

}


class RozvrhhodinConfirmIntegratedDelegate extends ConfirmationDelegate {


    function initialize() {
       ConfirmationDelegate.initialize();
    }

    function onResponse(response){
        if(response == WatchUi.CONFIRM_NO)
        {
            
                WatchUi.switchToView(
                    new RozvrhhodinKeyboard(),
                    new RozvrhhodinKeyboardDelegate(),
                    WatchUi.SLIDE_RIGHT
                );
        
        }
        else{
            if (Toybox.Application.getApp().getProperty("Teacher") != null
                ) // pokud není null i učitel tak dělá request
                {
                    WatchUi.switchToView(
                        new RozvrhhodinLoading(),
                        new RozvrhhodinLoadingInput(),
                        WatchUi.SLIDE_IMMEDIATE
                    );
                } else {
                    WatchUi.switchToView(
                        new RozvrhhodinSettingsButton(),
                        new RozvrhhodinSettingsButtonBehaviorDelagate(),
                        WatchUi.SLIDE_RIGHT
                    );
                }
        }
        return false;
    }
}
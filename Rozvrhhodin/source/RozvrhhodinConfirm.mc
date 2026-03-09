import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

class RozvrhhodinConfirm extends WatchUi.View {
    var typedText;
    var confirmIco;
    var backIco;

    function initialize() {
        View.initialize();
        if (
            Toybox.Application.getApp().getProperty("API_KEY") != null
        ) //pokud exituje uložená hodnota načte ji
        {
            typedText = Toybox.Application.getApp().getProperty("API_KEY");
        } else {
            typedText = "";
        }
    }

    function onUpdate(dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK); //nastavení barev pro překreslení textu

        dc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight()); //překreslení textu černou aby nebyl vidět funkce dc.clear() nedělá nic
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT); //nastavení barev
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() * 0.25,
            Graphics.FONT_MEDIUM,
            "Zadaný klíč je:",
            Graphics.TEXT_JUSTIFY_CENTER
        ); // text menu
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() * 0.4,
            Graphics.FONT_MEDIUM,
            typedText,
            Graphics.TEXT_JUSTIFY_CENTER
        ); //zobrazení klíče

        dc.drawBitmap(
            (dc.getWidth() * 3) / 4 - confirmIco.getWidth() / 2,
            dc.getHeight() * 0.75 - confirmIco.getHeight(),
            confirmIco
        ); //tlačítko pro potvrzení API klíče
        dc.drawBitmap(
            (dc.getWidth() * 1) / 4 - backIco.getWidth() / 2,
            dc.getHeight() * 0.75 - backIco.getHeight(),
            backIco
        ); //tlačítko pro zrušení
    }

    function onLayout(dc as Dc) as Void {
        //načtení ikon pro tlačítka
        confirmIco =
            WatchUi.loadResource(Rez.Drawables.Confirm) as
            Graphics.BitmapResource;
        backIco =
            WatchUi.loadResource(Rez.Drawables.Cancel) as
            Graphics.BitmapResource;
    }
}

class RozvrhhodinConfirmInput extends BehaviorDelegate {
    //input pro confirm view

    var displayHeight;
    var displayWidth;

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onTap(evt) as Boolean {
        //zjištění rozměrů displeje(při každém dotyku displeje takže ->TODO: optimalizovat) a zjištění zda bylo kliknuto na potvrdit nebo zrušit
        displayHeight =
            Toybox.Application.getApp().getProperty("displayHeight");
        displayWidth = Toybox.Application.getApp().getProperty("displayWidth");

        var xy = evt.getCoordinates();

        if (
            xy[1] >
            displayHeight * 0.5
        ) //pokud je kliknuto na spodní část obrazovky
        {
            if (xy[0] > displayWidth / 2) //pokud je kliknuto vpravo potvrdit
            {
                if (
                    Toybox.Application.getApp().getProperty("Teacher") != null
                ) // pokud není null i učitel tak nedělá request
                {
                    WatchUi.switchToView(
                        new RozvrhhodinLoading(),
                        new RozvrhhodinLoadingInput(),
                        WatchUi.SLIDE_BLINK
                    );
                } else {
                    WatchUi.switchToView(
                        new RozvrhhodinSettings(),
                        new RozvrhhodinSettingsInput(),
                        WatchUi.SLIDE_RIGHT
                    );
                }
            } else //pokud je kliknuto vlevo zrušit
            {
                WatchUi.switchToView(
                    new RozvrhhodinT9Keyboard(),
                    new RozvrhhodinT9KeyboardInput(),
                    WatchUi.SLIDE_LEFT
                );
                Toybox.Application.getApp().setProperty("API_KEY", "");
            }
        }
        return false;
    }
}

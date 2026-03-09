import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

class RozvrhhodinSettings extends WatchUi.View {
    var Teacher;
    var displayHeight;

    function initialize() {
        View.initialize();
    }

    function onShow() {}

    function onUpdate(dc) as Void {
        if (displayHeight == null) //načtve výšku a sířku displeje
        {
            displayHeight = dc.getHeight();
            Toybox.Application.getApp().setProperty(
                "displayHeight",
                displayHeight
            );
        }

        if (
            Toybox.Application.getApp().getProperty("Teacher") != null
        ) //pokud exituje uložená hodnota pro nastavení studenta/ učitele, načte ji
        {
            Teacher = Toybox.Application.getApp().getProperty("Teacher");
        }

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK); //nastavení barev pro překreslení textu

        dc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight()); //překreslení textu černou aby nebyl vidět funkce dc.clear() nefunguje/nedělá nic

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT); //nastavení barev pro text

        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() * 0.06,
            Graphics.FONT_SMALL,
            "nastavení",
            Graphics.TEXT_JUSTIFY_CENTER
        ); //název menu

        if (
            Teacher == null
        ) //zobrazení nastavení učitel nebo žák, podle uložené hodnoty
        {
            dc.drawText(
                dc.getWidth() / 2,
                dc.getHeight() * 0.25,
                Graphics.FONT_MEDIUM,
                "Jsem: neurčeno",
                Graphics.TEXT_JUSTIFY_CENTER
            );
        } else if (Teacher == true) {
            dc.drawText(
                dc.getWidth() / 2,
                dc.getHeight() * 0.25,
                Graphics.FONT_MEDIUM,
                "Jsem: učitel",
                Graphics.TEXT_JUSTIFY_CENTER
            );
        } else {
            dc.drawText(
                dc.getWidth() / 2,
                dc.getHeight() * 0.25,
                Graphics.FONT_MEDIUM,
                "Jsem: žák",
                Graphics.TEXT_JUSTIFY_CENTER
            );
        }

        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() * 0.75 - dc.getFontHeight(Graphics.FONT_MEDIUM),
            Graphics.FONT_MEDIUM,
            "Můj API klíč",
            Graphics.TEXT_JUSTIFY_CENTER
        ); //tlačítko pro nastavení API klíče
    }
}

class RozvrhhodinSettingsInput extends BehaviorDelegate {
    //input

    var displayHeight;
    var Teacher;

    function initialize() {
        //načtení inputu
        BehaviorDelegate.initialize();
        Teacher = Toybox.Application.getApp().getProperty("Teacher");
    }

    function onKey(keyEvent as KeyEvent) as Boolean {
        if (
            keyEvent.getKey() == 5
        ) //použité tlačítko zpět -> říct systému že má reagovat normálně (vrátit se zpět)
        {
            WatchUi.switchToView(
                new RozvrhhodinView(),
                new RozvrhhodinInput(),
                WatchUi.SLIDE_RIGHT
            );
            return true;
        } else {
            return false; //ostatní -> systém nereaguje (např. nejde otervřít menu s aktivitami atd.)
        }
    }

    function onTap(evt) as Boolean {
        //tlačítko změny učitele/žáka, funkční pouze pro dotykové hodinky
        var xy = evt.getCoordinates();
        if (displayHeight == null) {
            displayHeight =
                Toybox.Application.getApp().getProperty("displayHeight");
        }

        if (xy[1] < displayHeight / 2) {
            //pokud je klik v horní části displeje tak měním hodnotu Teacher x Student
            if (Teacher == false) {
                Toybox.Application.getApp().setProperty("Teacher", true);
                Teacher = true;
                requestUpdate();
            } else {
                Toybox.Application.getApp().setProperty("Teacher", false);
                Teacher = false;
                requestUpdate();
            }
        } else {
            //v dolní části otevřu klávesnici
            WatchUi.switchToView(
                new RozvrhhodinT9Keyboard(),
                new RozvrhhodinT9KeyboardInput(),
                WatchUi.SLIDE_LEFT
            );
        }
        return true;
    }
}

import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;
using Toybox.Timer;
using Toybox.Attention;

class RozvrhhodinT9Keyboard extends WatchUi.View {
    var typedText = "";
    var CharactersShown = [
        "abc",
        "def",
        "ghi", //sseznam znaků pro tlačítka
        "jkl",
        "mno",
        "pqr",
        "stu",
        "vw",
        "xyz",
        "ABC",
        "DEF",
        "GHI",
        "JKL",
        "MNO",
        "PQR",
        "STU",
        "VW",
        "XYZ",
        "123",
        "456",
        "789",
        "-_=",
        "0[]",
        "$?!",
        "*{}",
        ":#,",
        ".()",
    ];
    var Characters = [];
    var capsOn = 0;
    var displayWidth;
    var displayHeight;

    var confirmIco;
    var keyboardModeIco;
    var spaceIco;
    var backspaceIco;

    function initialize() {
        //inicializace view
        View.initialize();
    }

    function onLayout(dc as Dc) as Void {
        //načtení ikon pro tlačítka
        confirmIco =
            WatchUi.loadResource(Rez.Drawables.Confirm) as
            Graphics.BitmapResource;
        keyboardModeIco =
            WatchUi.loadResource(Rez.Drawables.KeyboardMode) as
            Graphics.BitmapResource;
        spaceIco =
            WatchUi.loadResource(Rez.Drawables.Space) as
            Graphics.BitmapResource;
        backspaceIco =
            WatchUi.loadResource(Rez.Drawables.Backspace) as
            Graphics.BitmapResource;
    }

    function onUpdate(dc) as Void {
        //vykreslení všechn polí a textu na tlačítkách

        if (
            displayHeight == null or
            displayWidth == null
        ) //pokud nebyl načten rozměr displeje, načte se
        {
            displayWidth = dc.getWidth();
            displayHeight = dc.getHeight();
            Toybox.Application.getApp().setProperty(
                "displayWidth",
                displayWidth
            );
            Toybox.Application.getApp().setProperty(
                "displayHeight",
                displayHeight
            );
        }

        capsOn = Toybox.Application.getApp().getProperty("Caps"); //načtení stavu caps locku
        if (
            Toybox.Application.getApp().getProperty("text") == null
        ) //pokud nebyl uložen text(api klíč), nastaví se na prázdný
        {
            typedText = "";
        } else {
            typedText = Toybox.Application.getApp().getProperty("text"); //jinak se načte uložený text
        }
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK); //nastavení barev pro překreslení textu

        dc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight()); //překreslení textu černou aby nebyl vidět funkce dc.clear() nedělá nic

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT); //nastavení barev pro text

        dc.drawText(
            dc.getWidth() / 2 + (dc.getHeight() / 100) * 5,
            (dc.getHeight() / 100) * 4.6,
            Graphics.FONT_SMALL,
            typedText.toString(),
            Graphics.TEXT_JUSTIFY_RIGHT
        ); //zobrazení napsaného textu (API klíče)

        dc.drawRectangle(
            (dc.getWidth() / 4) * 0,
            (dc.getHeight() / 5) * 1,
            dc.getWidth() / 4,
            dc.getHeight() / 5
        ); //následující kod vykresluje tlačítka (obdélníky a text na nich) a je opakován pro všech 9 tlačítek, změnou souřadnic a textu (abc, def, ghi)
        dc.drawText(
            dc.getWidth() / 8 + (dc.getHeight() / 100) * 2.5,
            (dc.getHeight() / 5) * 1 +
                dc.getFontHeight(Graphics.FONT_SMALL) / 3,
            Graphics.FONT_SMALL,
            CharactersShown[0 + capsOn],
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.drawRectangle(
            (dc.getWidth() / 4) * 1,
            (dc.getHeight() / 5) * 1,
            dc.getWidth() / 4,
            dc.getHeight() / 5
        );
        dc.drawText(
            (dc.getWidth() / 8) * 3,
            (dc.getHeight() / 5) * 1 +
                dc.getFontHeight(Graphics.FONT_SMALL) / 3,
            Graphics.FONT_SMALL,
            CharactersShown[1 + capsOn],
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.drawRectangle(
            (dc.getWidth() / 4) * 2,
            (dc.getHeight() / 5) * 1,
            dc.getWidth() / 4,
            dc.getHeight() / 5
        );
        dc.drawText(
            (dc.getWidth() / 8) * 5,
            (dc.getHeight() / 5) * 1 +
                dc.getFontHeight(Graphics.FONT_SMALL) / 3,
            Graphics.FONT_SMALL,
            CharactersShown[2 + capsOn],
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.drawRectangle(
            (dc.getWidth() / 4) * 0,
            (dc.getHeight() / 5) * 2,
            dc.getWidth() / 4,
            dc.getHeight() / 5
        ); //jkl, mno, pqr
        dc.drawText(
            dc.getWidth() / 8 + (dc.getHeight() / 100) * 2.5,
            (dc.getHeight() / 5) * 2 +
                dc.getFontHeight(Graphics.FONT_SMALL) / 3,
            Graphics.FONT_SMALL,
            CharactersShown[3 + capsOn],
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.drawRectangle(
            (dc.getWidth() / 4) * 1,
            (dc.getHeight() / 5) * 2,
            dc.getWidth() / 4,
            dc.getHeight() / 5
        );
        dc.drawText(
            (dc.getWidth() / 8) * 3,
            (dc.getHeight() / 5) * 2 +
                dc.getFontHeight(Graphics.FONT_SMALL) / 3,
            Graphics.FONT_SMALL,
            CharactersShown[4 + capsOn],
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.drawRectangle(
            (dc.getWidth() / 4) * 2,
            (dc.getHeight() / 5) * 2,
            dc.getWidth() / 4,
            dc.getHeight() / 5
        );
        dc.drawText(
            (dc.getWidth() / 8) * 5,
            (dc.getHeight() / 5) * 2 +
                dc.getFontHeight(Graphics.FONT_SMALL) / 3,
            Graphics.FONT_SMALL,
            CharactersShown[5 + capsOn],
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.drawRectangle(
            (dc.getWidth() / 4) * 0,
            (dc.getHeight() / 5) * 3,
            dc.getWidth() / 4,
            dc.getHeight() / 5
        ); //stu, vw, xyz
        dc.drawText(
            dc.getWidth() / 8 + (dc.getHeight() / 100) * 2.5,
            (dc.getHeight() / 5) * 3 +
                dc.getFontHeight(Graphics.FONT_SMALL) / 3,
            Graphics.FONT_SMALL,
            CharactersShown[6 + capsOn],
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.drawRectangle(
            (dc.getWidth() / 4) * 1,
            (dc.getHeight() / 5) * 3,
            dc.getWidth() / 4,
            dc.getHeight() / 5
        );
        dc.drawText(
            (dc.getWidth() / 8) * 3,
            (dc.getHeight() / 5) * 3 +
                dc.getFontHeight(Graphics.FONT_SMALL) / 3,
            Graphics.FONT_SMALL,
            CharactersShown[7 + capsOn],
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.drawRectangle(
            (dc.getWidth() / 4) * 2,
            (dc.getHeight() / 5) * 3,
            dc.getWidth() / 4,
            dc.getHeight() / 5
        );
        dc.drawText(
            (dc.getWidth() / 8) * 5,
            (dc.getHeight() / 5) * 3 +
                dc.getFontHeight(Graphics.FONT_SMALL) / 3,
            Graphics.FONT_SMALL,
            CharactersShown[8 + capsOn],
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.drawRectangle(
            (dc.getWidth() / 4) * 3,
            (dc.getHeight() / 5) * 1,
            dc.getWidth() / 4,
            (dc.getHeight() / 5) * 3
        ); //tlačítko potvrzení
        dc.drawBitmap(
            (dc.getWidth() / 8) * 7 - confirmIco.getWidth() / 2,
            dc.getHeight() / 2 - confirmIco.getHeight() / 2,
            confirmIco
        );

        dc.drawRectangle(
            (dc.getWidth() / 2) * 0,
            (dc.getHeight() / 5) * 4,
            dc.getWidth() / 2,
            dc.getHeight() / 5
        ); //tlačítko mezery
        dc.drawBitmap(
            (dc.getWidth() / 8) * 3 - spaceIco.getWidth() / 2,
            (dc.getHeight() / 10) * 9 - spaceIco.getHeight() / 2,
            spaceIco
        );

        dc.drawRectangle(
            (dc.getWidth() / 2) * 1,
            (dc.getHeight() / 5) * 4,
            dc.getWidth() / 2,
            dc.getHeight() / 5
        ); //tlačítko capslocku
        dc.drawBitmap(
            (dc.getWidth() / 8) * 5 - keyboardModeIco.getWidth() / 2,
            (dc.getHeight() / 10) * 9 - keyboardModeIco.getHeight() / 2,
            keyboardModeIco
        );

        dc.drawBitmap(
            (dc.getWidth() / 10) * 7 - backspaceIco.getWidth() / 2,
            dc.getHeight() / 10 - backspaceIco.getHeight() / 2,
            backspaceIco
        ); //tlačítko backspace (není ohraničen pomocí dc.drawRectangle, protože by to vypadalo divně, je za zobrazeným textem)
    }
}

class RozvrhhodinT9KeyboardInput extends BehaviorDelegate {
    //input

    var displayHeight;
    var displayWidth;
    var capsOn = 0;
    var typedText = "";

    var timer = new Timer.Timer();

    var keyPressed = 0;

    var abcPressed = 0;
    var defPressed = 3;
    var ghiPressed = 6;
    var jklPressed = 9;
    var mnoPressed = 12;
    var pqrPressed = 15;
    var stuPressed = 18;
    var vwPressed = 21;
    var xyzPressed = 24;

    var Characters = [
        //DVAKRÁT "w" A "W" z důvodu nestejného poměru znaků u všech tlačítek (3 nebo 2) funkce klávesnice se nemění ale je lehčí napragramovat(nemusím řešit zda je zapnutý caps lock a tím pádem odečítat 1 navíc kvůli posuntí z důvodu nedokonalého poměru) jestli můj popis dává smysl :)
        "a",
        "b",
        "c",
        "d",
        "e",
        "f",
        "g",
        "h",
        "i",
        "j",
        "k",
        "l",
        "m",
        "n",
        "o",
        "p",
        "q",
        "r",
        "s",
        "t",
        "u",
        "v",
        "w",
        "w",
        "x",
        "y",
        "z",
        "A",
        "B",
        "C",
        "D",
        "E",
        "F",
        "G",
        "H",
        "I",
        "J",
        "K",
        "L",
        "M",
        "N",
        "O",
        "P",
        "Q",
        "R",
        "S",
        "T",
        "U",
        "V",
        "W",
        "W",
        "X",
        "Y",
        "Z",
        "1",
        "2",
        "3",
        "4",
        "5",
        "6",
        "7",
        "8",
        "9",
        "-",
        "_",
        "=",
        "0",
        "[",
        "]",
        "$",
        "?",
        "!",
        "*",
        "{",
        "}",
        ":",
        "#",
        ",",
        ".",
        "(",
        ")",
    ];

    function initialize() {
        BehaviorDelegate.initialize(); //inicializace inputu
        Toybox.Application.getApp().setProperty("Caps", capsOn); //nastavení stavu caps locku na vypnutý při načtení klávesnice
        if (
            Toybox.Application.getApp().getProperty("text") != null
        ) //pokud je text uložen tak se načte
        {
            typedText = Toybox.Application.getApp().getProperty("text");
        } else {
            typedText = "";
        }
    }

    function onTap(evt) as Boolean {
        displayHeight =
            Toybox.Application.getApp().getProperty("displayHeight"); //načtení rozměrů displeje (při každém dotyku displeje takže ->TODO: optimalizovat)
        displayWidth = Toybox.Application.getApp().getProperty("displayWidth");

        if (Attention has :vibrate) {
            //vibrace při stisku tlačítka, pokud to hodinky podporují
            Attention.vibrate([new Attention.VibeProfile(50, 100)]);
        }

        var xy = evt.getCoordinates();

        switch (
            Toybox.Math.round(xy[1] / (displayHeight / 5)) //zjištění které tlačítko bylo zmáčknuto a podle toho se změní text/potvrzení textu atd.
        ) {
            case 0:
                if (
                    xy[0] > (displayWidth / 5) * 3 &&
                    xy[0] < (displayWidth / 5) * 4
                ) //backspace
                {
                    removeCharacter();
                }
                break;
            case 1:
                if (xy[0] < displayWidth / 4) {
                    //abc
                    keyPressed = 1;
                    abcPressed++;
                    timer.start(method(:timerCallback), 500, false);
                } else if (
                    xy[0] > displayWidth / 4 &&
                    xy[0] < displayWidth / 2
                ) {
                    //def
                    keyPressed = 2;
                    defPressed++;
                    timer.start(method(:timerCallback), 500, false);
                } else if (
                    xy[0] > displayWidth / 2 &&
                    xy[0] < (displayWidth / 4) * 3
                ) {
                    //ghi
                    keyPressed = 3;
                    ghiPressed++;
                    timer.start(method(:timerCallback), 500, false);
                } else if (xy[0] > displayWidth / 4 && xy[0] < displayWidth) {
                    confirm();
                }
                break;
            case 2: //4 dílky
                if (xy[0] < displayWidth / 4) {
                    //jkl
                    keyPressed = 4;
                    jklPressed++;
                    timer.start(method(:timerCallback), 500, false);
                } else if (
                    xy[0] > displayWidth / 4 &&
                    xy[0] < displayWidth / 2
                ) {
                    //mno
                    keyPressed = 5;
                    mnoPressed++;
                    timer.start(method(:timerCallback), 500, false);
                } else if (
                    xy[0] > displayWidth / 2 &&
                    xy[0] < (displayWidth / 4) * 3
                ) {
                    //pqr
                    keyPressed = 6;
                    pqrPressed++;
                    timer.start(method(:timerCallback), 500, false);
                } else if (xy[0] > displayWidth / 4 && xy[0] < displayWidth) {
                    confirm();
                }
                break;
            case 3: //4 dílky
                if (xy[0] < displayWidth / 4) {
                    //stu
                    keyPressed = 7;
                    stuPressed++;
                    timer.start(method(:timerCallback), 500, false);
                } else if (
                    xy[0] > displayWidth / 4 &&
                    xy[0] < displayWidth / 2
                ) {
                    //vw
                    keyPressed = 8;
                    vwPressed++;
                    timer.start(method(:timerCallback), 500, false);
                } else if (
                    xy[0] > displayWidth / 2 &&
                    xy[0] < (displayWidth / 4) * 3
                ) {
                    //xyz
                    keyPressed = 9;
                    xyzPressed++;
                    timer.start(method(:timerCallback), 500, false);
                } else if (xy[0] > displayWidth / 4 && xy[0] < displayWidth) {
                    confirm();
                }
                break;
            case 4: //2 dílky
                if (xy[0] < displayWidth / 2) //mezera
                {
                    addCharacter(" ");
                } else if (xy[0] > displayWidth / 2) //capslock
                {
                    ToggleCapsLock();
                }
                break;
            default: //mimo display(nemožné) nebo mimo všechny tlačítka např. na text
                break;
        }
        return false;
    }

    function timerCallback() as Void {
        //metoda která je volaná 500ms po prvním zmáčknutí tlačítka, aby byla možnost napsat druhé a třetí písmeno toho tlačítka (počet zmáčknutí tlačítka v tomto časovém úseku určuje které písmeno z toho tlačítka se napíše 1 = první, 2 = druhé, 3 a více = třetí)
        switch (keyPressed) {
            case 1:
                if (abcPressed > 3) {
                    abcPressed = 3;
                }
                addCharacter(Characters[abcPressed + capsOn * 3 - 1]);
                abcPressed = 0;
                break;
            case 2:
                if (defPressed > 6) {
                    defPressed = 6;
                }
                addCharacter(Characters[defPressed + capsOn * 3 - 1]);
                defPressed = 3;
                break;
            case 3:
                if (ghiPressed > 9) {
                    ghiPressed = 9;
                }
                addCharacter(Characters[ghiPressed + capsOn * 3 - 1]);
                ghiPressed = 6;
                break;
            case 4:
                if (jklPressed > 12) {
                    jklPressed = 12;
                }
                addCharacter(Characters[jklPressed + capsOn * 3 - 1]);
                jklPressed = 9;
                break;
            case 5:
                if (mnoPressed > 15) {
                    mnoPressed = 15;
                }
                addCharacter(Characters[mnoPressed + capsOn * 3 - 1]);
                mnoPressed = 12;
                break;
            case 6:
                if (pqrPressed > 18) {
                    pqrPressed = 18;
                }
                addCharacter(Characters[pqrPressed + capsOn * 3 - 1]);
                pqrPressed = 15;
                break;
            case 7:
                if (stuPressed > 21) {
                    stuPressed = 21;
                }
                addCharacter(Characters[stuPressed + capsOn * 3 - 1]);
                stuPressed = 18;
                break;
            case 8:
                if (vwPressed > 24) {
                    vwPressed = 24;
                }
                addCharacter(Characters[vwPressed + capsOn * 3 - 1]);
                vwPressed = 21;
                break;
            case 9:
                if (xyzPressed > 27) {
                    xyzPressed = 27;
                }
                addCharacter(Characters[xyzPressed + capsOn * 3 - 1]);
                xyzPressed = 24;
                break;
            default:
                break;
        }

        requestUpdate(); //po napsání znaku se překreslí view aby se zobrazil napsaný znak
    }

    function ToggleCapsLock() {
        //0 = malá písmena, 9 = velká písmena, 18 = znaky a cyklování mezi těmito třemi stavy
        if (capsOn == 0) {
            capsOn = 9;
        } else if (capsOn == 9) {
            capsOn = 18;
        } else {
            capsOn = 0;
        }

        Toybox.Application.getApp().setProperty("Caps", capsOn); //uložení stavu caps locku aby se zachoval při překreslení view
        requestUpdate();
    }

    function addCharacter(char) {
        //přidá znak předaný funkci dopředu aby se zapsal
        typedText = typedText + char;
        Toybox.Application.getApp().setProperty("text", typedText);
        requestUpdate();
    }

    function removeCharacter() {
        //odebere poslední znak
        typedText = typedText.substring(0, typedText.length() - 1);
        Toybox.Application.getApp().setProperty("text", typedText);
        requestUpdate();
    }

    function confirm() {
        //uloží vložený text jako API klíč

        Toybox.Application.getApp().setProperty("API_KEY", typedText);
        WatchUi.switchToView(
            new RozvrhhodinConfirm(),
            new RozvrhhodinConfirmInput(),
            WatchUi.SLIDE_LEFT
        );
    }

    function onKey(keyEvent as KeyEvent) as Boolean {
        if (
            keyEvent.getKey() == 5
        ) //použité tlačítko zpět -> říct systému že se má vrátit na stránku nastavení
        {
            WatchUi.switchToView(
                new RozvrhhodinSettings(),
                new RozvrhhodinSettingsInput(),
                WatchUi.SLIDE_RIGHT
            );
            return true;
        } else {
            return false; //ostatní -> systém nereaguje (např. nejde otervřít menu s aktivitami atd.)
        }
    }
}

import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Communications;
import Toybox.System;
import Toybox.Lang;
import Toybox.PersistedContent;
import Toybox.Time;
import Toybox.Media;
import Toybox.Application;
import Toybox.Timer;

class RozvrhhodinLoading extends WatchUi.View {
    function initialize() {
        //inicializace view
        View.initialize();
    }

    var progressBar;

    function onShow() {
        //zkontroluje zda je uložen api klíč a nastavení student X učitel, pokud ano spustí se načítací obrazovka a udělá request
        if (
            Application.getApp().getProperty("API_KEY") != null and
            Application.getApp().getProperty("Teacher") != null
        ) {
            progressBar = new WatchUi.ProgressBar(
                "Komunikace se\nserverem...",
                null
            );

            WatchUi.switchToView(
                progressBar,
                new RozvrhhodinLoadingInput(),
                WatchUi.SLIDE_LEFT
            );
        } else {
            WatchUi.switchToView(
                new RozvrhhodinView(),
                new RozvrhhodinInput(),
                WatchUi.SLIDE_IMMEDIATE
            );
        }
    }

    function onUpdate(dc) {}
}

class RozvrhhodinLoadingInput extends WatchUi.BehaviorDelegate {
    var url_permanent =
        "https://.../"; //změnit URL na oficiální AŽ bude možné
    var url_actual =
        "https://.../";
    var key = "";

    var url_permanent_full;
    var url_actual_full;
    var url = "";

    var failedRequest = false;

    var DownloadedContent;

    var Teacher;

    var app;

    var timer;

    function initialize() {
        BehaviorDelegate.initialize();
        app = Application.getApp();
        Setup();
    }

    function Setup() {
        if (
            app.getProperty("API_KEY") != null and
            app.getProperty("Teacher") != null
        ) //pokud existuje uložený API klíč a nastavení student/učitel spustí načítací obrazovku a udělá request
        {
            key = app.getProperty("API_KEY");
            Teacher = app.getProperty("Teacher");

            timer = new Timer.Timer();
            timer.start(method(:timerCallback), 3000, false); //timeout na 3s
            makeRequest();
        }
    }

    function makeRequest() as Void {
        //zjistí momentální den pro případ aktuálního rozvrhu a funkce pro získání dat z webového API

        if (Teacher != true) {
            url_permanent_full =
                url_permanent +
                "student/" +
                key +
                "?API_KEY=XXXX"; //TODO: zašifrovat API klíč a URL?
            url_actual_full =
                url_actual + "student/" + key + "?API_KEY=XXX";
        } else {
            url_permanent_full =
                url_permanent +
                "teacher/" +
                key +
                "?API_KEY=XXXX";
            url_actual_full =
                url_actual + "teacher/" + key + "?API_KEY=XXXX";
        }

        if (app.getProperty("dateOfdata") != null) {
            if (
                app.getProperty("dateOfdata") ==
                Time.Gregorian.info(
                    Time.now(),
                    Time.FORMAT_SHORT
                ).day_of_week.toNumber() -
                    2
            ) //pokud naposledy uložený den je dnes tak nastaví url na aktuální rozvrh/aktualizuje data
            {
                url = url_actual_full;
                app.setProperty("timetableIsPermanent", false);
            } else {
                //jinak dá url na stálý a načte stálý u celého týdne
                url = url_permanent_full;
                app.setProperty("timetableIsPermanent", true);
            }
        } else {
            url = url_permanent_full;
            app.setProperty("timetableIsPermanent", true);
        }

        var params = {};

        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :headers => {
                "Content-Type"
                =>
                Communications.REQUEST_CONTENT_TYPE_URL_ENCODED,
            },
            :responseType
            =>
            Communications.HTTP_RESPONSE_CONTENT_TYPE_TEXT_PLAIN,
            :timeout => 3000, // timeout na 3 sekundy
        };
        var responseCallback = method(:onReceive);

        app.setProperty(
            "dateOfdata",
            Time.Gregorian.info(
                Time.now(),
                Time.FORMAT_SHORT
            ).day_of_week.toNumber() - 2
        ); //uloží den kdy byla data stažena pro případné další použití
        Communications.makeWebRequest(url, params, options, responseCallback); //udělá request
    }

    function onReceive(
        responseCode as Number,
        data as String or Dictionary or Null
    ) as Void {
        if (responseCode == 200) {
            app.setProperty("DownloadedContent", data); //nastaví odpověď API jako downloadedContent a s tím se pracuje dále
            app.setProperty("failedRequest", false);
        } else {
            //pokud se request nezdaří zobrazí ho na obrazovce a načte data z paměti
            app.setProperty("DownloadedContent", responseCode);
            app.setProperty("failedRequest", true);
        }
    }

    function timerCallback() as Void {
        WatchUi.switchToView(
            new RozvrhhodinView(),
            new RozvrhhodinInput(),
            WatchUi.SLIDE_LEFT
        );
    }

    function onKey(keyEvent) {
        if (
            keyEvent.getKey() == 5
        ) //použité tlačítko zpět -> říct systému že má vypnout aplikaci
        {
            return false;
        } else {
            //ostatní -> systém nereaguje (např. nejde otervřít menu s aktivitami atd.)
            return false;
        }
    }
}

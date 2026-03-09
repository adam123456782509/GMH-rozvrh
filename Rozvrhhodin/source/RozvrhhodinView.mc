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

class RozvrhhodinView extends WatchUi.View {
    var url_permanent =
        "https://.../";
    var url_actual =
        "https://.../";
    var key = "";

    var url_permanent_full;
    var url_actual_full;
    var url = "";

    var failedRequest = false;

    var DownloadedContent;
    var classes = [];
    var Positions = [];
    var numberOfClasses = 1;
    var lenghtOfDone = 0;
    var timetableIsPermanent = true;

    var Monday = [];
    var Tuesday = [];
    var Wednesday = [];
    var Thursday = [];
    var Friday = [];

    var time;
    var date;

    var MondayExtractedSubject = new [10]; //maximální <HourIndex> je 10 (0 AŽ 9, nultá až 9 hodina)
    var MondayExtractedTeacher = new [10];
    var MondayExtractedRoom = new [10];
    var TuesdayExtractedSubject = new [10];
    var TuesdayExtractedTeacher = new [10];
    var TuesdayExtractedRoom = new [10];
    var WednesdayExtractedSubject = new [10];
    var WednesdayExtractedTeacher = new [10];
    var WednesdayExtractedRoom = new [10];
    var ThursdayExtractedSubject = new [10];
    var ThursdayExtractedTeacher = new [10];
    var ThursdayExtractedRoom = new [10];
    var FridayExtractedSubject = new [10];
    var FridayExtractedTeacher = new [10];
    var FridayExtractedRoom = new [10];
    var Teacher;

    var ongoingHour;

    var settingsIco;

    var pageIndex = 0; //index posunutí zobrazení hodiny

    var classTimes = [
        //časy od nulté hodiny do 9 pro zobrazení podle ongoingHour, podle dokumentace API bakalářu obsahuje každá hodina časy ale není tomu tak.
        "7:00 - 7:45",
        "8:00 - 8:45",
        "8:55 - 9:40",
        "9:55 - 10:40",
        "10:50 - 11:35",
        "11:45 - 12:30",
        "12:35 - 13:20",
        "13:25 - 14:10",
        "14:15 - 15:00",
        "15:05 - 15:50",
    ];

    var app; //id aplikace aby mohly data být uloženy a načteny mezi glancem a aplikací a nastavením

    function sortClasses() {
        for (var i = 0; i < numberOfClasses; ) {
            //Rozdělí jednotlivé hodiny do vlastní proměnné (classes[i]), v každé je "<dayIndex>...</DayIndex>" a <HourIndex>...</HourIndex>" atd. + potřebná data na zobrazení
            if (DownloadedContent.find("<TimetableCell>") == null) {
                numberOfClasses = numberOfClasses - 1;
                break;
            }

            Positions.add(DownloadedContent.find("<TimetableCell>"));
            Positions.add(DownloadedContent.find("</TimetableCell>") + 16);

            classes.add(
                DownloadedContent.substring(Positions[0], Positions[1])
            );
            DownloadedContent = DownloadedContent.substring(Positions[1], null);

            Positions = [];
            numberOfClasses++;
            i = i + 1;
        }
        sortDays();
    }

    function sortDays() {
        //rozdělení hodin do dnů v týdnu (aktuální rozvrh má 0 jako den kdy byl request odeslán, permanentní rozvrh má 0 jako pondělí)

        date =
            Time.Gregorian.info(
                Time.now(),
                Time.FORMAT_SHORT
            ).day_of_week.toNumber() - 2; // 0 = pondělí ... 5 = sobota ... 6 = neděle (odčítání -2 docíli aby 0 = pondělí)

        for (var i = 0; i < classes.size(); i++) {
            if (timetableIsPermanent == true) {
                //rozdělení hodin do dnů v týdnu (aktuální rozvrh má 0 jako den kdy byl request odeslán, permanentní rozvrh má 0 jako pondělí, také obsahuje pouze aktuální den, funkce je i tak připravena připravena pro více dnů)
                if (classes[i].find("<DayIndex>0</DayIndex>") != null) {
                    //pondělí
                    Monday.add(classes[i]);
                } else if (classes[i].find("<DayIndex>1</DayIndex>") != null) {
                    //úterý
                    Tuesday.add(classes[i]);
                } else if (classes[i].find("<DayIndex>2</DayIndex>") != null) {
                    //středa
                    Wednesday.add(classes[i]);
                } else if (classes[i].find("<DayIndex>3</DayIndex>") != null) {
                    //čtvrtek
                    Thursday.add(classes[i]);
                } else if (classes[i].find("<DayIndex>4</DayIndex>") != null) {
                    //pátek
                    Friday.add(classes[i]);
                }
            } else {
                //rozdělení hodin do dnů v týdnu pro aktuální rozvrh
                if (date == 0) {
                    Monday.add(classes[i]);
                } else if (date == 1) {
                    Tuesday.add(classes[i]);
                } else if (date == 2) {
                    Wednesday.add(classes[i]);
                } else if (date == 3) {
                    Thursday.add(classes[i]);
                } else if (date == 4) {
                    Friday.add(classes[i]);
                }
            }
        }

        extractData();
    }

    function extractData() {
        //vyhledá v každé hodině např. <HourIndex> a </HourIndex> a číslo mezi nimi použije jako index arraye ve kterém jsou uloženy všechny hodiny v ten den (3 arraye 1x místnosti, 1x hodina a 1x učitel)
        for (var i = 0; i < Monday.size(); i++) {
            MondayExtractedSubject[
                Monday[i]
                    .substring(
                        Monday[i].find("<HourIndex>") + 11,
                        Monday[i].find("</HourIndex>")
                    )
                    .toNumber() - 2
            ] = Monday[i].substring(
                Monday[i]
                    .substring(Monday[i].find("<Subject>"), null)
                    .find("<Abbrev>") +
                    8 +
                    Monday[i].find("<Subject>"),
                Monday[i]
                    .substring(Monday[i].find("<Subject>"), null)
                    .find("</Abbrev>") + Monday[i].find("<Subject>")
            );

            MondayExtractedTeacher[
                Monday[i]
                    .substring(
                        Monday[i].find("<HourIndex>") + 11,
                        Monday[i].find("</HourIndex>")
                    )
                    .toNumber() - 2
            ] = Monday[i].substring(
                Monday[i]
                    .substring(Monday[i].find("<Teacher>"), null)
                    .find("<Abbrev>") +
                    8 +
                    Monday[i].find("<Teacher>"),
                Monday[i]
                    .substring(Monday[i].find("<Teacher>"), null)
                    .find("</Abbrev>") + Monday[i].find("<Teacher>")
            );

            MondayExtractedRoom[
                Monday[i]
                    .substring(
                        Monday[i].find("<HourIndex>") + 11,
                        Monday[i].find("</HourIndex>")
                    )
                    .toNumber() - 2
            ] = Monday[i].substring(
                Monday[i]
                    .substring(Monday[i].find("<Room>"), null)
                    .find("<Abbrev>") +
                    8 +
                    Monday[i].find("<Room>"),
                Monday[i]
                    .substring(Monday[i].find("<Room>"), null)
                    .find("</Abbrev>") + Monday[i].find("<Room>")
            );
        }

        for (var i = 0; i < Tuesday.size(); i++) {
            TuesdayExtractedSubject[
                Tuesday[i]
                    .substring(
                        Tuesday[i].find("<HourIndex>") + 11,
                        Tuesday[i].find("</HourIndex>")
                    )
                    .toNumber() - 2
            ] = Tuesday[i].substring(
                Tuesday[i]
                    .substring(Tuesday[i].find("<Subject>"), null)
                    .find("<Abbrev>") +
                    8 +
                    Tuesday[i].find("<Subject>"),
                Tuesday[i]
                    .substring(Tuesday[i].find("<Subject>"), null)
                    .find("</Abbrev>") + Tuesday[i].find("<Subject>")
            );

            TuesdayExtractedTeacher[
                Tuesday[i]
                    .substring(
                        Tuesday[i].find("<HourIndex>") + 11,
                        Tuesday[i].find("</HourIndex>")
                    )
                    .toNumber() - 2
            ] = Tuesday[i].substring(
                Tuesday[i]
                    .substring(Tuesday[i].find("<Teacher>"), null)
                    .find("<Abbrev>") +
                    8 +
                    Tuesday[i].find("<Teacher>"),
                Tuesday[i]
                    .substring(Tuesday[i].find("<Teacher>"), null)
                    .find("</Abbrev>") + Tuesday[i].find("<Teacher>")
            );

            TuesdayExtractedRoom[
                Tuesday[i]
                    .substring(
                        Tuesday[i].find("<HourIndex>") + 11,
                        Tuesday[i].find("</HourIndex>")
                    )
                    .toNumber() - 2
            ] = Tuesday[i].substring(
                Tuesday[i]
                    .substring(Tuesday[i].find("<Room>"), null)
                    .find("<Abbrev>") +
                    8 +
                    Tuesday[i].find("<Room>"),
                Tuesday[i]
                    .substring(Tuesday[i].find("<Room>"), null)
                    .find("</Abbrev>") + Tuesday[i].find("<Room>")
            );
        }

        for (var i = 0; i < Wednesday.size(); i++) {
            WednesdayExtractedSubject[
                Wednesday[i]
                    .substring(
                        Wednesday[i].find("<HourIndex>") + 11,
                        Wednesday[i].find("</HourIndex>")
                    )
                    .toNumber() - 2
            ] = Wednesday[i].substring(
                Wednesday[i]
                    .substring(Wednesday[i].find("<Subject>"), null)
                    .find("<Abbrev>") +
                    8 +
                    Wednesday[i].find("<Subject>"),
                Wednesday[i]
                    .substring(Wednesday[i].find("<Subject>"), null)
                    .find("</Abbrev>") + Wednesday[i].find("<Subject>")
            );

            WednesdayExtractedTeacher[
                Wednesday[i]
                    .substring(
                        Wednesday[i].find("<HourIndex>") + 11,
                        Wednesday[i].find("</HourIndex>")
                    )
                    .toNumber() - 2
            ] = Wednesday[i].substring(
                Wednesday[i]
                    .substring(Wednesday[i].find("<Teacher>"), null)
                    .find("<Abbrev>") +
                    8 +
                    Wednesday[i].find("<Teacher>"),
                Wednesday[i]
                    .substring(Wednesday[i].find("<Teacher>"), null)
                    .find("</Abbrev>") + Wednesday[i].find("<Teacher>")
            );

            WednesdayExtractedRoom[
                Wednesday[i]
                    .substring(
                        Wednesday[i].find("<HourIndex>") + 11,
                        Wednesday[i].find("</HourIndex>")
                    )
                    .toNumber() - 2
            ] = Wednesday[i].substring(
                Wednesday[i]
                    .substring(Wednesday[i].find("<Room>"), null)
                    .find("<Abbrev>") +
                    8 +
                    Wednesday[i].find("<Room>"),
                Wednesday[i]
                    .substring(Wednesday[i].find("<Room>"), null)
                    .find("</Abbrev>") + Wednesday[i].find("<Room>")
            );
        }

        for (var i = 0; i < Thursday.size(); i++) {
            ThursdayExtractedSubject[
                Thursday[i]
                    .substring(
                        Thursday[i].find("<HourIndex>") + 11,
                        Thursday[i].find("</HourIndex>")
                    )
                    .toNumber() - 2
            ] = Thursday[i].substring(
                Thursday[i]
                    .substring(Thursday[i].find("<Subject>"), null)
                    .find("<Abbrev>") +
                    8 +
                    Thursday[i].find("<Subject>"),
                Thursday[i]
                    .substring(Thursday[i].find("<Subject>"), null)
                    .find("</Abbrev>") + Thursday[i].find("<Subject>")
            );

            ThursdayExtractedTeacher[
                Thursday[i]
                    .substring(
                        Thursday[i].find("<HourIndex>") + 11,
                        Thursday[i].find("</HourIndex>")
                    )
                    .toNumber() - 2
            ] = Thursday[i].substring(
                Thursday[i]
                    .substring(Thursday[i].find("<Teacher>"), null)
                    .find("<Abbrev>") +
                    8 +
                    Thursday[i].find("<Teacher>"),
                Thursday[i]
                    .substring(Thursday[i].find("<Teacher>"), null)
                    .find("</Abbrev>") + Thursday[i].find("<Teacher>")
            );

            ThursdayExtractedRoom[
                Thursday[i]
                    .substring(
                        Thursday[i].find("<HourIndex>") + 11,
                        Thursday[i].find("</HourIndex>")
                    )
                    .toNumber() - 2
            ] = Thursday[i].substring(
                Thursday[i]
                    .substring(Thursday[i].find("<Room>"), null)
                    .find("<Abbrev>") +
                    8 +
                    Thursday[i].find("<Room>"),
                Thursday[i]
                    .substring(Thursday[i].find("<Room>"), null)
                    .find("</Abbrev>") + Thursday[i].find("<Room>")
            );
        }

        for (var i = 0; i < Friday.size(); i++) {
            FridayExtractedSubject[
                Friday[i]
                    .substring(
                        Friday[i].find("<HourIndex>") + 11,
                        Friday[i].find("</HourIndex>")
                    )
                    .toNumber() - 2
            ] = Friday[i].substring(
                Friday[i]
                    .substring(Friday[i].find("<Subject>"), null)
                    .find("<Abbrev>") +
                    8 +
                    Friday[i].find("<Subject>"),
                Friday[i]
                    .substring(Friday[i].find("<Subject>"), null)
                    .find("</Abbrev>") + Friday[i].find("<Subject>")
            );

            FridayExtractedTeacher[
                Friday[i]
                    .substring(
                        Friday[i].find("<HourIndex>") + 11,
                        Friday[i].find("</HourIndex>")
                    )
                    .toNumber() - 2
            ] = Friday[i].substring(
                Friday[i]
                    .substring(Friday[i].find("<Teacher>"), null)
                    .find("<Abbrev>") +
                    8 +
                    Friday[i].find("<Teacher>"),
                Friday[i]
                    .substring(Friday[i].find("<Teacher>"), null)
                    .find("</Abbrev>") + Friday[i].find("<Teacher>")
            );

            FridayExtractedRoom[
                Friday[i]
                    .substring(
                        Friday[i].find("<HourIndex>") + 11,
                        Friday[i].find("</HourIndex>")
                    )
                    .toNumber() - 2
            ] = Friday[i].substring(
                Friday[i]
                    .substring(Friday[i].find("<Room>"), null)
                    .find("<Abbrev>") +
                    8 +
                    Friday[i].find("<Room>"),
                Friday[i]
                    .substring(Friday[i].find("<Room>"), null)
                    .find("</Abbrev>") + Friday[i].find("<Room>")
            );
        }

        save();
    }

    function initialize() {
        View.initialize();
        app = Toybox.Application.getApp();
    }

    function loadDataFromMemory() {
        var MoNullCheck = true;
        var TuNullCheck = true;
        var WeNullCheck = true;
        var ThNullCheck = true;
        var FrNullCheck = true;

        if (app.getProperty("saveDate") != null) {
            switch (app.getProperty("saveDate").toNumber()) {
                case 0:
                    app.setProperty("TuExRoom", null);
                    app.setProperty("TuExSubj", null);
                    app.setProperty("TuExTeach", null);
                    app.setProperty("WeExRoom", null);
                    app.setProperty("WeExSubj", null);
                    app.setProperty("WeExTeach", null);
                    app.setProperty("ThExRoom", null);
                    app.setProperty("ThExSubj", null);
                    app.setProperty("ThExTeach", null);
                    app.setProperty("FrExRoom", null);
                    app.setProperty("FrExSubj", null);
                    app.setProperty("FrExTeach", null);
                    break;
                case 1:
                    app.setProperty("MoExRoom", null);
                    app.setProperty("MoExSubj", null);
                    app.setProperty("MoExTeach", null);
                    app.setProperty("WeExRoom", null);
                    app.setProperty("WeExSubj", null);
                    app.setProperty("WeExTeach", null);
                    app.setProperty("ThExRoom", null);
                    app.setProperty("ThExSubj", null);
                    app.setProperty("ThExTeach", null);
                    app.setProperty("FrExRoom", null);
                    app.setProperty("FrExSubj", null);
                    app.setProperty("FrExTeach", null);
                    break;
                case 2:
                    app.setProperty("MoExRoom", null);
                    app.setProperty("MoExSubj", null);
                    app.setProperty("MoExTeach", null);
                    app.setProperty("TuExRoom", null);
                    app.setProperty("TuExSubj", null);
                    app.setProperty("TuExTeach", null);
                    app.setProperty("ThExRoom", null);
                    app.setProperty("ThExSubj", null);
                    app.setProperty("ThExTeach", null);
                    app.setProperty("FrExRoom", null);
                    app.setProperty("FrExSubj", null);
                    app.setProperty("FrExTeach", null);
                    break;
                case 3:
                    app.setProperty("MoExRoom", null);
                    app.setProperty("MoExSubj", null);
                    app.setProperty("MoExTeach", null);
                    app.setProperty("TuExRoom", null);
                    app.setProperty("TuExSubj", null);
                    app.setProperty("TuExTeach", null);
                    app.setProperty("WeExRoom", null);
                    app.setProperty("WeExSubj", null);
                    app.setProperty("WeExTeach", null);
                    app.setProperty("ThExRoom", null);
                    app.setProperty("ThExSubj", null);
                    app.setProperty("ThExTeach", null);
                    break;
                case 4:
                    app.setProperty("MoExRoom", null);
                    app.setProperty("MoExSubj", null);
                    app.setProperty("MoExTeach", null);
                    app.setProperty("TuExRoom", null);
                    app.setProperty("TuExSubj", null);
                    app.setProperty("TuExTeach", null);
                    app.setProperty("WeExRoom", null);
                    app.setProperty("WeExSubj", null);
                    app.setProperty("WeExTeach", null);
                    app.setProperty("ThExRoom", null);
                    app.setProperty("ThExSubj", null);
                    app.setProperty("ThExTeach", null);
                    break;
                default:
                    app.setProperty("MoExRoom", null);
                    app.setProperty("MoExSubj", null);
                    app.setProperty("MoExTeach", null);
                    app.setProperty("TuExRoom", null);
                    app.setProperty("TuExSubj", null);
                    app.setProperty("TuExTeach", null);
                    app.setProperty("WeExRoom", null);
                    app.setProperty("WeExSubj", null);
                    app.setProperty("WeExTeach", null);
                    app.setProperty("ThExRoom", null);
                    app.setProperty("ThExSubj", null);
                    app.setProperty("ThExTeach", null);
                    app.setProperty("FrExRoom", null);
                    app.setProperty("FrExSubj", null);
                    app.setProperty("FrExTeach", null);
                    break;
            }
        }

        if (app.getProperty("MoExRoom") != null) {
            for (var i = 0; i < 10; i = i + 1) {
                if (app.getProperty("MoExRoom")[i] != null) {
                    MoNullCheck = false;
                }
            }
        }

        if (app.getProperty("TuExRoom") != null) {
            for (var i = 0; i < 10; i = i + 1) {
                if (app.getProperty("TuExRoom")[i] != null) {
                    TuNullCheck = false;
                }
            }
        }

        if (app.getProperty("WeExRoom") != null) {
            for (var i = 0; i < 10; i = i + 1) {
                if (app.getProperty("WeExRoom")[i] != null) {
                    WeNullCheck = false;
                }
            }
        }

        if (app.getProperty("ThExRoom") != null) {
            for (var i = 0; i < 10; i = i + 1) {
                if (app.getProperty("ThExRoom")[i] != null) {
                    ThNullCheck = false;
                }
            }
        }

        if (app.getProperty("FrExRoom") != null) {
            for (var i = 0; i < 10; i = i + 1) {
                if (app.getProperty("FrExRoom")[i] != null) {
                    FrNullCheck = false;
                }
            }
        }

        if (MoNullCheck == false) {
            MondayExtractedRoom = app.getProperty("MoExRoom");
            MondayExtractedSubject = app.getProperty("MoExSubj");
            MondayExtractedTeacher = app.getProperty("MoExTeach");
        } else if (TuNullCheck == false) {
            TuesdayExtractedRoom = app.getProperty("TuExRoom");
            TuesdayExtractedSubject = app.getProperty("TuExSubj");
            TuesdayExtractedTeacher = app.getProperty("TuExTeach");
        } else if (WeNullCheck == false) {
            WednesdayExtractedRoom = app.getProperty("WeExRoom");
            WednesdayExtractedSubject = app.getProperty("WeExSubj");
            WednesdayExtractedTeacher = app.getProperty("WeExTeach");
        } else if (ThNullCheck == false) {
            ThursdayExtractedRoom = app.getProperty("ThExRoom");
            ThursdayExtractedSubject = app.getProperty("ThExSubj");
            ThursdayExtractedTeacher = app.getProperty("ThExTeach");
        } else if (FrNullCheck == false) {
            FridayExtractedRoom = app.getProperty("FrExRoom");
            FridayExtractedSubject = app.getProperty("FrExSubj");
            FridayExtractedTeacher = app.getProperty("FrExTeach");
        } else {
            MondayExtractedRoom = app.getProperty("MoExRoomPerm");
            TuesdayExtractedRoom = app.getProperty("TuExRoomPerm");
            WednesdayExtractedRoom = app.getProperty("WeExRoomPerm");
            ThursdayExtractedRoom = app.getProperty("ThExRoomPerm");
            FridayExtractedRoom = app.getProperty("FrExRoomPerm");

            MondayExtractedSubject = app.getProperty("MoExSubjPerm");
            TuesdayExtractedSubject = app.getProperty("TuExSubjPerm");
            WednesdayExtractedSubject = app.getProperty("WeExSubjPerm");
            ThursdayExtractedSubject = app.getProperty("ThExSubjPerm");
            FridayExtractedSubject = app.getProperty("FrExSubjPerm");

            MondayExtractedTeacher = app.getProperty("MoExTeachPerm");
            TuesdayExtractedTeacher = app.getProperty("TuExTeachPerm");
            WednesdayExtractedTeacher = app.getProperty("WeExTeachPerm");
            ThursdayExtractedTeacher = app.getProperty("ThExTeachPerm");
            FridayExtractedTeacher = app.getProperty("FrExTeachPerm");
        }
    }

    function makeRequest() {
        //zjistí momentální den pro případ aktuálního rozvrhu a funkce pro získání dat z webového API
        DownloadedContent = app.getProperty("DownloadedContent");
        timetableIsPermanent = app.getProperty("timetableIsPermanent");
        failedRequest = app.getProperty("failedRequest");
        key = app.getProperty("API_KEY");
        Teacher = app.getProperty("Teacher");
        if (failedRequest == false) {
            sortClasses();
        } else {
            loadDataFromMemory();
        }
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        //tady se témeř nic neděje v layoutu je pouze logo bakalářů které možná bude muset být odstraněno protože na něj nemám práva
        setLayout(Rez.Layouts.MainLayout(dc));
        settingsIco =
            WatchUi.loadResource(Rez.Drawables.settings) as
            Graphics.BitmapResource;
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        app.setProperty("pageIndex", 0);
        failedRequest = false;

        //loadDataFromMemory(); //načte data a udělá request, pokud request selže tak se použijí načtená data z paměti
        makeRequest();
    }

    // Update the view
    function onUpdate(dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight());

        View.onUpdate(dc); //tento řádek je podivný, calluje tuto funkci ale zároveň když je první nikdy se nazacyklí, je v základním projektu automaticky a v glanech tvoří černý obdélník z neznámého důvodu

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        time = System.getClockTime().hour * 60 + System.getClockTime().min; //aktuální čas v minutách od půlnoci

        date =
            Time.Gregorian.info(
                Time.now(),
                Time.FORMAT_SHORT
            ).day_of_week.toNumber() - 2; //aktualizace datumu/dne v týdnu

        ongoingHour = 0; //kdyby nebyla splněna žádná podmínka tak aby nebyl null (např. o víkendu)
        if (
            time <
            7 * 60 + 45
        ) //nastavení momentální hodiny (i přestávka před hodinou se počítá do této hodiny)
        {
            ongoingHour = 0;
        } else if (time < 8 * 60 + 45) {
            ongoingHour = 1;
        } else if (time < 9 * 60 + 40) {
            ongoingHour = 2;
        } else if (time < 10 * 60 + 40) {
            ongoingHour = 3;
        } else if (time < 11 * 60 + 35) {
            ongoingHour = 4;
        } else if (time < 12 * 60 + 30) {
            ongoingHour = 5;
        } else if (time < 13 * 60 + 20) {
            ongoingHour = 6;
        } else if (time < 14 * 60 + 10) {
            ongoingHour = 7;
        } else if (time < 15 * 60 + 0) {
            ongoingHour = 8;
        } else if (time < 15 * 60 + 50) {
            ongoingHour = 9;
        } else if (date != 5 && date != -1) {
            ongoingHour = 0; //aby ongoingHour nebyl null
            date = 10; //nemožná hodnota normálně z důvodu odlišení od soboty a neděle použita po konci všech hodin
        }
        app.setProperty("ongoingHour", ongoingHour);
        pageIndex = app.getProperty("pageIndex").toNumber();

        if (pageIndex + ongoingHour > 9) {
            //zabránění přečíslení indexu přes maximální počet hodin
            pageIndex--;
            app.setProperty("pageIndex", pageIndex);
        }
        dc.drawBitmap(
            (dc.getWidth() / (100).toFloat()) * 90.5 -
                settingsIco.getWidth() / 2,
            (dc.getHeight() / (100).toFloat()) * 27.5 -
                settingsIco.getWidth() / 2,
            settingsIco
        );

        if (Teacher != null and key != null) {
            if (failedRequest == true) {
                if (DownloadedContent == -104) {
                    dc.drawText(
                        dc.getWidth() / 2,
                        dc.getHeight() / 2 -
                            dc.getFontHeight(Graphics.FONT_LARGE),
                        Graphics.FONT_LARGE,
                        "Není připojeno\npřes Bluetooth",
                        Graphics.TEXT_JUSTIFY_CENTER
                    );
                } else if (
                    DownloadedContent == 500 or
                    DownloadedContent == -400
                ) {
                    dc.drawText(
                        dc.getWidth() / 2,
                        dc.getHeight() / 2 -
                            dc.getFontHeight(Graphics.FONT_MEDIUM),
                        Graphics.FONT_MEDIUM,
                        "Neplatná odpověď\nserveru",
                        Graphics.TEXT_JUSTIFY_CENTER
                    );
                } else {
                    dc.drawText(
                        dc.getWidth() / 2,
                        dc.getHeight() / 2 -
                            dc.getFontHeight(Graphics.FONT_LARGE),
                        Graphics.FONT_LARGE,
                        "kód API: " + DownloadedContent,
                        Graphics.TEXT_JUSTIFY_CENTER
                    );
                }
            } else {
                switch (
                    date //podle dne vybereme hodnotu kterou vyrendrujeme poté index podle ongoingHour
                ) {
                    case 0: //pondělí
                        if (
                            MondayExtractedRoom[
                                ongoingHour.toNumber() + pageIndex
                            ] == null
                        ) {
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() / 100) * 50,
                                Graphics.FONT_LARGE,
                                "Volná hodina",
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() / 100) * 75,
                                Graphics.FONT_LARGE,
                                classTimes[ongoingHour.toNumber() + pageIndex],
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                        } else {
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() / 100) * 25,
                                Graphics.FONT_LARGE,
                                MondayExtractedRoom[
                                    ongoingHour.toNumber() + pageIndex
                                ],
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() / 100) * 50,
                                Graphics.FONT_LARGE,
                                MondayExtractedSubject[
                                    ongoingHour.toNumber() + pageIndex
                                ] +
                                    " - " +
                                    MondayExtractedTeacher[
                                        ongoingHour.toNumber() + pageIndex
                                    ],
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() / 100) * 75,
                                Graphics.FONT_LARGE,
                                classTimes[ongoingHour.toNumber() + pageIndex],
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                        }
                        break;

                    case 1: //úterý
                        if (
                            TuesdayExtractedRoom[
                                ongoingHour.toNumber() + pageIndex
                            ] == null
                        ) {
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() / 100) * 50,
                                Graphics.FONT_LARGE,
                                "Volná hodina",
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() / 100) * 75,
                                Graphics.FONT_LARGE,
                                classTimes[ongoingHour.toNumber() + pageIndex],
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                        } else {
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() / 100) * 25,
                                Graphics.FONT_LARGE,
                                TuesdayExtractedRoom[
                                    ongoingHour.toNumber() + pageIndex
                                ],
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() / 100) * 50,
                                Graphics.FONT_LARGE,
                                TuesdayExtractedSubject[
                                    ongoingHour.toNumber() + pageIndex
                                ] +
                                    " - " +
                                    TuesdayExtractedTeacher[
                                        ongoingHour.toNumber() + pageIndex
                                    ],
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() / 100) * 75,
                                Graphics.FONT_LARGE,
                                classTimes[ongoingHour.toNumber() + pageIndex],
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                        }
                        break;
                    case 2: //středa
                        if (
                            WednesdayExtractedRoom[
                                ongoingHour.toNumber() + pageIndex
                            ] == null
                        ) {
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() / 100) * 50,
                                Graphics.FONT_LARGE,
                                "Volná hodina",
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() / 100) * 75,
                                Graphics.FONT_LARGE,
                                classTimes[ongoingHour.toNumber() + pageIndex],
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                        } else {
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() / 100) * 25,
                                Graphics.FONT_LARGE,
                                WednesdayExtractedRoom[
                                    ongoingHour.toNumber() + pageIndex
                                ],
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() / 100) * 50,
                                Graphics.FONT_LARGE,
                                WednesdayExtractedSubject[
                                    ongoingHour.toNumber() + pageIndex
                                ] +
                                    " - " +
                                    WednesdayExtractedTeacher[
                                        ongoingHour.toNumber() + pageIndex
                                    ],
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() / 100) * 75,
                                Graphics.FONT_LARGE,
                                classTimes[ongoingHour.toNumber() + pageIndex],
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                        }
                        break;
                    case 3: //čtvrtek
                        if (
                            ThursdayExtractedRoom[
                                ongoingHour.toNumber() + pageIndex
                            ] == null
                        ) {
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() / 100) * 50,
                                Graphics.FONT_LARGE,
                                "Volná hodina",
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() / 100) * 75,
                                Graphics.FONT_LARGE,
                                classTimes[ongoingHour.toNumber() + pageIndex],
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                        } else {
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() / 100) * 25,
                                Graphics.FONT_LARGE,
                                ThursdayExtractedRoom[
                                    ongoingHour.toNumber() + pageIndex
                                ],
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() / 100) * 50,
                                Graphics.FONT_LARGE,
                                ThursdayExtractedSubject[
                                    ongoingHour.toNumber() + pageIndex
                                ] +
                                    " - " +
                                    ThursdayExtractedTeacher[
                                        ongoingHour.toNumber() + pageIndex
                                    ],
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() / 100) * 75,
                                Graphics.FONT_LARGE,
                                classTimes[ongoingHour.toNumber() + pageIndex],
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                        }
                        break;
                    case 4: //pátek
                        if (
                            FridayExtractedRoom[
                                ongoingHour.toNumber() + pageIndex
                            ] == null
                        ) {
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() / 100) * 50,
                                Graphics.FONT_LARGE,
                                "Volná hodina",
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() / 100) * 75,
                                Graphics.FONT_LARGE,
                                classTimes[ongoingHour.toNumber() + pageIndex],
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                        } else {
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() / 100) * 25,
                                Graphics.FONT_LARGE,
                                FridayExtractedRoom[
                                    ongoingHour.toNumber() + pageIndex
                                ],
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() / 100) * 50,
                                Graphics.FONT_LARGE,
                                FridayExtractedSubject[
                                    ongoingHour.toNumber() + pageIndex
                                ] +
                                    " - " +
                                    FridayExtractedTeacher[
                                        ongoingHour.toNumber() + pageIndex
                                    ],
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() / 100) * 75,
                                Graphics.FONT_LARGE,
                                classTimes[ongoingHour.toNumber() + pageIndex],
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                        }
                        break;
                    case 10: //po 15:50 (nemohou už být další hodiny)
                        dc.drawText(
                            dc.getWidth() / 2,
                            (dc.getHeight() / 100) * 25,
                            Graphics.FONT_LARGE,
                            "Dnes už\nnejsou žádné\ndalší hodiny.",
                            Graphics.TEXT_JUSTIFY_CENTER
                        );
                        break;
                    default: //víkend nebo teoreticky chyba, ukáže, že nejsou žádné hodiny
                        dc.drawText(
                            dc.getWidth() / 2,
                            (dc.getHeight() / 100) * 25,
                            Graphics.FONT_LARGE,
                            "Dnes nejsou\nžádné hodiny.",
                            Graphics.TEXT_JUSTIFY_CENTER
                        );
                        dc.drawText(
                            dc.getWidth() / 2,
                            (dc.getHeight() / 100) * 75,
                            Graphics.FONT_LARGE,
                            "Užívej volného\ndne!",
                            Graphics.TEXT_JUSTIFY_CENTER
                        );
                        break;
                }
            }
        } else {
            dc.drawText(
                dc.getWidth() / 2,
                (dc.getHeight() / 100) * 50,
                Graphics.FONT_LARGE,
                "Dokončete\nnastavení",
                Graphics.TEXT_JUSTIFY_CENTER
            );
        }
    }

    function save() as Void {
        //uložení momentálních dat při zavření aplikace
        app.setProperty("saveDate", date);

        if (timetableIsPermanent == true) {
            app.setProperty("MoExRoomPerm", MondayExtractedRoom);
            app.setProperty("TuExRoomPerm", TuesdayExtractedRoom);
            app.setProperty("WeExRoomPerm", WednesdayExtractedRoom);
            app.setProperty("ThExRoomPerm", ThursdayExtractedRoom);
            app.setProperty("FrExRoomPerm", FridayExtractedRoom);

            app.setProperty("MoExSubjPerm", MondayExtractedSubject);
            app.setProperty("TuExSubjPerm", TuesdayExtractedSubject);
            app.setProperty("WeExSubjPerm", WednesdayExtractedSubject);
            app.setProperty("ThExSubjPerm", ThursdayExtractedSubject);
            app.setProperty("FrExSubjPerm", FridayExtractedSubject);

            app.setProperty("MoExTeachPerm", MondayExtractedTeacher);
            app.setProperty("TuExTeachPerm", TuesdayExtractedTeacher);
            app.setProperty("WeExTeachPerm", WednesdayExtractedTeacher);
            app.setProperty("ThExTeachPerm", ThursdayExtractedTeacher);
            app.setProperty("FrExTeachPerm", FridayExtractedTeacher);
        } else {
            switch (date) {
                case 0:
                    app.setProperty("MoExRoom", MondayExtractedRoom);
                    app.setProperty("MoExSubj", MondayExtractedSubject);
                    app.setProperty("MoExTeach", MondayExtractedTeacher);
                    break;
                case 1:
                    app.setProperty("TuExRoom", TuesdayExtractedRoom);
                    app.setProperty("TuExSubj", TuesdayExtractedSubject);
                    app.setProperty("TuExTeach", TuesdayExtractedTeacher);
                    break;
                case 2:
                    app.setProperty("WeExRoom", WednesdayExtractedRoom);
                    app.setProperty("WeExSubj", WednesdayExtractedSubject);
                    app.setProperty("WeExTeach", WednesdayExtractedTeacher);
                    break;
                case 3:
                    app.setProperty("ThExRoom", ThursdayExtractedRoom);
                    app.setProperty("ThExSubj", ThursdayExtractedSubject);
                    app.setProperty("ThExTeach", ThursdayExtractedTeacher);
                    break;
                case 4:
                    app.setProperty("FrExRoom", FridayExtractedRoom);
                    app.setProperty("FrExSubj", FridayExtractedSubject);
                    app.setProperty("FrExTeach", FridayExtractedTeacher);
                    break;
                default:
                    break;
            }
        }
    }
}

class RozvrhhodinInput extends WatchUi.BehaviorDelegate {
    var app;
    var pageIndex = 0;

    function initialize() {
        WatchUi.BehaviorDelegate.initialize();
        app = Application.getApp();
        pageIndex = 0;
        app.setProperty("pageIndex", 0);
    }

    function onKey(keyEvent) {
        if (
            keyEvent.getKey() == 5
        ) //použité tlačítko zpět -> říct systému že má vypnout aplikaci
        {
            System.exit();
            return true;
        } else if (keyEvent.getKey() == 4) {
            //horní pravé tlačítko otevírá menu/nastavení
            openSettings();
            return true;
        } else {
            //ostatní -> systém reaguje normálně
            return true;
        }
    }

    function onSwipe(swipeEvent) {
        pageIndex = app.getProperty("pageIndex").toNumber();

        if (
            swipeEvent.getDirection() == 1
        ) //swipe doleva -> vratí zpět stejně jako tlačítko
        {
            return false;
        } else if (swipeEvent.getDirection() == 2) //nahoru
        {
            pageIndex = pageIndex - 1;

            if (pageIndex + app.getProperty("ongoingHour") < 0) {
                pageIndex++;
            }

            app.setProperty("pageIndex", pageIndex);

            requestUpdate();

            return true;
        } else if (swipeEvent.getDirection() == 0) //dolu
        {
            pageIndex = pageIndex + 1;

            if (pageIndex + app.getProperty("ongoingHour").toNumber() > 9) {
                pageIndex--;
            }

            app.setProperty("pageIndex", pageIndex);

            requestUpdate();

            return true;
        } else {
            return false;
        }
    }

    function openSettings() {
        WatchUi.switchToView(
            new RozvrhhodinSettings(),
            new RozvrhhodinSettingsInput(),
            WatchUi.SLIDE_LEFT
        );
    }
}

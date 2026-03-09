import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Application;
import Toybox.Time;

(:glance)
class RozvrhhodinGlanceView extends WatchUi.GlanceView {
    //všechny proměné mají stejný význam jako v hlavním RozvrhhodinView.mc
    var MondayExtractedSubject = new [10]; //maximální počet hodin je 10
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

    var ongoingHour;
    var time;
    var date;
    var savedDate;

    var app;

    var loadActualData;

    var classTimes = [
        //časy končících hodin, místo počítání z měnících se délek přestávek
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

    var loadedData;

    function initialize() {
        //načtení glance a id aplikace
        GlanceView.initialize();

        app = Toybox.Application.getApp();
        loadDataCheck();
    }

    function loadDataCheck() as Void {
        //pokud existují uložená data tak načíst
        if (app.getProperty("saveDate") != null) {
            //pokud data byla uložena dnes tak načíst aktuální data, jinak načíst stálý rozvrh
            if (
                app.getProperty("saveDate").toNumber() ==
                (
                    Time.Gregorian.info(
                        Time.now(),
                        Time.FORMAT_SHORT
                    ).day_of_week.toNumber() - 2
                ).toNumber()
            ) {
                loadedData = true;
                loadActualData = true;
                loadDataFromMemory();
            } else {
                loadedData = true;
                loadActualData = false;
                loadDataFromMemory();
            }
        } else {
            //jinak nenajde žádná data a zobrazí se hláška že se nepodařilo načíst data
            loadedData = false;
        }
    }

    function loadDataFromMemory() as Void {
        //načtení dat do proměných
        if (loadActualData == false) {
            //pokud se načítá stálý rozvrh načtou se data pro stálý rozvrh
            MondayExtractedSubject = app.getProperty("MoExSubjPerm");
            MondayExtractedTeacher = app.getProperty("MoExTeachPerm");
            MondayExtractedRoom = app.getProperty("MoExRoomPerm");
            TuesdayExtractedSubject = app.getProperty("TuExSubjPerm");
            TuesdayExtractedTeacher = app.getProperty("TuExTeachPerm");
            TuesdayExtractedRoom = app.getProperty("TuExRoomPerm");
            WednesdayExtractedSubject = app.getProperty("WeExSubjPerm");
            WednesdayExtractedTeacher = app.getProperty("WeExTeachPerm");
            WednesdayExtractedRoom = app.getProperty("WeExRoomPerm");
            ThursdayExtractedSubject = app.getProperty("ThExSubjPerm");
            ThursdayExtractedTeacher = app.getProperty("ThExTeachPerm");
            ThursdayExtractedRoom = app.getProperty("ThExRoomPerm");
            FridayExtractedSubject = app.getProperty("FrExSubjPerm");
            FridayExtractedTeacher = app.getProperty("FrExTeachPerm");
            FridayExtractedRoom = app.getProperty("FrExRoomPerm");
        } else {
            if (
                app.getProperty("saveDate") != null
            ) //zkontroluje se znovu zda saveData existuje a zda je to dnes
            {
                if (
                    app.getProperty("saveDate").toNumber() ==
                    (
                        Time.Gregorian.info(
                            Time.now(),
                            Time.FORMAT_SHORT
                        ).day_of_week.toNumber() - 2
                    ).toNumber()
                ) {
                    switch (
                        app.getProperty("saveDate").toNumber() //pokud data byla načtena dnes tak vynuluje všechny data mimo dnešek
                    ) {
                        case 0:
                            app.setProperty("TuExSubj", null);
                            app.setProperty("TuExTeach", null);
                            app.setProperty("TuExRoom", null);
                            app.setProperty("WeExSubj", null);
                            app.setProperty("WeExTeach", null);
                            app.setProperty("WeExRoom", null);
                            app.setProperty("ThExSubj", null);
                            app.setProperty("ThExTeach", null);
                            app.setProperty("ThExRoom", null);
                            app.setProperty("FrExSubj", null);
                            app.setProperty("FrExTeach", null);
                            app.setProperty("FrExRoom", null);
                            break;
                        case 1:
                            app.setProperty("MoExSubj", null);
                            app.setProperty("MoExTeach", null);
                            app.setProperty("MoExRoom", null);
                            app.setProperty("WeExSubj", null);
                            app.setProperty("WeExTeach", null);
                            app.setProperty("WeExRoom", null);
                            app.setProperty("ThExSubj", null);
                            app.setProperty("ThExTeach", null);
                            app.setProperty("ThExRoom", null);
                            app.setProperty("FrExSubj", null);
                            app.setProperty("FrExTeach", null);
                            app.setProperty("FrExRoom", null);
                            break;
                        case 2:
                            app.setProperty("MoExSubj", null);
                            app.setProperty("MoExTeach", null);
                            app.setProperty("MoExRoom", null);
                            app.setProperty("TuExSubj", null);
                            app.setProperty("TuExTeach", null);
                            app.setProperty("TuExRoom", null);
                            app.setProperty("ThExSubj", null);
                            app.setProperty("ThExTeach", null);
                            app.setProperty("ThExRoom", null);
                            app.setProperty("FrExSubj", null);
                            app.setProperty("FrExTeach", null);
                            app.setProperty("FrExRoom", null);
                            break;
                        case 3:
                            app.setProperty("MoExSubj", null);
                            app.setProperty("MoExTeach", null);
                            app.setProperty("MoExRoom", null);
                            app.setProperty("TuExSubj", null);
                            app.setProperty("TuExTeach", null);
                            app.setProperty("TuExRoom", null);
                            app.setProperty("WeExSubj", null);
                            app.setProperty("WeExTeach", null);
                            app.setProperty("WeExRoom", null);
                            app.setProperty("FrExSubj", null);
                            app.setProperty("FrExTeach", null);
                            app.setProperty("FrExRoom", null);
                            break;
                        case 4:
                            app.setProperty("MoExSubj", null);
                            app.setProperty("MoExTeach", null);
                            app.setProperty("MoExRoom", null);
                            app.setProperty("TuExSubj", null);
                            app.setProperty("TuExTeach", null);
                            app.setProperty("TuExRoom", null);
                            app.setProperty("WeExSubj", null);
                            app.setProperty("WeExTeach", null);
                            app.setProperty("WeExRoom", null);
                            app.setProperty("ThExSubj", null);
                            app.setProperty("ThExTeach", null);
                            app.setProperty("ThExRoom", null);
                            break;
                        default:
                            break;
                    }
                }
            } //načte všechny data pro každý den, ale kromě aktuálního dne se jedná vždy o null
            MondayExtractedSubject = app.getProperty("MoExSubj");
            MondayExtractedTeacher = app.getProperty("MoExTeach");
            MondayExtractedRoom = app.getProperty("MoExRoom");
            TuesdayExtractedSubject = app.getProperty("TuExSubj");
            TuesdayExtractedTeacher = app.getProperty("TuExTeach");
            TuesdayExtractedRoom = app.getProperty("TuExRoom");
            WednesdayExtractedSubject = app.getProperty("WeExSubj");
            WednesdayExtractedTeacher = app.getProperty("WeExTeach");
            WednesdayExtractedRoom = app.getProperty("WeExRoom");
            ThursdayExtractedSubject = app.getProperty("ThExSubj");
            ThursdayExtractedTeacher = app.getProperty("ThExTeach");
            ThursdayExtractedRoom = app.getProperty("ThExRoom");
            FridayExtractedSubject = app.getProperty("FrExSubj");
            FridayExtractedTeacher = app.getProperty("FrExTeach");
            FridayExtractedRoom = app.getProperty("FrExRoom");
        }
    }

    function onUpdate(dc) {
        //renderování textu podle dne atd. stejně jako v hlavním kodu + kontrola momentální hodiny, redruje se při změně na displaji, docs doporučují 1Hz ale neexistuje .sleep(1000) nebo něco podobného
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        time = System.getClockTime().hour * 60 + System.getClockTime().min; //aktuální čas v minutách od půlnoci

        date =
            Time.Gregorian.info(
                Time.now(),
                Time.FORMAT_SHORT
            ).day_of_week.toNumber() - 2; //aktuální den v týdnu, -2 aby byla neděle je -1 a 0 pondělí

        if (
            time <
            7 * 60 + 45
        ) //kontrola času aby byla zobrazena správná hodina
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

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT); //nastavení barvy textu a pozadí textu
        if (
            loadedData == true
        ) //pokud byla data načtena tak se zobrazí, jinak se zobrazí hláška že se data nepodařilo načíst
        {
            switch (date) {
                case 0: //pokud je pondělí
                    if (MondayExtractedRoom != null) {
                        //pokud pondělí není null (může nastat pouze při chybě requestu)
                        if (
                            MondayExtractedRoom[ongoingHour.toNumber()] == null
                        ) {
                            //pokud je null tak je to volná hodina
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() * 15) / 100,
                                Graphics.FONT_SMALL,
                                "Volná hodina",
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() * 55) / 100,
                                Graphics.FONT_SMALL,
                                classTimes[ongoingHour.toNumber()],
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                        } else {
                            //jinak se zobrazí informace o hodině
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() * 5) / 100,
                                Graphics.FONT_SMALL,
                                MondayExtractedRoom[ongoingHour.toNumber()],
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() * 35) / 100,
                                Graphics.FONT_SMALL,
                                MondayExtractedSubject[ongoingHour.toNumber()] +
                                    " - " +
                                    MondayExtractedTeacher[
                                        ongoingHour.toNumber()
                                    ],
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() * 65) / 100,
                                Graphics.FONT_SMALL,
                                classTimes[ongoingHour.toNumber()],
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                        }
                    } else {
                        //pokud je pondělí null (může nastat pouze při chybě requestu) zobrazí se hláška že se data nepodařilo načíst
                        dc.drawText(
                            dc.getWidth() / 2,
                            dc.getHeight() / 2 -
                                dc.getFontHeight(Graphics.FONT_SMALL) / 2,
                            Graphics.FONT_SMALL,
                            "Nepodařilo se\nnačíst data.",
                            Graphics.TEXT_JUSTIFY_CENTER
                        );
                    }
                    break;
                case 1: //pokud je úterý
                    if (TuesdayExtractedRoom != null) {
                        //pokud úterý není null (může nastat pouze při chybě requestu)
                        if (
                            TuesdayExtractedRoom[ongoingHour.toNumber()] == null
                        ) {
                            //pokud je null tak je to volná hodina
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() * 15) / 100,
                                Graphics.FONT_SMALL,
                                "Volná hodina",
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() * 55) / 100,
                                Graphics.FONT_SMALL,
                                classTimes[ongoingHour.toNumber()],
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                        } else {
                            //jinak se zobrazí informace o hodině
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() * 5) / 100,
                                Graphics.FONT_SMALL,
                                TuesdayExtractedRoom[ongoingHour.toNumber()],
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() * 35) / 100,
                                Graphics.FONT_SMALL,
                                TuesdayExtractedSubject[
                                    ongoingHour.toNumber()
                                ] +
                                    " - " +
                                    TuesdayExtractedTeacher[
                                        ongoingHour.toNumber()
                                    ],
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() * 65) / 100,
                                Graphics.FONT_SMALL,
                                classTimes[ongoingHour.toNumber()],
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                        }
                    } else {
                        //pokud je úterý null (může nastat pouze při chybě requestu) zobrazí se hláška že se data nepodařilo načíst
                        dc.drawText(
                            dc.getWidth() / 2,
                            dc.getHeight() / 2 -
                                dc.getFontHeight(Graphics.FONT_SMALL) / 2,
                            Graphics.FONT_SMALL,
                            "Nepodařilo se\nnačíst data.",
                            Graphics.TEXT_JUSTIFY_CENTER
                        );
                    }
                    break;
                case 2: //pokud je středa
                    if (WednesdayExtractedRoom != null) {
                        //pokud středa není null (může nastat pouze při chybě requestu)
                        if (
                            WednesdayExtractedRoom[ongoingHour.toNumber()] ==
                            null
                        ) {
                            //pokud je null tak je to volná hodina
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() * 15) / 100,
                                Graphics.FONT_SMALL,
                                "Volná hodina",
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() * 55) / 100,
                                Graphics.FONT_SMALL,
                                classTimes[ongoingHour.toNumber()],
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                        } else {
                            //jinak se zobrazí informace o hodině
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() * 5) / 100,
                                Graphics.FONT_SMALL,
                                WednesdayExtractedRoom[ongoingHour.toNumber()],
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() * 35) / 100,
                                Graphics.FONT_SMALL,
                                WednesdayExtractedSubject[
                                    ongoingHour.toNumber()
                                ] +
                                    " - " +
                                    WednesdayExtractedTeacher[
                                        ongoingHour.toNumber()
                                    ],
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() * 65) / 100,
                                Graphics.FONT_SMALL,
                                classTimes[ongoingHour.toNumber()],
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                        }
                    } else {
                        //pokud je středa null (může nastat pouze při chybě requestu) zobrazí se hláška že se data nepodařilo načíst
                        dc.drawText(
                            dc.getWidth() / 2,
                            dc.getHeight() / 2 -
                                dc.getFontHeight(Graphics.FONT_SMALL) / 2,
                            Graphics.FONT_SMALL,
                            "Nepodařilo se\nnačíst data.",
                            Graphics.TEXT_JUSTIFY_CENTER
                        );
                    }
                    break;
                case 3: //pokud je čtvrtek
                    if (ThursdayExtractedRoom != null) {
                        //pokud čtvrtek není null (může nastat pouze při chybě requestu)
                        if (
                            ThursdayExtractedRoom[ongoingHour.toNumber()] ==
                            null
                        ) {
                            //pokud je null tak je to volná hodina
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() * 15) / 100,
                                Graphics.FONT_SMALL,
                                "Volná hodina",
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() * 55) / 100,
                                Graphics.FONT_SMALL,
                                classTimes[ongoingHour.toNumber()],
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                        } else {
                            //jinak se zobrazí informace o hodině
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() * 5) / 100,
                                Graphics.FONT_SMALL,
                                ThursdayExtractedRoom[ongoingHour.toNumber()],
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() * 35) / 100,
                                Graphics.FONT_SMALL,
                                ThursdayExtractedSubject[
                                    ongoingHour.toNumber()
                                ] +
                                    " - " +
                                    ThursdayExtractedTeacher[
                                        ongoingHour.toNumber()
                                    ],
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() * 65) / 100,
                                Graphics.FONT_SMALL,
                                classTimes[ongoingHour.toNumber()],
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                        }
                    } else {
                        //pokud je čtvrtek null (může nastat pouze při chybě requestu) zobrazí se hláška že se data nepodařilo načíst
                        dc.drawText(
                            dc.getWidth() / 2,
                            dc.getHeight() / 2 -
                                dc.getFontHeight(Graphics.FONT_SMALL) / 2,
                            Graphics.FONT_SMALL,
                            "Nepodařilo se\nnačíst data.",
                            Graphics.TEXT_JUSTIFY_CENTER
                        );
                    }
                    break;
                case 4: //pokud je pátek
                    if (FridayExtractedRoom != null) {
                        //pokud pátek není null (může nastat pouze při chybě requestu)
                        if (
                            FridayExtractedRoom[ongoingHour.toNumber()] == null
                        ) {
                            //pokud je null tak je to volná hodina
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() * 15) / 100,
                                Graphics.FONT_SMALL,
                                "Volná hodina",
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() * 55) / 100,
                                Graphics.FONT_SMALL,
                                classTimes[ongoingHour.toNumber()],
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                        } else {
                            //jinak se zobrazí informace o hodině
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() * 5) / 100,
                                Graphics.FONT_SMALL,
                                FridayExtractedRoom[ongoingHour.toNumber()],
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() * 35) / 100,
                                Graphics.FONT_SMALL,
                                FridayExtractedSubject[ongoingHour.toNumber()] +
                                    " - " +
                                    FridayExtractedTeacher[
                                        ongoingHour.toNumber()
                                    ],
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                            dc.drawText(
                                dc.getWidth() / 2,
                                (dc.getHeight() * 65) / 100,
                                Graphics.FONT_SMALL,
                                classTimes[ongoingHour.toNumber()],
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                        }
                    } else {
                        //pokud je pátek null (může nastat pouze při chybě requestu) zobrazí se hláška že se data nepodařilo načíst
                        dc.drawText(
                            dc.getWidth() / 2,
                            dc.getHeight() / 2 -
                                dc.getFontHeight(Graphics.FONT_SMALL) / 2,
                            Graphics.FONT_SMALL,
                            "Nepodařilo se\nnačíst data.",
                            Graphics.TEXT_JUSTIFY_CENTER
                        );
                    }
                    break;
                case 10: //pokud je po poslední hodině
                    dc.drawText(
                        dc.getWidth() / 2,
                        dc.getHeight() / 2 -
                            dc.getFontHeight(Graphics.FONT_SMALL),
                        Graphics.FONT_SMALL,
                        "Dnes už nejsou\nžádné hodiny.",
                        Graphics.TEXT_JUSTIFY_CENTER
                    );
                    break;
                default: //víkend nebo chyba
                    dc.drawText(
                        dc.getWidth() / 2,
                        dc.getHeight() / 2 -
                            dc.getFontHeight(Graphics.FONT_SMALL),
                        Graphics.FONT_SMALL,
                        "Dnes nejsou\nžádné hodiny.",
                        Graphics.TEXT_JUSTIFY_CENTER
                    );
                    break;
            }
        } else if (
            loadedData == false
        ) //data nebyla nikdy uložena, zobrazí se hláška že je potřeba načíst data
        {
            dc.drawText(
                dc.getWidth() / 2,
                dc.getHeight() / 2 - dc.getFontHeight(Graphics.FONT_SMALL),
                Graphics.FONT_SMALL,
                "Otevřete aplikaci\na načtěte data.",
                Graphics.TEXT_JUSTIFY_CENTER
            );
        }
    }
}

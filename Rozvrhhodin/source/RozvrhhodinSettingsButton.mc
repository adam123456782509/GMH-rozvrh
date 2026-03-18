import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

var menu;
class RozvrhhodinSettingsButton extends WatchUi.View {

    function initialize() {
        menu = new WatchUi.Menu2({:title=>"Nastavení"});

        //nastavení pro typ uživatele, pokud není nastaveno, nastaví se výchozí hodnota na učitele
        if(Toybox.Application.getApp().getProperty("Teacher") == null){
            Toybox.Application.getApp().setProperty("Teacher", true);
        }

        menu.addItem(//položka pro nastavení typu uživatele, zobrazuje se jako přepínač a mění se podle uložené hodnoty
            new ToggleMenuItem(
                "Typ uživatele",
                "žák",
                "toggle",
                Toybox.Application.getApp().getProperty("Teacher"),
                {}
            )
        );
        if(Toybox.Application.getApp().getProperty("Teacher") == true){//nastavení zobrazení pro typ uživatele
            menu.getItem(0).setSubLabel("žák");
        }
        else
        {
            menu.getItem(0).setSubLabel("učitel");
        }

        menu.addItem(//položka pro nastavení API klíče
            new MenuItem(
                "Můj API klíč",
                "Úprava klíče uživatele",
                "API",
                {}
            )
        );
        
        menu.addItem(//položka pro načtení stálého rozvrhu
            new MenuItem(
                "Načíst stálý rozvrh",
                "Refresh stálého rozvrhu",//TODO: zkrátit popis
                "LOAD",
                {}
            )
        );
    }
    

    function onShow() as Void {
        WatchUi.switchToView(menu, new RozvrhhodinSettingsButtonBehaviorDelagate(), WatchUi.SLIDE_IMMEDIATE);
    }
}

class RozvrhhodinSettingsButtonBehaviorDelagate extends Menu2InputDelegate {
    function onSelect(item as MenuItem) {

        if(item.getId().equals("toggle")){//při změně typu uživatele se změní hodnota a aktualizuje se zobrazení
            if(menu.getItem(0).isEnabled() == true){
                menu.getItem(0).setSubLabel("žák");
            }
            else
            {
            menu.getItem(0).setSubLabel("učitel");
            }
            menu.updateItem(menu.getItem(0), 0);
            Toybox.Application.getApp().setProperty("Teacher", menu.getItem(0).isEnabled());

        }
        else if(item.getId().equals("API")){//otevření nastavení pro API klíč
            
            WatchUi.switchToView(
                new RozvrhhodinKeyboard(),
                new RozvrhhodinKeyboardDelegate(),
                WatchUi.SLIDE_LEFT
            );
            
        }

        else if(item.getId().equals("LOAD")){//otevření načítací obrazovky pro stálý rozvrh a nastavení proměnné pro načítací obrazovku
            Toybox.Application.getApp().setProperty("loadPermanent", true);
            WatchUi.switchToView(
                new RozvrhhodinLoading(),
                new RozvrhhodinLoadingInput(),
                WatchUi.SLIDE_IMMEDIATE
            );
        }
    }

    function onBack(){//při stisku tlačítka zpět se vrátí na hlavní obrazovku
        
            WatchUi.switchToView(
                new RozvrhhodinView(),
                new RozvrhhodinInput(),
                WatchUi.SLIDE_RIGHT
            );
        
    }
}
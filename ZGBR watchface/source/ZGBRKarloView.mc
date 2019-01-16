using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Time.Gregorian as Calendar;

class ZGBRKarloView extends Ui.WatchFace {
	var background;
	var hourFont;
	var minuteFont;
	var dateFont;
	var batteryFont;
	var stepFont;

    function initialize() {
        WatchFace.initialize();
    }

    //! Load your resources here
    function onLayout(dc) {
    	background = Ui.loadResource(Rez.Drawables.back);
    	hourFont = Ui.loadResource(Rez.Fonts.hour);
    	minuteFont = Ui.loadResource(Rez.Fonts.minute);
    	dateFont = Ui.loadResource(Rez.Fonts.date);
    	stepFont = Ui.loadResource(Rez.Fonts.step);
    	batteryFont = Ui.loadResource(Rez.Fonts.battery);
    	
        setLayout(Rez.Layouts.WatchFace(dc));
    }
    
    

    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
    function onShow() {
    }

    //! Update the view
    function onUpdate(dc) {
        //set backgorund
        setBackground(dc);
    	
        var clockTime = Sys.getClockTime();
        var hour = clockTime.hour;
        var minute = clockTime.min;
        var now = Time.now();
        var info = Calendar.info(now, Time.FORMAT_LONG);
        var shorter = Calendar.info(now, Time.FORMAT_SHORT);
        //!TEXT COLOR
        var textColor = Gfx.COLOR_WHITE;
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        
        var horizontal = 110;
        var vertical = 100;
        
//!hour
        dc.drawText(horizontal, vertical-3, hourFont, hour.format("%02d"), Gfx.TEXT_JUSTIFY_RIGHT);
        dc.clear();
//!minute
        dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(horizontal+5, vertical+3, minuteFont, minute.format("%02d"), Gfx.TEXT_JUSTIFY_LEFT);
        
        
//!date
        var dateStr = Lang.format("$1$ $2$/$3$", [info.day_of_week.substring(0, 3).toUpper(), info.day, shorter.month]);
        var dateSize = dc.getTextDimensions(dateStr, dateFont);

        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(149, 137, dateFont, dateStr, Gfx.TEXT_JUSTIFY_CENTER);
        
//!STEPS
        var activityInfo = ActivityMonitor.getInfo();
        if(activityInfo.stepGoal == 0)
        {
            activityInfo.stepGoal = 5000;
        }

        var goal = activityInfo.stepGoal;
        var steps = activityInfo.steps;
        var stepPercent = getStepPercent(activityInfo);

		//positioning
		horizontal = 100;
		vertical = 150;
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        var stepsString = Lang.format("/$2$", [steps, goal]);
        var stepsSize = dc.getTextDimensions(stepsString, stepFont);
        dc.drawText(horizontal, vertical, stepFont, stepsString, Gfx.TEXT_JUSTIFY_LEFT);
        
		dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
        stepsString = Lang.format("$1$/", [steps, goal]);
        dc.drawText(horizontal + 5, vertical, stepFont, stepsString, Gfx.TEXT_JUSTIFY_RIGHT);
        
//!battery
        var battery_x = 97;	//136
      	drawBattery(dc, battery_x + 10, 167);
      	var stats = Sys.getSystemStats();
      	var battery = stats.battery;
     	dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
      	dc.drawText(battery_x - 5, 163, batteryFont, battery.format("%d") + "%", Gfx.TEXT_JUSTIFY_CENTER);
      	//dc.drawText(107, 164, batteryFont, battery.format("%d") + "%", Gfx.TEXT_JUSTIFY_CENTER);
    }
    


	function getStepPercent(info) {

        return info.steps * 215 / info.stepGoal;
    }
    
    //battery
    function drawBattery(dc,x,y) {

        var stats = Sys.getSystemStats();
        var width = 22;
        var height = 14;
        //!OUTLINE COLOR
		var outline = Gfx.COLOR_WHITE;
		//!BATTERY INSIDE
        dc.setColor(Gfx.COLOR_TRANSPARENT, Gfx.COLOR_BLACK);
        dc.fillRectangle(x,y,width,height);
        //!BATTERY END
        dc.setColor(outline, Gfx.COLOR_BLACK);
        dc.fillRectangle(x + width,y + height/2 - 2, 2, 4);
        //!BATTERY OUTLINE
        dc.setColor(outline, Gfx.COLOR_BLACK);
        dc.drawRectangle(x + 1,y + 1,width - 2, height - 2);

        if(stats.battery >= 75)
        {
            dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_BLACK);
        }
        else if(stats.battery >= 50)
        {
            dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_BLACK);
        }
        else if(stats.battery >= 20)
        {
            dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_BLACK);
        }
        var chargeWidth = ((width - 4).toFloat() * stats.battery).toLong() / 100;
        if(chargeWidth > (width -4))
        {
            chargeWidth = (width - 4).toLong();
        }

        dc.fillRectangle(x + 2, y + 2, chargeWidth, height - 4);
        
    }
    
    function setBackground(dc){
    	dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_BLACK);
        dc.clear();
        dc.drawBitmap(0, 0, background);
    }
    
    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
    }

    //! The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    //! Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }

}
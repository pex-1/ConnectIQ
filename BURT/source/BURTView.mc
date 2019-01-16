using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Time.Gregorian as Calendar;

class BURTView extends Ui.WatchFace {
	var background1;
	var background2;
	var minuteFont;
	var dateFont;
	var batteryFont;
	var stepFont;
	var hourFont;
	var theme = Gfx.COLOR_WHITE;

    function initialize() {
        WatchFace.initialize();
    }

    //! Load your resources here
    function onLayout(dc) {
        background1 = Ui.loadResource(Rez.Drawables.back2);
        background2 = Ui.loadResource(Rez.Drawables.back);
    	hourFont = Ui.loadResource(Rez.Fonts.HourFont);
    	minuteFont = Ui.loadResource(Rez.Fonts.MinuteFont);
    	dateFont = Ui.loadResource(Rez.Fonts.DateFont);
    	stepFont = Ui.loadResource(Rez.Fonts.StepFont);
    	batteryFont = Ui.loadResource(Rez.Fonts.StepFont);
    	
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    function onShow() {
    }

    //! Update the view
    function onUpdate(dc) {
        //set time
        var info = Calendar.info(Time.now(), Time.FORMAT_LONG);
        var shorter = Calendar.info(Time.now(), Time.FORMAT_SHORT);
        
        //set backgorund
        if (Sys.getClockTime().hour>=16 || Sys.getClockTime().hour<6){
        	theme = Gfx.COLOR_WHITE;
        	dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_BLACK);
        	dc.clear();
        	dc.drawBitmap(0, 0, background1);
        }
        else{
        	theme = Gfx.COLOR_BLACK;
        	dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_WHITE);
        	dc.clear();
        	dc.drawBitmap(0, 0, background2);
        }
        
        //!TEXT COLOR
        var textColor = Gfx.COLOR_WHITE;
		dc.setColor(theme, Gfx.COLOR_TRANSPARENT);
        //positioning
        var horizontal = 125;
        var vertical = 28;
        
        drawTime(dc, horizontal, vertical, info, shorter, dateFont, hourFont, minuteFont);
        

        
//!STEPS
		drawSteps(dc, horizontal, vertical, stepFont);
        
        
//!battery
		battery(dc, theme, batteryFont);
        
        
        
    }
    function getStepPercent(info) {

        return info.steps * 215 / info.stepGoal;
    }
    
    //battery function
    function battery(dc, theme, batteryFont){
    	var battery_x = 97;	//136
        var battery_y = 157;
      	drawBattery(dc, battery_x + 10, battery_y + 2);
      	var stats = Sys.getSystemStats();
      	var battery = stats.battery;
     	dc.setColor(theme, Gfx.COLOR_TRANSPARENT);
      	dc.drawText(battery_x - 5, battery_y, batteryFont, battery.format("%d") + "%", Gfx.TEXT_JUSTIFY_CENTER);
    }
    
    function drawSteps(dc, horizontal, vertical, stepFont){
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
		vertical = 137;
		dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
        var stepsString = Lang.format("/$2$", [steps, goal]);
        var stepsSize = dc.getTextDimensions(stepsString, stepFont);
        dc.drawText(horizontal, vertical, stepFont, stepsString, Gfx.TEXT_JUSTIFY_LEFT);
        
		dc.setColor(theme, Gfx.COLOR_TRANSPARENT);
        stepsString = Lang.format("$1$/", [steps, goal]);
        dc.drawText(horizontal + 7, vertical, stepFont, stepsString, Gfx.TEXT_JUSTIFY_RIGHT);
    }
    
    

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
    }
    
    function drawTime(dc, horizontal, vertical, info, shorter, dateFont, hourFont, minuteFont){
//!hour
        dc.drawText(horizontal, vertical, hourFont, ((Sys.getClockTime().hour - Sys.getClockTime().hour%10)/10).format("%d"), Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(horizontal+35, vertical, hourFont, (Sys.getClockTime().hour%10).format("%d"), Gfx.TEXT_JUSTIFY_CENTER);
        dc.clear();
//!minute
        dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.drawText(horizontal, vertical + 42, minuteFont, ((Sys.getClockTime().min - Sys.getClockTime().min%10)/10).format("%d"), Gfx.TEXT_JUSTIFY_CENTER);  
        dc.drawText(horizontal+35, vertical + 42, minuteFont, (Sys.getClockTime().min%10).format("%d"), Gfx.TEXT_JUSTIFY_CENTER);
        
//!date
        var dateStr = Lang.format("$1$ $2$/$3$", [info.day_of_week.substring(0, 3).toUpper(), info.day, shorter.month]);
        var dateSize = dc.getTextDimensions(dateStr, dateFont);
		//draw date
        dc.setColor(theme, Gfx.COLOR_TRANSPARENT);
        dc.drawText(105, 15, dateFont, dateStr, Gfx.TEXT_JUSTIFY_CENTER);
    }
    
    //battery status draw
    function drawBattery(dc,x,y) {

        var stats = Sys.getSystemStats();

        var width = 22;
        var height = 14;
        //!OUTLINE COLOR
		var outline = theme;
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
            dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_BLACK);
        }
        else if(stats.battery >= 50)
        {
            dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_BLACK);
        }
        else if(stats.battery >= 20)
        {
            dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_BLACK);
        }
        var chargeWidth = ((width - 4).toFloat() * stats.battery).toLong() / 100;
        if(chargeWidth > (width -4))
        {
            chargeWidth = (width - 4).toLong();
        }

        dc.fillRectangle(x + 2, y + 2, chargeWidth, height - 4);
        
    }

    //! The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    //! Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }

}

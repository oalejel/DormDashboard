//Label dateLabel;
import java.util.Date;

int viewOffset = 40;

void setup() {
  //size(600, 600);
  smooth(8);
  fullScreen();
  background(0,39,76);
  
  fill(255);
  
   //dateLabel = new Label("00:00:00 PM");
}

void draw() {
  background(0,39,76);
  
  upateTimeLabel();
  updateDateLabel();
  
  
  delay(300);
}

void upateTimeLabel() {
  textSize(100);
   int s = second();
   int m = minute();
   int h = hour();
   
   String periodString = "AM";
   String sString = s < 10 ? "0" + s : "" + s;
   String mString = m < 10 ? "0" + m : "" + m;
   
   String hString = h < 10 ? "0" + h : "" + h;
   //if above 12 hours
   if (h > 12) {
     h -= 12;
     hString = h < 10 ? "0" + h : "" + h;
     periodString = "PM";
   }
   
  String timeString = hString + ":" + mString + ":" + sString + " " + periodString; 
  text(timeString, viewOffset, 110);
}

void updateDateLabel() {
  int month = month();
  int day = day();
  int year = year();
  
  String[] dayArray = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"};
  int dayOfWeek = new Date().getDay();
  String stringDayOfWeek = dayArray[dayOfWeek - 1];
  
  
  String[] monthArray = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"};
  String monthString = monthArray[month];
  
  String fullDateString = stringDayOfWeek + ", " + monthString + " " + day + ", " + year;
  textSize(40);
  text(fullDateString, viewOffset, 170);
}
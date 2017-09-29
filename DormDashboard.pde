
import java.util.Date;
import ipcapture.*;

int viewOffset = 40;
IPCapture cam;

void setup() {
  //size(600, 600);
  smooth(8);
  fullScreen();


  cam = new IPCapture(this, "http://shapiro.cam.lib.umich.edu/mjpg/video.mjpg", "", "");
  cam.start();

  fill(255);

  //dateLabel = new Label("00:00:00 PM");
}

void draw() {
  background(17, 122, 146);

  upateTimeLabel();
  updateDateLabel();
  updateCam();



  delay(100);
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

void updateCam() {
  if (cam.isAvailable()) {
    cam.read();
  }
  float camWidth = 500;
  float camHeight = 281;
  float tuner = 1.5;
  image(cam, viewOffset, 300, camWidth * tuner, camHeight * tuner);
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

void keyPressed() {
  if (key == ' ') {
    if (!cam.isAlive()) {
      println("cam not alive");
    }
  }
}
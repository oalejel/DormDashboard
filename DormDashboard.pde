import java.util.Date;
import ipcapture.*;

int viewOffset = 40;
IPCapture cam;

int highTemp = 0;
int lowTemp = 0;
String weatherDescription = "";

String fullDateString;

int month = month();
int day = day();
int year = year();

void setup() {
  //size(600, 600);
  smooth(8);
  fullScreen();

  cam = new IPCapture(this, "http://shapiro.cam.lib.umich.edu/mjpg/video.mjpg", "", "");
  cam.start();

  fill(255);
  
  //call this on every new day
  resetWeather();
  updateDate();
  drawDateLabel();
}

void draw() {
  background(17, 122, 180);

  upateTimeLabel();
  
  updateCam();
  drawWeatherDisplay();
  drawDateLabel();
  
  if (day != day()) {
    //we dont want to recalculate everything 
    //unless we have a new day for some things
    updateDate();
    resetWeather();
  }

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
  } else if (h == 0) {
    hString = "12";
  }

  String timeString = hString + ":" + mString + ":" + sString + " " + periodString; 
  text(timeString, viewOffset, 110);
}

void updateCam() {
  textSize(30);
  text("Live Diag Feed", viewOffset, 370);
  
  if (cam.isAvailable()) {
    cam.read();
  }
  float camWidth = 500;
  float camHeight = 281;
  float tuner = 1.8;
  image(cam, viewOffset, height - (viewOffset + camHeight * tuner), camWidth * tuner, camHeight * tuner);
}

void updateDate() {
  month = month();
  day = day();
  year = year();

  String[] dayArray = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"};
  int dayOfWeek = new Date().getDay();
  String stringDayOfWeek = dayArray[dayOfWeek - 1];

  String[] monthArray = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"};
  String monthString = monthArray[month];

  fullDateString = stringDayOfWeek + ", " + monthString + " " + day + ", " + year;
}

void drawDateLabel() {
  textSize(40);
  text(fullDateString, viewOffset, 170);
}

void drawWeatherDisplay() {
  textSize(40);
  String fulltempString = "H: " + highTemp + ", L: " + lowTemp;
  text(fulltempString, width - 340, 200);
  
  text(weatherDescription, width - 340, 160);
}

void keyPressed() {
  if (key == ' ') {
    if (!cam.isAlive()) {
      println("cam not alive");
    }
  }
}

void resetWeather() {
  String[] lines = loadStrings("https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20woeid%20in%20(select%20woeid%20from%20geo.places(1)%20where%20text%3D%22ann%20arbor%2C%20MI%2C%20USA%22)&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys");
  String jsonString = join(lines, " "); 
  
  JSONObject json = parseJSONObject(jsonString);
  JSONObject query = json.getJSONObject("query");
  JSONObject results = query.getJSONObject("results");
  JSONObject channel = results.getJSONObject("channel");
  JSONObject item = channel.getJSONObject("item");
  JSONArray forecast = item.getJSONArray("forecast");
  //println(item);
  JSONObject todayInfo = forecast.getJSONObject(0);
  highTemp = int(todayInfo.getString("high"));
  lowTemp = int(todayInfo.getString("low"));
  weatherDescription = todayInfo.getString("text");
}


class Calendar {
  String[] events;
  String[] times;
  
  int getNextEventIndex() {
    return 0;
  }
  
}
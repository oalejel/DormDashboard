import java.util.Date;
import ipcapture.*;

int viewOffset = 40;
IPCapture cam;

int highTemp = 0;
int lowTemp = 0;
String weatherDescription = "";
PImage weatherImg;

float camY = 0;
float camHeight = 0;
float camWidth = 0;

String fullDateString;

int month = month();
int day = day();
int year = year();

int lastMillis_camera = 0;
int lastMillis_headlines = 0;

String[] headlineStrings = {};

CourseSchedule omarSchedule;
CourseSchedule vishnuSchedule;

// An array of headline ticker objects
TickerItem[] tickerItems = new TickerItem[20];
float totalW = 0;
PFont tickerFont; // Global font variable

void setup() {
  frameRate(10);

  pixelDensity(2);
  //size(600, 600);
  smooth(8);
  fullScreen();

  tickerFont = loadFont("RidetheFader-80.vlw");

  // Giving the stocks names and values to display
  tickerItems[0] = new TickerItem("News headlines not yet received");

  getHeadlines();

  // We space the stock quotes out according to textWidth()
  float x = 0;
  println(tickerItems.length);
  for (int i = 0; i < tickerItems.length; i++) {
    if (tickerItems[i] == null) {
      break;
    }
    tickerItems[i].setX(x);
    x = x + (tickerItems[i].textW());
  }
  totalW = x;

  cam = new IPCapture(this, "http://shapiro.cam.lib.umich.edu/mjpg/video.mjpg", "", "");
  cam.start();

  fill(255);
  //call this on every new day
  resetWeather();
  updateDate();
  drawDateLabel();

  //setup all courses
  setupOmarCourses();
  
  Course c = omarSchedule.getCurrentCourse();
  if (c == null) {
    //returns null when no class happneing -> use nextCourse()
    
  }
  String title = c.title;
  println(title);
  //String cLocation = c.location;
  //String timeRangeString = c.timeRangeString();
}

void draw() {
  //draw blue background and other background shapes
  background(0, 0, 74);
  noStroke();
  fill(0, 0, 0);
  rect(0, 250, width, 60);

  // Move and display all quotes
  for (int i = 0; i < tickerItems.length; i++) {
    if (tickerItems[i] == null) {
      break;
    }
    tickerItems[i].move();
    tickerItems[i].display(306);
  }

  //reset font to standard after stock ticker font changed
  fill(255);
  PFont standardFont = createFont("", 50);
  textFont(standardFont);

  //set font color to white
  fill(255);
  upateTimeLabel();

  drawWeatherDisplay();
  drawDateLabel();
  updateCam();
  drawClassBox();

  if (millis() - lastMillis_headlines > 60000) {
    getHeadlines();
    lastMillis_headlines = millis();
  }

  if (day != day()) {
    //we dont want to recalculate everything 
    //unless we have a new day for some things
    updateDate();
    resetWeather();
  }

  //delay(10);
}

void upateTimeLabel() {
  textSize(60);
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
  //change text alignment for labels on right side
  textAlign(RIGHT);
  text(timeString, width - viewOffset, viewOffset + 50);
  textAlign(LEFT);
}

void updateCam() {
  textSize(30);
  fill(255);
  text("Live UGLi Video Feed", viewOffset, 390);

  if ((millis() - lastMillis_camera >= 200) && cam.isAvailable()) {
    cam.read();
    lastMillis_camera = millis();
  }

  float tuner = 1.8;
  camWidth = 350 * tuner;
  camHeight = camWidth * (281.0 / 500.0);
  camY = height - ((viewOffset + camHeight) + 4);
  rect(viewOffset - 4, camY, camWidth + 8, camHeight + 8);
  image(cam, viewOffset, height - (viewOffset + camHeight), camWidth, camHeight);
}

void updateDate() {
  month = month();
  day = day();
  year = year();

  String[] dayArray = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"};
  int dayOfWeek = new Date().getDay(); 
  println(dayOfWeek);
  String stringDayOfWeek = dayArray[dayOfWeek];


  String[] monthArray = {"January", "February", "March", "April", "May", "June", "July", " August", "September", "October", "November", "December"};
  String monthString = monthArray[month - 1];

  fullDateString = stringDayOfWeek + ", " + monthString + " " + day + ", " + year;
}

void drawDateLabel() {
  textAlign(RIGHT);
  textSize(30);
  text(fullDateString, width - viewOffset, 90 + viewOffset );
  textAlign(LEFT);
}

void drawClassBox() {
  fill(0);
  float classBoxWidth = width - (3 * viewOffset + camWidth);
  float classBoxX = width - (classBoxWidth + viewOffset);
  rect(classBoxX, camY, classBoxWidth, camHeight, 30);

  stroke(255);
  line(classBoxX + 10, camY + camHeight * 0.5, classBoxX + classBoxWidth - 20, camY + (camHeight * 0.5));

  fill(255);
  textAlign(CENTER, TOP);
  textSize(25);
  text("Vishnu's Current Class", classBoxX + 0.5 * classBoxWidth, camY + 5);
  text("Omar's Current Class", classBoxX + 0.5 * classBoxWidth, camY + (camHeight * 0.5) + 5);

  textAlign(LEFT, TOP);

  //consider coloring green or orange based on progress in class time
  //description labels (drawn after names since they share fonts)
  text("STAMPS", classBoxX + 20, camY + 95);
  text("Next: EECS 203 [CHRYS]", classBoxX + 20, camY + (camHeight * 0.5) + 85);

  //time labels
  text("10:30 am - 12:30 pm", classBoxX + 20, camY + 125);
  text("11:30 am - 1:00 pm", classBoxX + 20, camY + (camHeight * 0.5) + 115);

  //class name/status labels
  textFont(createFont("Arial Black", 40));
  text("EECS 280", classBoxX + 20, camY + 45);
  text("None", classBoxX + 20, camY + (camHeight * 0.5) + 30);

  //set font back to normal
  resetFont();
}

//resets font to standard font with size 40 and white fill
void resetFont() {
  fill(255);
  textFont(createFont("", 40));
}

void drawWeatherDisplay() {
  float imageWidth = 160;
  weatherImg = loadImage("raincloud.png");
  image(weatherImg, viewOffset, viewOffset, imageWidth, imageWidth);

  String fulltempString = "H: " + highTemp + ", L: " + lowTemp;

  //textAlign(LEFT, TOP);
  textSize(34);
  text(weatherDescription, 2 * viewOffset  + imageWidth, viewOffset + 64);
  textSize(30);
  text(fulltempString, 2 * viewOffset + imageWidth, viewOffset + 105);
  //textAlign(LEFT, TOP);
}

void keyPressed() {
  if (key == ' ') {
    if (!cam.isAlive()) {
      println("cam not alive");
    }
  }
}

void getHeadlines() {
  try {
    String[] lines = loadStrings("https://newsapi.org/v2/top-headlines?sources=google-news&apiKey=deab2cdaf5cc4eff8f415a85f2f47e1f");
    String jsonString = join(lines, " ");
    JSONObject json = parseJSONObject(jsonString);

    int numArticles = json.getInt("totalResults");
    JSONArray articles = json.getJSONArray("articles");

    for (int i = 0; i < numArticles; i++) {
      if (tickerItems[i] == null) {
        tickerItems[i] = new TickerItem("");
      }

      JSONObject article = articles.getJSONObject(i);
      String title = article.getString("title");
      tickerItems[i].display = title + " --- ";
    }
  } 
  catch (Exception e) {
    println("news headlines error");
  }
}

void resetWeather() {
  try {
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
  catch (Exception e) {
    println("weather error");
  }
}

class Calendar {
  String[] events;
  String[] times;

  int getNextEventIndex() {
    return 0;
  }
}

void setupOmarCourses() {
  //SimpleDate(int _dayOfWeek, int _hour, int _minute)
  //sunday - saturday; sunday = 0

  omarSchedule = new CourseSchedule();

  Course eng100 = new Course("ENG100 Lect", "G906 COOL");
  DateRange engRange1 = new DateRange(new SimpleDate(1, 9, 0), new SimpleDate(1, 10, 30));
  DateRange engRange2 = new DateRange(new SimpleDate(3, 9, 0), new SimpleDate(3, 10, 30));
  eng100.addDateRange(engRange1);
  eng100.addDateRange(engRange2);

  Course eng100Lab = new Course("ENG100 Lab", "185 EWRE");
  DateRange engRange3 = new DateRange(new SimpleDate(4, 13, 30), new SimpleDate(4, 14, 30));
  eng100Lab.addDateRange(engRange3);

  Course eng100Other = new Course("ENG100 Other", "2322 EECS");
  DateRange engRange4 = new DateRange(new SimpleDate(4, 14, 30), new SimpleDate(4, 16, 30));
  eng100Other.addDateRange(engRange4);

  Course econ101Discussion = new Course("ECON101 Lect", "140 LORCH");
  DateRange econRange1 = new DateRange(new SimpleDate(1, 11, 30), new SimpleDate(1, 13, 0));
  DateRange econRange2 = new DateRange(new SimpleDate(3, 11, 30), new SimpleDate(3, 13, 0));
  econ101Discussion.addDateRange(econRange1);
  econ101Discussion.addDateRange(econRange2);

  Course econ101Other = new Course("ECON101 Other", "373 LORCH");
  DateRange econRange3 = new DateRange(new SimpleDate(2, 10, 0), new SimpleDate(2, 11, 3));
  econ101Other.addDateRange(econRange3);

  Course math215Disc = new Course("MATH215 Lect", "260 Weiser");
  DateRange mathRange1 = new DateRange(new SimpleDate(1, 13, 0), new SimpleDate(1, 14, 0));
  DateRange mathRange2 = new DateRange(new SimpleDate(3, 13, 0), new SimpleDate(3, 14, 0));
  DateRange mathRange3 = new DateRange(new SimpleDate(5, 13, 0), new SimpleDate(5, 14, 0));
  math215Disc.addDateRange(mathRange1);
  math215Disc.addDateRange(mathRange2);
  math215Disc.addDateRange(mathRange3);

  Course math215Lab = new Course("MATH215 Lab", "B735 EH");
  DateRange mathRange4 = new DateRange(new SimpleDate(4, 9, 0), new SimpleDate(4, 10, 30));
  math215Lab.addDateRange(mathRange4);

  Course eecs203Lab = new Course("EECS203 Lab", "1005 DOW");
  DateRange eecsRange1 = new DateRange(new SimpleDate(1, 15, 30), new SimpleDate(1, 16, 30));
  eecs203Lab.addDateRange(eecsRange1);

  Course eecs203Disc = new Course("EECS203 Lect", "AUD CHRYS");
  DateRange eecsRange2 = new DateRange(new SimpleDate(2, 12, 0), new SimpleDate(2, 13, 30));
  DateRange eecsRange3 = new DateRange(new SimpleDate(4, 12, 0), new SimpleDate(4, 13, 30));
  eecs203Disc.addDateRange(eecsRange2);
  eecs203Disc.addDateRange(eecsRange3);

  Course testCourse = new Course("TEST", "LOCATION");
  DateRange testRange = new DateRange(new SimpleDate(0, 1, 0), new SimpleDate(0, 23, 30));
  testCourse.addDateRange(testRange);

  //add courses to omar's schedule
  Course[] omarCourses = {testCourse, eng100, eng100Lab, eng100Other, econ101Discussion, econ101Other, math215Disc, math215Lab, eecs203Lab, eecs203Disc};
  omarSchedule.setCourses(omarCourses);
}
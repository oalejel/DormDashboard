import java.util.Date; //<>//
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
int lastMinute = minute();

String[] headlineStrings = {};

//schedule
CourseSchedule omarSchedule;
CourseSchedule vishnuSchedule;
String omarTitle = "";
String omarDescription = "";
String omarRangeTitle = "";
String vishnuTitle = "";
String vishnuDescription = "";
String vishnuRangeTitle = "";

// An array of headline ticker objects
TickerItem[] tickerItems = new TickerItem[20];
float totalW = 0;
PFont tickerFont; // Global font variable

void setup() {
  frameRate(60);
  //pixelDensity(2);
  //size(600, 600);
  //smooth(4);
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
  setupVishnuCourses();

  //then draw the course info
  updateCourseLabels();
  background(0, 0, 74);

  //drawing for the camera area
  camWidth = (width / 2);
  camHeight = camWidth * (281.0 / 500.0);
  camY = height - ((viewOffset + camHeight) + 4);
  rect(viewOffset - 4, camY, camWidth + 8, camHeight + 8);
}


void draw() {
  //draw blue background and other background shapes
  //background(0, 0, 74);
  noStroke();
  fill(0, 0, 0);
  strokeWeight(10);
  stroke(0, 0, 74);
  rect(-10, 240, width + 20, 80);
  strokeWeight(1);

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

  //if (millis() - lastMillis_headlines > 6000) {
  //  print("ohhhhh" + millis());
  //  tickerItems[0].display = "hallo";
  //  lastMillis_headlines = millis();
  //}
  
  if (day != day()) {
    //we dont want to recalculate everything 
    //unless we have a new day for some things
    updateDate();
    resetWeather();
  }

  if (minute() != lastMinute) {
    lastMinute = minute();
    updateCourseLabels();
  }

  //delay(10);
}

void setBlueFill() {
  fill(0, 0, 74);
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

  setBlueFill();
  rect(width / 1.5, 0, 500, 200);
  fill(255);

  String timeString = hString + ":" + mString + ":" + sString + " " + periodString; 
  //change text alignment for labels on right side
  textAlign(RIGHT);
  text(timeString, width - viewOffset, viewOffset + 50);
  textAlign(LEFT);
}

void updateCam() {
  textSize(30);
  fill(255);
  text("Live UGLi Video Feed", viewOffset, height - (camHeight + viewOffset * 2));

  if (cam.isAvailable()) {
    //thread("drawCam");
    drawCam();
  }
}

void drawCam() {
  fill(255);
  //if (cam.isAvailable()) {
  cam.read();
  //lastMillis_camera = millis();
  image(cam, viewOffset, height - (viewOffset + camHeight), camWidth, camHeight);
  //}
}

void updateDate() {
  month = month();
  day = day();
  year = year();

  String[] dayArray = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"};
  int dayOfWeek = new Date().getDay(); 
  String stringDayOfWeek = dayArray[dayOfWeek];

  String[] monthArray = {"January", "February", "March", "April", "May", "June", "July", " August", "September", "October", "November", "December"};
  String monthString = monthArray[month - 1];

  fullDateString = stringDayOfWeek + ", " + monthString + " " + day + ", " + year;
}

void drawDateLabel() {
  //set fill to blue for camoflauge
  setBlueFill();
  //fill(44);//test to make sre all good
  rect(width - (2 + viewOffset + textWidth(fullDateString)), 60 + viewOffset, textWidth(fullDateString) + 4, 40);

  textAlign(RIGHT);
  textSize(30);

  fill(255);
  text(fullDateString, width - viewOffset, 90 + viewOffset);
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
  text(vishnuDescription, classBoxX + 20, camY + 95);
  text(omarDescription, classBoxX + 20, camY + (camHeight * 0.5) + 85);

  //time labels
  text(vishnuRangeTitle, classBoxX + 20, camY + 125);
  text(omarRangeTitle, classBoxX + 20, camY + (camHeight * 0.5) + 115);

  //class name/status labels
  textFont(createFont("Arial Black", 40));
  text(vishnuTitle, classBoxX + 20, camY + 45);
  text(omarTitle, classBoxX + 20, camY + (camHeight * 0.5) + 30);

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
  setBlueFill();
  rect(viewOffset, viewOffset, 2 * viewOffset + imageWidth + textWidth(weatherDescription), imageWidth);
  fill(255);
  
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
      tickerItems[i].display = " --- " + title;
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

void updateCourseLabels() {
  int omarCourseIndex = omarSchedule.currentCourseIndex();

  if (omarCourseIndex == -1) {
    //returns -1 when no class happening -> use nextCourseIndex()
    int nextCourseIndex = omarSchedule.nextCourseIndex();
    Course c = omarSchedule.courseForIndex(nextCourseIndex);
    omarTitle = "None";
    omarDescription = "Next: " + c.title + " [" + c.location + "]";
    DateRange r = omarSchedule.dateRangeForIndex(nextCourseIndex);
    omarRangeTitle = r.descriptionString();
  } else {
    Course c = omarSchedule.courseForIndex(omarCourseIndex);
    omarTitle = c.title;
    omarDescription = c.location;

    DateRange r = omarSchedule.dateRangeForIndex(omarCourseIndex);
    omarRangeTitle = r.descriptionString();
  }

  int vishnuCourseIndex = vishnuSchedule.currentCourseIndex();

  if (vishnuCourseIndex == -1) {
    //returns -1 when no class happening -> use nextCourseIndex()
    int nextCourseIndex = vishnuSchedule.nextCourseIndex();
    Course c = vishnuSchedule.courseForIndex(nextCourseIndex);
    vishnuTitle = "None";
    vishnuDescription = "Next: " + c.title + " [" + c.location + "]";
    DateRange r = vishnuSchedule.dateRangeForIndex(nextCourseIndex);
    vishnuRangeTitle = r.descriptionString();
  } else {
    Course c = vishnuSchedule.courseForIndex(vishnuCourseIndex);
    vishnuTitle = c.title;
    vishnuDescription = c.location;

    DateRange r = vishnuSchedule.dateRangeForIndex(vishnuCourseIndex);
    vishnuRangeTitle = r.descriptionString();
  }
}

void setupVishnuCourses() {
  println("setting up vishnu courses!");
  vishnuSchedule = new CourseSchedule();

  Course math217 = new Course("MATH217 Lec", "B737 EH");
  DateRange mathRange1 = new DateRange(new SimpleDate(1, 8, 30), new SimpleDate(1, 10, 0));
  DateRange mathRange2 = new DateRange(new SimpleDate(3, 8, 30), new SimpleDate(3, 10, 0));
  DateRange mathRange3 = new DateRange(new SimpleDate(5, 8, 30), new SimpleDate(5, 10, 0));
  math217.addDateRange(mathRange1);
  math217.addDateRange(mathRange2);
  math217.addDateRange(mathRange3);

  Course eecs280 = new Course("EECS280 Lec", "1013 DOW");
  DateRange eecsRange1 = new DateRange(new SimpleDate(1, 10, 30), new SimpleDate(1, 12, 0));
  DateRange eecsRange2 = new DateRange(new SimpleDate(3, 10, 30), new SimpleDate(3, 12, 0));
  eecs280.addDateRange(eecsRange1);
  eecs280.addDateRange(eecsRange2);

  Course eecs280Lab = new Course("EECS280 Lab", "1303 EECS");
  DateRange eecsLabRange1 = new DateRange(new SimpleDate(5, 12, 0), new SimpleDate(5, 14, 0));
  eecs280Lab.addDateRange(eecsLabRange1);

  Course eng100Lec = new Course("ENGR100 Lec", "1109 FXB");
  DateRange eng100Range1 = new DateRange(new SimpleDate(2, 10, 30), new SimpleDate(2, 12, 0));
  DateRange eng100Range2 = new DateRange(new SimpleDate(4, 10, 30), new SimpleDate(4, 12, 0));
  eng100Lec.addDateRange(eng100Range1);
  eng100Lec.addDateRange(eng100Range2);

  Course eng100Lab = new Course("ENGR100 Lab", "108 GFL");
  DateRange engLabRange = new DateRange(new SimpleDate(2, 15, 30), new SimpleDate(2, 17, 30));
  eng100Lab.addDateRange(engLabRange);

  Course eng100Disc = new Course("ENGR100 Disc", "1005 EECS");
  DateRange engDiscRange = new DateRange(new SimpleDate(5, 10, 30), new SimpleDate(5, 11, 30));
  eng100Disc.addDateRange(engDiscRange);

  Course discMathLec = new Course("EECS203 Lec", "AUD CHRYS");
  DateRange discRange1 = new DateRange(new SimpleDate(2, 12, 0), new SimpleDate(2, 13, 30));
  DateRange discRange2 = new DateRange(new SimpleDate(4, 12, 0), new SimpleDate(4, 13, 30));
  discMathLec.addDateRange(discRange1);
  discMathLec.addDateRange(discRange2);

  Course discMathDisc = new Course("EECS203 Disc", "2166 DOW");
  DateRange discRange3 = new DateRange(new SimpleDate(3, 12, 30), new SimpleDate(3, 13, 30));
  discMathDisc.addDateRange(discRange3);

  Course[] vishnuCourses = {math217, eecs280, eecs280Lab, eng100Lec, eng100Lab, eng100Disc, discMathLec, discMathDisc};
  vishnuSchedule.setCourses(vishnuCourses);
}

void setupOmarCourses() {
  println("setting up omar courses!");
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

  //add courses to omar's schedule
  Course[] omarCourses = {eng100, eng100Lab, eng100Other, econ101Discussion, econ101Other, math215Disc, math215Lab, eecs203Lab, eecs203Disc};
  omarSchedule.setCourses(omarCourses);
}
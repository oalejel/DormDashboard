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

int lastMillis = 0;

String[] headlineStrings = {};
 
// An array of headline ticker objects
TickerItem[] tickerItems = new TickerItem[20];
float totalW = 0;
PFont tickerFont; // Global font variable

void setup() {
  pixelDensity(2);
  //size(600, 600);
  smooth(8);
  fullScreen();
  
  tickerFont = loadFont("RidetheFader-80.vlw");

  // Giving the stocks names and values to display
  tickerItems[0] = new TickerItem("CNN News headlines not yet received");
  
  getHeadlines();

  // We space the stock quotes out according to textWidth()
  float x = 0;
  println(tickerItems.length);
  for (int i = 0; i < tickerItems.length; i++) {
    if (tickerItems[i] == null) {break;}
    tickerItems[i].setX(x);
    x = x + (tickerItems[i].textW());
  }
  totalW = x;
  
  //PFont helvetica = loadFont("Helvetica-Bold-200.vlw");
  //textFont(helvetica);

  cam = new IPCapture(this, "http://shapiro.cam.lib.umich.edu/mjpg/video.mjpg", "", "");
  cam.start();

  fill(255);
  
  //call this on every new day
  resetWeather();
  updateDate();
  drawDateLabel();
}

void draw() {
  //draw blue background and other background shapes
  background(0, 0, 74);
  fill(0,0,0);
  rect(0, 200, width, 60);

    // Move and display all quotes
  for (int i = 0; i < tickerItems.length; i++) {
    if (tickerItems[i] == null) {break;}
    tickerItems[i].move();
    tickerItems[i].display(256);
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
  
  if (day != day()) {
    //we dont want to recalculate everything 
    //unless we have a new day for some things
    updateDate();
    resetWeather();
  }

  delay(10);
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
  
  if ((millis() - lastMillis >= 200) && cam.isAvailable()) {
    cam.read();
    lastMillis = millis();
  }
  
  
  float camWidth = 350;
  float camHeight = camWidth * (281.0 / 500.0);
  float tuner = 1.8;
  rect(viewOffset - 4, height - ((viewOffset + camHeight * tuner) + 4), camWidth * tuner + 8, camHeight * tuner + 8);
  image(cam, viewOffset, height - (viewOffset + camHeight * tuner), camWidth * tuner, camHeight * tuner);
}

void updateDate() {
  month = month();
  day = day();
  year = year();
  
  String[] dayArray = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"};
  int dayOfWeek = new Date().getDay(); 
  String stringDayOfWeek = dayArray[dayOfWeek - 1];

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

void drawWeatherDisplay() {
  float imageWidth = 80;
  
  String fulltempString = "H: " + highTemp + ", L: " + lowTemp;
  
  //textAlign(LEFT, TOP);
  textSize(34);
  text(weatherDescription, 2 * viewOffset  + imageWidth, viewOffset + 34);
  textSize(30);
  text(fulltempString, 2 * viewOffset + imageWidth, viewOffset + 75);
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
    String[] lines = loadStrings("https://newsapi.org/v2/top-headlines?sources=cnn&apiKey=deab2cdaf5cc4eff8f415a85f2f47e1f");
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

  } catch (Exception e) {
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
  } catch (Exception e) {
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
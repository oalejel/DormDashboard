// Exercise 17-6: Stock Ticker 

// A class to describe a stock quote
class TickerItem {
  float x;     // x position
  String display;  // What we see onscreen

  TickerItem(String s) {
    display = s + "   ";
  }
  
  // A function to set x position
  void setX(float x_) {
    x = x_;
  }
  
  // Scroll the quote and reset it when it gets far enough offscreen
  void move() {
    x = x - 20;
    if (x < width - (100 + totalW)) {
      x = width;
    } 
  }

  // Display the quote
  void display(int y) {
    textFont(tickerFont, 60);
    textAlign(LEFT);
    fill(255, 240, 72);
    text(display, x, y); 
  }
  
  // Return the width of the quote
  float textW() {
    textFont(tickerFont, 60);
    return textWidth(display); 
  }
}
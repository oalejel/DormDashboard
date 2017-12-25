/*
Usage:

CourseSchedule omarSchedule = new CourseSchedule();
Course eecs280 = new Course();
//SimpleDate(int _dayOfWeek, int _hour, int _minute)
//sunday - saturday; sunday = 0

DateRange eecsdr = DateRange(SimpleDate(2, 13, 30), SimpleDate(2, 15, 0));
eecs280.addDateRanges({eecsdr});

...

Course c = omarSchedule.getCurrentCourse();
String title = c.title();
String timeRangeString = c.timeRangeString();

text(title....
text(timeRangeString...

*/

import java.util.Calendar;

class Course {
  String title;
  String location;
  //no class will have over 10 blocks, just set a limit for the sake of java array primitives
  DateRange[] dateRanges = new DateRange[10];
  int numBlocks = 0;
  
  Course(String _title, String _location) {
    title = _title;
    location = _location;
  }
  
  void addDateRanges(DateRange[] drs) {
    for (int i = 0; i < drs.length; i++)
    dateRanges[numBlocks] = drs[i];
    numBlocks++;
  }
  
  void addDateRange(DateRange dr) {
    dateRanges[numBlocks] = dr;
    numBlocks++;
  }
  
  String timeRangeString() {
    return "time - time";
  }
}

class CourseSchedule {
  int numCourses = 0;
  //won't have more than 20 courses
  Course[] courses = new Course[20];
  
  //holds all blocks of courses in order. since Java is a terrible language and
  //doesn't make working with tuple values easy, we'll have to lists where indices match info
  ArrayList<Course> courseOrderings = new ArrayList<Course>(50);
  ArrayList<DateRange> dateRangeOrderings = new ArrayList<DateRange>(50);
  
  DateRange currentCourseRange;
  
  Course getCurrentCourse() {
    //int month = month();
    //int day = day();
    //int year = year();
    int hour = hour();
    int minute = minute();
    int dayOfWeek = new Date().getDay(); 
    
    for (int i = 0; i < numCourses; i++) {
      Course c = courses[i]; //<>//
      for (int j = 0; j < c.numBlocks; j++) {
        DateRange dr = c.dateRanges[j];
        if (dr.dayOfWeek == dayOfWeek) {
           //potential current course
           float militaryDecimal = (float)hour + ((float)minute / 60.0);
           //for example, if time is 2:33 pm, we get militaryDecimal = 14.55
           //if class is greater than 
           if (dr.militaryStart() <= militaryDecimal && dr.militaryEnd() >= militaryDecimal) {
             currentCourseRange = dr;
             return c;
           }
        }
      }
    }
    
    return null;
  }
  
  Course nextCourse() {
    int hour = hour();
    int minute = minute();
    int dayOfWeek = new Date().getDay(); 
    
    Course closestNextCourse = null;
    int closestDayOfWeek = 0;
    float closestMilitaryTime = 0.0;

    for (int i = 0; i < numCourses; i++) {
      Course c = courses[i];
      for (int j = 0; j < c.numBlocks; j++) {
        DateRange dr = c.dateRanges[j];
         float militaryDecimal = (float)hour + ((float)minute / 60.0);
        
         if (dr.dayOfWeek - dayOfWeek < closestDayOfWeek)
      }
    }
    
    return new Course("ERR", "ERR");
  }
  
  void setCourses(Course[] _courses) {
    courses = _courses;
    numCourses = _courses.length;
  }
  
  void addCourse(Course c) {
    courses[numCourses] = c;
    numCourses++;
  }
}

class SimpleDate {
  int dayOfWeek;
  int hour;
  int minute;
  
  SimpleDate(int _dayOfWeek, int _hour, int _minute) {
    dayOfWeek = _dayOfWeek;
    hour = _hour;
    minute = _minute;
  }
}

class DateRange {
  int dayOfWeek = 0;
  private int hourStart = 0;
  private int hourEnd = 0;
  private int minuteStart = 0;
  private int minuteEnd = 0;
   
   DateRange(SimpleDate d1, SimpleDate d2) {
     dayOfWeek = d1.dayOfWeek;
     hourStart = d1.hour;
     hourEnd = d2.hour;
     minuteStart = d1.minute;
     minuteEnd = d2.minute;
   }
   
   float militaryStart() {
     return (float)hourStart + ((float)minuteStart / 60.0);
   }
   
   float militaryEnd() {
     return (float)hourEnd + ((float)minuteEnd / 60.0);
   }
   
   boolean less(DateRange other) {
     if (dayOfWeek < other.dayOfWeek) {
       return true;
     } else if (dayOfWeek > other.dayOfWeek) {
       return false;
     } else {
       //same day
       if (militaryStart() < other.militaryStart()) {
         return true;
       } 
       
       return false;
     }
   }
}
/* //<>//
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

  int currentCourseIndex() {
    //int month = month();
    //int day = day();
    //int year = year();
    int hour = hour();
    int minute = minute();
    int dayOfWeek = new Date().getDay(); 

    for (int rangeIndex = 0; rangeIndex < dateRangeOrderings.size(); rangeIndex++) {
      DateRange dr = dateRangeOrderings.get(rangeIndex);
      if (dr.dayOfWeek == dayOfWeek) {
        //potential current course
        float militaryDecimal = (float)hour + ((float)minute / 60.0);
        //for example, if time is 2:33 pm, we get militaryDecimal = 14.55
        //if class is greater than 
        if (dr.militaryStart() <= militaryDecimal && dr.militaryEnd() >= militaryDecimal) {
          return rangeIndex;
        }
      }
    }

    return -1;
  }

  int nextCourseIndex() {
    int hour = hour();
    int minute = minute();
    int dayOfWeek = new Date().getDay();

    DateRange nowRange = new DateRange(new SimpleDate(dayOfWeek, hour, minute), new SimpleDate(dayOfWeek, hour, minute));
    for (int rangeIndex = 0; rangeIndex < dateRangeOrderings.size(); rangeIndex++) {
      if (nowRange.less(dateRangeOrderings.get(rangeIndex))) {
        return rangeIndex;
      }
    }

    return -1;
  }

  Course courseForIndex(int i) {
    return courseOrderings.get(i);
  }

  DateRange dateRangeForIndex(int i) {
    return dateRangeOrderings.get(i);
  }

  void setCourses(Course[] _courses) {
    for (Course c : _courses) {
      addCourse(c);
    }
  }

  void addCourse(Course c) {
    println(c.title);
    courses[numCourses] = c;
    numCourses++;

    for (int newRangeIndex = 0; newRangeIndex < c.numBlocks; newRangeIndex++) {
      boolean didAdd = false;
      int startSize = dateRangeOrderings.size();
      for (int testRangeIndex = 0; testRangeIndex < startSize; testRangeIndex++) {
        DateRange dr = dateRangeOrderings.get(testRangeIndex);
        //if the DateRange to add is less than the existing ordered dr, insert
        if (c.dateRanges[newRangeIndex].less(dr)) {
          dateRangeOrderings.add(testRangeIndex, c.dateRanges[newRangeIndex]);
          courseOrderings.add(testRangeIndex, c);
          didAdd = true;
        }
      }
      //if none added because of an empty list or all less, then add to end
      if (!didAdd) {
        dateRangeOrderings.add(c.dateRanges[newRangeIndex]);
        courseOrderings.add(c);
      }
    }
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

  String descriptionString() {

    String minuteStartPadded = "" + minuteStart;
    if (minuteStart < 10) {
      minuteStartPadded = "0" + minuteStart;
    } else if (minuteStart == 0) {
      minuteStartPadded = "00";
    }
    String minuteEndPadded = "" + minuteEnd;
    if (minuteStart < 10) {
      minuteEndPadded = "0" + minuteEnd;
    } else if (minuteEnd == 0) {
      minuteEndPadded = "00";
    }

    String startMeridiem = "AM";
    String endMeridiem = "AM";

    String hourStartString = "";
    if (hourStart > 12) {
      hourStartString = "" + (hourStart - 12);
      startMeridiem = "PM";
    } else if (hourStart == 0) {
      hourStartString = "12";
    } else {
      hourStartString = "" + hourStart;
    }
    
    String hourEndString = "";
    if (hourEnd > 12) {
      hourEndString = "" + (hourEnd - 12);
      endMeridiem = "PM";
    } else if (hourEnd == 0) {
      hourEndString = "12";
    } else {
      hourEndString = "" + hourEnd;
    }
    
    String formattedStart = hourStartString + ":" + minuteStartPadded + " " + startMeridiem;
    String formattedEnd = hourEndString + ":" + minuteEndPadded + " " + endMeridiem;
    return formattedStart + " – " + formattedEnd;
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
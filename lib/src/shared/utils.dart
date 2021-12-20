import 'package:flutter/widgets.dart';

typedef DayBuilder = Widget? Function(BuildContext context, DateTime day);
typedef FocusedDayBuilder = Widget? Function(
    BuildContext context, DateTime day, DateTime focusedDay);
typedef TextFormatter = String Function(DateTime date, dynamic locale);
enum AvailableGestures { none, verticalSwipe, horizontalSwipe, all }
enum CalendarFormat { month, twoWeeks, week }
enum StartingDayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

int getWeekdayNumber(StartingDayOfWeek weekday) {
  return StartingDayOfWeek.values.indexOf(weekday) + 1;
}

DateTime normalizeDate(DateTime date) {
  return DateTime.utc(date.year, date.month, date.day);
}

bool isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) {
    return false;
  }

  return a.year == b.year && a.month == b.month && a.day == b.day;
}

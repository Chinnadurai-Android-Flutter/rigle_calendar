import 'package:flutter/material.dart';
import 'package:rigle_calendar/rigel_soft_calendar.dart';

class RigelCalendarExample extends StatefulWidget {
  @override
  RigelCalendarState createState() => RigelCalendarState();
}

class RigelCalendarState extends State<RigelCalendarExample> {
  CalendarFormat calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rigle Calendar'),
      ),
      body: RigelCalendar(
        firstDay: DateTime(DateTime.now().year, DateTime.now().month, 1),
        lastDay: DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
        // firstDay: DateTime(
        //     DateTime.now().year, DateTime.now().month - 3, DateTime.now().day),
        // lastDay: DateTime(
        //     DateTime.now().year, DateTime.now().month + 3, DateTime.now().day),

        //disabledDays should be lower case
        disabledDays: ['sunday', 'saturday'],
        focusedDay: _focusedDay,
        calendarFormat: calendarFormat,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDay, selectedDay)) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          }
        },
        onFormatChanged: (format) {
          if (calendarFormat != format) {
            setState(() {
              calendarFormat = format;
            });
          }
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
      ),
    );
  }
}

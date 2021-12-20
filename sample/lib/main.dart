import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rigle_calendar_sample/rigle_calendar_example.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TableCalendar Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RigelCalendarExample(),
    );
  }
}

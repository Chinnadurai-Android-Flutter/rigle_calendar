import 'package:flutter/material.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';

import 'shared/utils.dart';
import 'widgets/calendar_core.dart';

class TableCalendarBase extends StatefulWidget {
  final DateTime firstDay;
  final DateTime lastDay;
  final DateTime focusedDay;
  final CalendarFormat calendarFormat;
  final DayBuilder? dowBuilder;
  final FocusedDayBuilder dayBuilder;
  final double? dowHeight;
  final double rowHeight;
  final bool sixWeekMonthsEnforced;
  final bool dowVisible;
  final Decoration? dowDecoration;
  final Decoration? rowDecoration;
  final TableBorder? tableBorder;
  final Duration formatAnimationDuration;
  final Curve formatAnimationCurve;
  final bool pageAnimationEnabled;
  final Duration pageAnimationDuration;
  final Curve pageAnimationCurve;
  final StartingDayOfWeek startingDayOfWeek;
  final AvailableGestures availableGestures;
  final SimpleSwipeConfig simpleSwipeConfig;
  final Map<CalendarFormat, String> availableCalendarFormats;
  final SwipeCallback? onVerticalSwipe;
  final void Function(DateTime focusedDay)? onPageChanged;
  final void Function(PageController pageController)? onCalendarCreated;

  TableCalendarBase({
    Key? key,
    required this.firstDay,
    required this.lastDay,
    required this.focusedDay,
    this.calendarFormat = CalendarFormat.month,
    this.dowBuilder,
    required this.dayBuilder,
    this.dowHeight,
    required this.rowHeight,
    this.sixWeekMonthsEnforced = false,
    this.dowVisible = true,
    this.dowDecoration,
    this.rowDecoration,
    this.tableBorder,
    this.formatAnimationDuration = const Duration(milliseconds: 200),
    this.formatAnimationCurve = Curves.linear,
    this.pageAnimationEnabled = true,
    this.pageAnimationDuration = const Duration(milliseconds: 300),
    this.pageAnimationCurve = Curves.easeOut,
    this.startingDayOfWeek = StartingDayOfWeek.sunday,
    this.availableGestures = AvailableGestures.all,
    this.simpleSwipeConfig = const SimpleSwipeConfig(
      verticalThreshold: 25.0,
      swipeDetectionBehavior: SwipeDetectionBehavior.continuousDistinct,
    ),
    this.availableCalendarFormats = const {
      CalendarFormat.month: 'Month',
      CalendarFormat.twoWeeks: '2 weeks',
      CalendarFormat.week: 'Week',
    },
    this.onVerticalSwipe,
    this.onPageChanged,
    this.onCalendarCreated,
  })  : assert(!dowVisible || (dowHeight != null && dowBuilder != null)),
        assert(isSameDay(focusedDay, firstDay) || focusedDay.isAfter(firstDay)),
        assert(isSameDay(focusedDay, lastDay) || focusedDay.isBefore(lastDay)),
        super(key: key);

  @override
  _TableCalendarBaseState createState() => _TableCalendarBaseState();
}

class _TableCalendarBaseState extends State<TableCalendarBase>
    with SingleTickerProviderStateMixin {
  late final ValueNotifier<double> pageHeight;
  late final PageController pageController;
  late DateTime focusedDay;
  late int previousIndex;
  late bool pageCallbackDisabled;

  @override
  void initState() {
    super.initState();
    focusedDay = widget.focusedDay;

    final rowCount = getRowCount(widget.calendarFormat, focusedDay);
    pageHeight = ValueNotifier(getPageHeight(rowCount));

    final initialPage = calculateFocusedPage(
        widget.calendarFormat, widget.firstDay, focusedDay);

    pageController = PageController(initialPage: initialPage);
    widget.onCalendarCreated?.call(pageController);

    previousIndex = initialPage;
    pageCallbackDisabled = false;
  }

  @override
  void didUpdateWidget(TableCalendarBase oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (focusedDay != widget.focusedDay ||
        widget.calendarFormat != oldWidget.calendarFormat ||
        widget.startingDayOfWeek != oldWidget.startingDayOfWeek) {
      final shouldAnimate = focusedDay != widget.focusedDay;

      focusedDay = widget.focusedDay;
      updatePage(shouldAnimate: shouldAnimate);
    }

    if (widget.rowHeight != oldWidget.rowHeight ||
        widget.dowHeight != oldWidget.dowHeight ||
        widget.dowVisible != oldWidget.dowVisible ||
        widget.sixWeekMonthsEnforced != oldWidget.sixWeekMonthsEnforced) {
      final rowCount = getRowCount(widget.calendarFormat, focusedDay);
      pageHeight.value = getPageHeight(rowCount);
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    pageHeight.dispose();
    super.dispose();
  }

  bool get _canScrollHorizontally =>
      widget.availableGestures == AvailableGestures.all ||
      widget.availableGestures == AvailableGestures.horizontalSwipe;

  bool get _canScrollVertically =>
      widget.availableGestures == AvailableGestures.all ||
      widget.availableGestures == AvailableGestures.verticalSwipe;

  void updatePage({bool shouldAnimate = false}) {
    final currentIndex = calculateFocusedPage(
        widget.calendarFormat, widget.firstDay, focusedDay);

    final endIndex = calculateFocusedPage(
        widget.calendarFormat, widget.firstDay, widget.lastDay);

    if (currentIndex != previousIndex ||
        currentIndex == 0 ||
        currentIndex == endIndex) {
      pageCallbackDisabled = true;
    }

    if (shouldAnimate && widget.pageAnimationEnabled) {
      if ((currentIndex - previousIndex).abs() > 1) {
        final jumpIndex =
            currentIndex > previousIndex ? currentIndex - 1 : currentIndex + 1;

        pageController.jumpToPage(jumpIndex);
      }

      pageController.animateToPage(
        currentIndex,
        duration: widget.pageAnimationDuration,
        curve: widget.pageAnimationCurve,
      );
    } else {
      pageController.jumpToPage(currentIndex);
    }

    previousIndex = currentIndex;
    final rowCount = getRowCount(widget.calendarFormat, focusedDay);
    pageHeight.value = getPageHeight(rowCount);

    pageCallbackDisabled = false;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SimpleGestureDetector(
          onVerticalSwipe: _canScrollVertically ? widget.onVerticalSwipe : null,
          swipeConfig: widget.simpleSwipeConfig,
          child: ValueListenableBuilder<double>(
            valueListenable: pageHeight,
            builder: (context, value, child) {
              final height =
                  constraints.hasBoundedHeight ? constraints.maxHeight : value;
              return AnimatedSize(
                vsync: this,
                duration: widget.formatAnimationDuration,
                curve: widget.formatAnimationCurve,
                alignment: Alignment.topCenter,
                child: SizedBox(
                  height: height,
                  child: child,
                ),
              );
            },
            child: CalendarCore(
              constraints: constraints,
              pageController: pageController,
              scrollPhysics: _canScrollHorizontally
                  ? PageScrollPhysics()
                  : NeverScrollableScrollPhysics(),
              firstDay: widget.firstDay,
              lastDay: widget.lastDay,
              startingDayOfWeek: widget.startingDayOfWeek,
              calendarFormat: widget.calendarFormat,
              previousIndex: previousIndex,
              focusedDay: focusedDay,
              sixWeekMonthsEnforced: widget.sixWeekMonthsEnforced,
              dowVisible: widget.dowVisible,
              dowHeight: widget.dowHeight,
              rowHeight: widget.rowHeight,
              dowDecoration: widget.dowDecoration,
              rowDecoration: widget.rowDecoration,
              tableBorder: widget.tableBorder,
              leaveDays: ['sunday', 'tuesday'],
              onPageChanged: (index, focusedMonth) {
                if (!pageCallbackDisabled) {
                  if (!isSameDay(focusedDay, focusedMonth)) {
                    focusedDay = focusedMonth;
                  }

                  if (widget.calendarFormat == CalendarFormat.month &&
                      !widget.sixWeekMonthsEnforced &&
                      !constraints.hasBoundedHeight) {
                    final rowCount = getRowCount(
                      widget.calendarFormat,
                      focusedMonth,
                    );
                    pageHeight.value = getPageHeight(rowCount);
                  }

                  previousIndex = index;
                  widget.onPageChanged?.call(focusedMonth);
                }

                pageCallbackDisabled = false;
              },
              dowBuilder: widget.dowBuilder,
              dayBuilder: widget.dayBuilder,
            ),
          ),
        );
      },
    );
  }

  double getPageHeight(int rowCount) {
    final dowHeight = widget.dowVisible ? widget.dowHeight! : 0.0;
    return dowHeight + rowCount * widget.rowHeight;
  }

  int calculateFocusedPage(
      CalendarFormat format, DateTime startDay, DateTime focusedDay) {
    switch (format) {
      case CalendarFormat.month:
        return getMonthCount(startDay, focusedDay);
      case CalendarFormat.twoWeeks:
        return getTwoWeekCount(startDay, focusedDay);
      case CalendarFormat.week:
        return getWeekCount(startDay, focusedDay);
      default:
        return getMonthCount(startDay, focusedDay);
    }
  }

  int getMonthCount(DateTime first, DateTime last) {
    final yearDif = last.year - first.year;
    final monthDif = last.month - first.month;

    return yearDif * 12 + monthDif;
  }

  int getWeekCount(DateTime first, DateTime last) {
    return last.difference(firstDayOfWeek(first)).inDays ~/ 7;
  }

  int getTwoWeekCount(DateTime first, DateTime last) {
    return last.difference(firstDayOfWeek(first)).inDays ~/ 14;
  }

  int getRowCount(CalendarFormat format, DateTime focusedDay) {
    if (format == CalendarFormat.twoWeeks) {
      return 2;
    } else if (format == CalendarFormat.week) {
      return 1;
    } else if (widget.sixWeekMonthsEnforced) {
      return 6;
    }

    final first = firstDayOfMonth(focusedDay);
    final daysBefore = _getDaysBefore(first);
    final firstToDisplay = first.subtract(Duration(days: daysBefore));

    final last = lastDayOfMonth(focusedDay);
    final daysAfter = getDaysAfter(last);
    final lastToDisplay = last.add(Duration(days: daysAfter));

    return (lastToDisplay.difference(firstToDisplay).inDays + 1) ~/ 7;
  }

  int _getDaysBefore(DateTime firstDay) {
    return (firstDay.weekday + 7 - getWeekdayNumber(widget.startingDayOfWeek)) %
        7;
  }

  int getDaysAfter(DateTime lastDay) {
    int invertedStartingWeekday =
        8 - getWeekdayNumber(widget.startingDayOfWeek);

    int daysAfter = 7 - ((lastDay.weekday + invertedStartingWeekday) % 7);
    if (daysAfter == 7) {
      daysAfter = 0;
    }

    return daysAfter;
  }

  DateTime firstDayOfWeek(DateTime week) {
    final daysBefore = _getDaysBefore(week);
    return week.subtract(Duration(days: daysBefore));
  }

  DateTime firstDayOfMonth(DateTime month) {
    return DateTime.utc(month.year, month.month, 1);
  }

  DateTime lastDayOfMonth(DateTime month) {
    final date = month.month < 12
        ? DateTime.utc(month.year, month.month + 1, 1)
        : DateTime.utc(month.year + 1, 1, 1);
    return date.subtract(const Duration(days: 1));
  }
}

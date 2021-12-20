import 'package:flutter/material.dart';

import '../shared/utils.dart' show TextFormatter;

class HeaderStyle {
  final bool titleCentered;
  final bool formatButtonVisible;
  final bool formatButtonShowsNext;
  final TextFormatter? titleTextFormatter;
  final TextStyle titleTextStyle;
  final TextStyle formatButtonTextStyle;
  final Decoration formatButtonDecoration;
  final EdgeInsets headerPadding;
  final EdgeInsets headerMargin;
  final EdgeInsets formatButtonPadding;
  final EdgeInsets leftChevronPadding;
  final EdgeInsets rightChevronPadding;
  final EdgeInsets leftChevronMargin;
  final EdgeInsets rightChevronMargin;
  final Widget leftChevronIcon;
  final Widget rightChevronIcon;
  final bool leftChevronVisible;
  final bool rightChevronVisible;
  final Decoration decoration;

  const HeaderStyle({
    this.titleCentered = false,
    this.formatButtonVisible = true,
    this.formatButtonShowsNext = true,
    this.titleTextFormatter,
    this.titleTextStyle = const TextStyle(fontSize: 17.0),
    this.formatButtonTextStyle = const TextStyle(),
    this.formatButtonDecoration = const BoxDecoration(
      border: const Border.fromBorderSide(BorderSide()),
      borderRadius: const BorderRadius.all(Radius.circular(12.0)),
    ),
    this.headerMargin = const EdgeInsets.all(0.0),
    this.headerPadding = const EdgeInsets.symmetric(vertical: 8.0),
    this.formatButtonPadding =
        const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
    this.leftChevronPadding = const EdgeInsets.all(12.0),
    this.rightChevronPadding = const EdgeInsets.all(12.0),
    this.leftChevronMargin = const EdgeInsets.symmetric(horizontal: 8.0),
    this.rightChevronMargin = const EdgeInsets.symmetric(horizontal: 8.0),
    this.leftChevronIcon = const Icon(Icons.chevron_left),
    this.rightChevronIcon = const Icon(Icons.chevron_right),
    this.leftChevronVisible = true,
    this.rightChevronVisible = true,
    this.decoration = const BoxDecoration(),
  });
}

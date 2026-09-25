import 'package:flutter/material.dart';

abstract final class AppShadows {
  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color(0x0C000000),
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x14000000),
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];
}

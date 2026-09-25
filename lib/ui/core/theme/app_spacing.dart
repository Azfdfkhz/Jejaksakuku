import 'package:flutter/material.dart';

abstract final class AppSpacing {
  // Spacing constants
  static const double s4 = 4.0;
  static const double s8 = 8.0;
  static const double s12 = 12.0;
  static const double s16 = 16.0;
  static const double s20 = 20.0;
  static const double s24 = 24.0;
  static const double s32 = 32.0;
  static const double s40 = 40.0;
  static const double s48 = 48.0;

  // EdgeInsets helpers
  static const EdgeInsets p4 = EdgeInsets.all(s4);
  static const EdgeInsets p8 = EdgeInsets.all(s8);
  static const EdgeInsets p12 = EdgeInsets.all(s12);
  static const EdgeInsets p16 = EdgeInsets.all(s16);
  static const EdgeInsets p20 = EdgeInsets.all(s20);
  static const EdgeInsets p24 = EdgeInsets.all(s24);
  static const EdgeInsets p32 = EdgeInsets.all(s32);

  static const EdgeInsets h8 = EdgeInsets.symmetric(horizontal: s8);
  static const EdgeInsets h12 = EdgeInsets.symmetric(horizontal: s12);
  static const EdgeInsets h16 = EdgeInsets.symmetric(horizontal: s16);
  static const EdgeInsets h20 = EdgeInsets.symmetric(horizontal: s20);
  static const EdgeInsets h24 = EdgeInsets.symmetric(horizontal: s24);

  static const EdgeInsets v8 = EdgeInsets.symmetric(vertical: s8);
  static const EdgeInsets v12 = EdgeInsets.symmetric(vertical: s12);
  static const EdgeInsets v16 = EdgeInsets.symmetric(vertical: s16);
  static const EdgeInsets v20 = EdgeInsets.symmetric(vertical: s20);
  static const EdgeInsets v24 = EdgeInsets.symmetric(vertical: s24);
}

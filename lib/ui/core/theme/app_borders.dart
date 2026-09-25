import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppBorders {
  // Border widths
  static const double widthDefault = 1.0;

  // Border styles
  static final Border defaultBorder = Border.all(
    color: AppColors.border,
    width: widthDefault,
  );

  // Border radius values
  static const double radiusButton = 8.0;
  static const double radiusCard = 10.0;
  static const double radiusCardLarge = 12.0;
  static const double radiusContainer = 16.0;

  // BorderRadius objects
  static final BorderRadius buttonRadius = BorderRadius.circular(radiusButton);
  static final BorderRadius cardRadius = BorderRadius.circular(radiusCard);
  static final BorderRadius containerRadius = BorderRadius.circular(radiusContainer);
}

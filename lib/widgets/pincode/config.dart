//region 1. CONFIGURATION CLASSES & ENUMS

import 'package:flutter/material.dart';

/// Defines the shape of each PIN code field.
enum PinCodeFieldShape { box, underline, circle }

/// Defines the type of error animation to be shown.
enum PinCodeErrorAnimationType { shake, clear }

/// {@template pin_theme}
/// A class to configure the visual appearance of the [PinCode].
///
/// Allows for customization of colors, sizes, borders, and shapes for the
/// different states of each field (active, inactive, selected, disabled, error).
/// {@endtemplate}
class PinCodeTheme {
  /// The border/background color for fields that have a digit.
  final Color activeColor;

  /// The background color for fields that have a digit.
  /// This is only used if `enableActiveFill` in [PinCode] is `true`.
  final Color activeFillColor;

  /// The border/background color for the field that is currently selected (has focus).
  final Color selectedColor;

  /// The background color for the field that is currently selected.
  /// This is only used if `enableActiveFill` in [PinCode] is `true`.
  final Color selectedFillColor;

  /// The border/background color for fields that are empty and not in focus.
  final Color inactiveColor;

  /// The background color for fields that are empty and not in focus.
  /// This is only used if `enableActiveFill` in [PinCode] is `true`.
  final Color inactiveFillColor;

  /// The border/background color for fields when the widget is disabled.
  final Color disabledColor;

  /// The border color for fields when they are in an error state.
  final Color errorBorderColor;

  /// The border width for fields that have a digit.
  final double activeBorderWidth;

  /// The border width for the currently selected field.
  final double selectedBorderWidth;

  /// The border width for empty, unfocused fields.
  final double inactiveBorderWidth;

  /// The border width for fields when the widget is disabled.
  final double disabledBorderWidth;

  /// The border width for fields when in an error state.
  final double errorBorderWidth;

  /// The border radius for each field.
  /// This has no effect if the shape is [PinCodeFieldShape.circle].
  final BorderRadius borderRadius;

  /// The height of each PIN field.
  final double fieldHeight;

  /// The width of each PIN field.
  final double fieldWidth;

  /// The shape of the fields ([PinCodeFieldShape.box], [PinCodeFieldShape.underline], or [PinCodeFieldShape.circle]).
  final PinCodeFieldShape shape;

  /// The outer padding for each field's container.
  final EdgeInsetsGeometry fieldOuterPadding;

  /// {@macro pin_theme}
  const PinCodeTheme({
    this.activeColor = Colors.blue,
    this.activeFillColor = Colors.white,
    this.selectedColor = Colors.blue,
    this.selectedFillColor = Colors.white,
    this.inactiveColor = Colors.grey,
    this.inactiveFillColor = Colors.white,
    this.disabledColor = Colors.grey,
    this.errorBorderColor = Colors.redAccent,
    this.activeBorderWidth = 1.0,
    this.selectedBorderWidth = 2.0,
    this.inactiveBorderWidth = 1.0,
    this.disabledBorderWidth = 1.0,
    this.errorBorderWidth = 1.0,
    this.borderRadius = BorderRadius.zero,
    this.fieldHeight = 50.0,
    this.fieldWidth = 40.0,
    this.shape = PinCodeFieldShape.underline,
    this.fieldOuterPadding = EdgeInsets.zero,
  });

  /// Creates a copy of this theme but with the given fields replaced with the new values.
  PinCodeTheme copyWith({
    Color? activeColor,
    Color? activeFillColor,
    Color? selectedColor,
    Color? selectedFillColor,
    Color? inactiveColor,
    Color? inactiveFillColor,
    Color? disabledColor,
    Color? errorBorderColor,
    double? activeBorderWidth,
    double? selectedBorderWidth,
    double? inactiveBorderWidth,
    double? disabledBorderWidth,
    double? errorBorderWidth,
    BorderRadius? borderRadius,
    double? fieldHeight,
    double? fieldWidth,
    PinCodeFieldShape? shape,
    EdgeInsetsGeometry? fieldOuterPadding,
  }) {
    return PinCodeTheme(
      activeColor: activeColor ?? this.activeColor,
      activeFillColor: activeFillColor ?? this.activeFillColor,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedFillColor: selectedFillColor ?? this.selectedFillColor,
      inactiveColor: inactiveColor ?? this.inactiveColor,
      inactiveFillColor: inactiveFillColor ?? this.inactiveFillColor,
      disabledColor: disabledColor ?? this.disabledColor,
      errorBorderColor: errorBorderColor ?? this.errorBorderColor,
      activeBorderWidth: activeBorderWidth ?? this.activeBorderWidth,
      selectedBorderWidth: selectedBorderWidth ?? this.selectedBorderWidth,
      inactiveBorderWidth: inactiveBorderWidth ?? this.inactiveBorderWidth,
      disabledBorderWidth: disabledBorderWidth ?? this.disabledBorderWidth,
      errorBorderWidth: errorBorderWidth ?? this.errorBorderWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      fieldHeight: fieldHeight ?? this.fieldHeight,
      fieldWidth: fieldWidth ?? this.fieldWidth,
      shape: shape ?? this.shape,
      fieldOuterPadding: fieldOuterPadding ?? this.fieldOuterPadding,
    );
  }
}

//endregion

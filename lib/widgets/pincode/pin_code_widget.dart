//region 3. MAIN WIDGET & STATE

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config.dart';

import 'core.dart';

/// {@template pin_code_text_field}
/// A highly customizable text field widget for entering PIN or OTP codes.
///
/// It automatically handles focus between fields, validation, and clipboard management.
/// {@endtemplate}
class PinCode extends StatefulWidget {
  /// The BuildContext of the application.
  final BuildContext appContext;

  /// The number of fields to be displayed for the PIN code.
  final int length;

  /// If `true`, the text will be obscured (like a password).
  final bool obscureText;

  /// The character used for obscuring the text if [obscureText] is `true`.
  final String obscuringCharacter;

  /// A custom widget for obscuring the text. If provided, it overrides [obscuringCharacter].
  final Widget? obscuringWidget;

  /// If `true`, enables haptic feedback (vibration) upon input.
  final bool useHapticFeedback;

  /// Callback that is executed every time the text changes.
  final ValueChanged<String>? onChanged;

  /// Callback that is executed when all fields have been filled.
  final ValueChanged<String>? onCompleted;

  /// Callback that is executed when the user submits the field from the keyboard.
  final ValueChanged<String>? onSubmitted;

  /// Callback that is executed when the user has finished editing.
  final VoidCallback? onEditingComplete;

  /// The style of the text within each field.
  final TextStyle? textStyle;

  /// The background color for the entire widget.
  final Color? backgroundColor;

  /// The alignment of the fields within the row.
  final MainAxisAlignment mainAxisAlignment;

  /// The duration for animations (e.g., the error shake animation).
  final Duration animationDuration;

  /// The curve for animations.
  final Curve animationCurve;

  /// The type of keyboard to display.
  final TextInputType keyboardType;

  /// If `true`, the field will be autofocused when it is displayed.
  final bool autoFocus;

  /// A [FocusNode] to control the focus of the hidden text field.
  final FocusNode? focusNode;

  /// A list of [TextInputFormatter]s to apply to the hidden [TextFormField].
  final List<TextInputFormatter> inputFormatters;

  /// If `false`, the widget is disabled for user interaction.
  final bool enabled;

  /// A [TextEditingController] to control the text of the field.
  final TextEditingController? controller;

  /// If `true`, the background of the fields will be filled with colors from the theme.
  final bool enableActiveFill;

  /// If `true`, the keyboard will be automatically dismissed upon completing the code.
  final bool autoDismissKeyboard;

  /// If `true`, the internal controllers ([TextEditingController] and [FocusNode]) will be disposed
  /// automatically when the widget is disposed.
  final bool autoDisposeControllers;

  /// The text capitalization scheme for the keyboard.
  final TextCapitalization textCapitalization;

  /// The keyboard action (e.g., `done`, `next`).
  final TextInputAction textInputAction;

  /// A [StreamController] to trigger the error animation externally.
  final StreamController<PinCodeErrorAnimationType>? errorAnimationController;

  /// A function that runs before pasting text from the clipboard.
  /// Return `true` to allow pasting, `false` to deny it.
  final bool Function(String? text)? beforeTextPaste;

  /// A callback to detect taps on the widget area.
  final Function? onTap;

  /// The visual configuration of the fields, defined by [PinCodeTheme].
  final PinCodeTheme pinTheme;

  /// A validator for the underlying [TextFormField].
  final FormFieldValidator<String>? validator;

  /// A callback that runs when the form is saved.
  final FormFieldSetter<String>? onSaved;

  /// The autovalidation mode for the form.
  final AutovalidateMode autovalidateMode;

  /// The vertical space between the fields and the error text (if any).
  final double errorTextSpace;

  /// If `true`, enables autofill for OTP codes from SMS messages.
  final bool enablePinAutofill;

  /// The duration of the "shake" error animation.
  final int errorAnimationDuration;

  /// A list of box shadows to apply to each field.
  final List<BoxShadow>? boxShadows;

  /// If `true`, a cursor will be shown in the active field.
  final bool showCursor;

  /// The color of the cursor.
  final Color? cursorColor;

  /// The width of the cursor.
  final double cursorWidth;

  /// The height of the cursor.
  final double? cursorHeight;

  /// The action to take with the autofill context when the widget is disposed.
  final AutofillContextAction onAutoFillDisposeAction;

  /// A character to display as a hint or placeholder in empty fields.
  final String? hintCharacter;

  /// The style of the hint text ([hintCharacter]).
  final TextStyle? hintStyle;

  /// The scroll padding when the field gains focus.
  final EdgeInsets scrollPadding;

  /// If `true`, the field is read-only.
  final bool readOnly;

  /// If `true`, the widget will attempt to re-focus if it unexpectedly loses focus.
  final bool autoUnfocus;

  /// An optional builder to create separator widgets between each field.
  final IndexedWidgetBuilder? separatorBuilder;

  /// {@macro pin_code_text_field}
  const PinCode({
    super.key,
    required this.appContext,
    required this.length,
    this.controller,
    this.obscureText = false,
    this.obscuringCharacter = '●',
    this.obscuringWidget,
    this.onChanged,
    this.onCompleted,
    this.backgroundColor,
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
    this.animationDuration = const Duration(milliseconds: 150),
    this.animationCurve = Curves.easeInOut,
    this.keyboardType = TextInputType.number,
    this.autoFocus = false,
    this.focusNode,
    this.onTap,
    this.enabled = true,
    this.inputFormatters = const <TextInputFormatter>[],
    this.textStyle,
    this.useHapticFeedback = false,
    this.enableActiveFill = false,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction = TextInputAction.done,
    this.autoDismissKeyboard = true,
    this.autoDisposeControllers = true,
    this.onSubmitted,
    this.onEditingComplete,
    this.errorAnimationController,
    this.beforeTextPaste,
    this.pinTheme = const PinCodeTheme(),
    this.validator,
    this.onSaved,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.errorTextSpace = 16,
    this.enablePinAutofill = true,
    this.errorAnimationDuration = 500,
    this.boxShadows,
    this.showCursor = true,
    this.cursorColor,
    this.cursorWidth = 2,
    this.cursorHeight,
    this.hintCharacter,
    this.hintStyle,
    this.readOnly = false,
    this.autoUnfocus = true,
    this.onAutoFillDisposeAction = AutofillContextAction.commit,
    this.scrollPadding = const EdgeInsets.all(20),
    this.separatorBuilder,
  });

  @override
  State<PinCode> createState() => _PinCodeState();
}

/// The state class for [PinCode].
/// It uses [PinCodeMixin] to separate the state logic.
class _PinCodeState extends State<PinCode>
    with TickerProviderStateMixin, PinCodeMixin {}

//endregion

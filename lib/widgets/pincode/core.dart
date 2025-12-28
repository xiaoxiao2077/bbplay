//region 4. CORE LOGIC MIXIN

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config.dart';
import 'pin_code_painters.dart';

import 'pin_code_widget.dart';

/// A `mixin` that contains all the state and UI logic for [PinCode].
/// This keeps the [_PinCodeState] class clean and focused on its lifecycle.
mixin PinCodeMixin on State<PinCode> {
  TextEditingController? textEditingController;
  FocusNode? focusNode;
  late List<String> inputList;
  int selectedIndex = 0;
  BorderRadius? borderRadius;

  // Animation Controllers
  late AnimationController errorController;
  late AnimationController cursorController;
  late Animation<Offset> offsetAnimation;
  late Animation<double> cursorAnimation;

  StreamSubscription<PinCodeErrorAnimationType>? errorAnimationSubscription;
  bool isInErrorMode = false;

  PinCodeTheme get pinTheme => widget.pinTheme;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  /// Initializes all controllers, listeners, and animations.
  void _initialize() {
    textEditingController = widget.controller ?? TextEditingController();
    textEditingController!.addListener(_onTextChanged);
    focusNode = widget.focusNode ?? FocusNode();
    focusNode!.addListener(() => setState(() {}));

    inputList = List<String>.filled(widget.length, "");
    if (textEditingController!.text.isNotEmpty) {
      _setTextToInput(textEditingController!.text);
    }

    if (pinTheme.shape != PinCodeFieldShape.circle) {
      borderRadius = pinTheme.borderRadius;
    }

    errorController = AnimationController(
      duration: Duration(milliseconds: widget.errorAnimationDuration),
      vsync: this as TickerProvider,
    );
    cursorController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this as TickerProvider,
    );

    offsetAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0.1, 0.0)).animate(
      CurvedAnimation(parent: errorController, curve: Curves.elasticIn),
    );

    cursorAnimation = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(CurvedAnimation(parent: cursorController, curve: Curves.easeIn));

    if (widget.showCursor) {
      cursorController.repeat();
    }

    errorController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        errorController.reverse();
      }
    });

    errorAnimationSubscription = widget.errorAnimationController?.stream.listen(
      (error) {
        if (error == PinCodeErrorAnimationType.shake) {
          errorController.forward();
          setState(() => isInErrorMode = true);
        } else if (error == PinCodeErrorAnimationType.clear) {
          setState(() => isInErrorMode = false);
        }
      },
    );
  }

  /// Disposes all resources used by the widget.
  void _dispose() {
    textEditingController?.removeListener(_onTextChanged);
    if (widget.autoDisposeControllers) {
      textEditingController?.dispose();
      focusNode?.dispose();
    }
    errorAnimationSubscription?.cancel();
    errorController.dispose();
    cursorController.dispose();
  }

  /// Handles the logic whenever the text in the controller changes.
  void _onTextChanged() {
    if (widget.useHapticFeedback) {
      HapticFeedback.lightImpact();
    }
    if (isInErrorMode) {
      setState(() => isInErrorMode = false);
    }

    String currentText = textEditingController!.text;
    if (widget.enabled && inputList.join("") != currentText) {
      if (currentText.length >= widget.length) {
        if (widget.onCompleted != null) {
          if (currentText.length > widget.length) {
            currentText = currentText.substring(0, widget.length);
          }
          Future.delayed(
            const Duration(milliseconds: 100),
            () => widget.onCompleted!(currentText),
          );
        }
        if (widget.autoDismissKeyboard) {
          focusNode!.unfocus();
        }
      }
      widget.onChanged?.call(currentText);
    }
    _setTextToInput(currentText);
  }

  /// Handles the logic for requesting or removing focus.
  void _onFocus() {
    if (widget.autoUnfocus &&
        focusNode!.hasFocus &&
        MediaQuery.of(context).viewInsets.bottom == 0) {
      focusNode!.unfocus();
      Future.delayed(
        const Duration(microseconds: 1),
        () => focusNode!.requestFocus(),
      );
    } else {
      focusNode!.requestFocus();
    }
  }

  /// Updates the `inputList` to reflect the current text in the UI.
  void _setTextToInput(String data) {
    if (!mounted) return;

    var updatedList = List<String>.filled(widget.length, "");
    for (int i = 0; i < widget.length; i++) {
      if (i < data.length) {
        updatedList[i] = data[i];
      }
    }
    setState(() {
      selectedIndex = data.length;
      inputList = updatedList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: offsetAnimation,
      child: Container(
        height: (widget.validator == null)
            ? pinTheme.fieldHeight
            : pinTheme.fieldHeight + widget.errorTextSpace,
        color: widget.backgroundColor,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[_buildHiddenTextFormField(), _buildPinFields()],
        ),
      ),
    );
  }

  /// Builds the hidden [TextFormField] that actually handles the text input.
  Widget _buildHiddenTextFormField() {
    return AbsorbPointer(
      absorbing: true,
      child: AutofillGroup(
        onDisposeAction: widget.onAutoFillDisposeAction,
        child: TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          enabled: widget.enabled,
          autofillHints: widget.enablePinAutofill && widget.enabled
              ? <String>[AutofillHints.oneTimeCode]
              : null,
          autofocus: widget.autoFocus,
          autocorrect: false,
          keyboardType: widget.keyboardType,
          textCapitalization: widget.textCapitalization,
          validator: widget.validator,
          onSaved: widget.onSaved,
          autovalidateMode: widget.autovalidateMode,
          inputFormatters: [
            ...widget.inputFormatters,
            LengthLimitingTextInputFormatter(widget.length),
          ],
          onFieldSubmitted: widget.onSubmitted,
          onEditingComplete: widget.onEditingComplete,
          showCursor: false,
          cursorWidth: 0.01,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.all(0),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
          ),
          style: TextStyle(
            color: Colors.transparent,
            height: 0.01,
            fontSize: kIsWeb ? 1 : 0.01,
          ),
          scrollPadding: widget.scrollPadding,
          readOnly: widget.readOnly,
        ),
      ),
    );
  }

  /// Builds the visible PIN fields that the user interacts with.
  Widget _buildPinFields() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: () {
          widget.onTap?.call();
          _onFocus();
        },
        onLongPress: widget.enabled
            ? () async {
                var data = await Clipboard.getData("text/plain");
                if (data != null && data.text != null) {
                  if (widget.beforeTextPaste?.call(data.text) ?? true) {
                    textEditingController!.text = data.text!;
                  }
                }
              }
            : null,
        child: Row(
          mainAxisAlignment: widget.mainAxisAlignment,
          children: _generateFields(),
        ),
      ),
    );
  }

  /// Generates the list of widgets for each individual PIN field.
  List<Widget> _generateFields() {
    var result = <Widget>[];
    for (int i = 0; i < widget.length; i++) {
      result.add(
        AnimatedContainer(
          padding: pinTheme.fieldOuterPadding,
          curve: widget.animationCurve,
          duration: widget.animationDuration,
          width: pinTheme.fieldWidth,
          height: pinTheme.fieldHeight,
          decoration: BoxDecoration(
            color:
                widget.enableActiveFill ? _getFillColor(i) : Colors.transparent,
            boxShadow: widget.boxShadows,
            shape: pinTheme.shape == PinCodeFieldShape.circle
                ? BoxShape.circle
                : BoxShape.rectangle,
            borderRadius: borderRadius,
            border: _getBorder(i),
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: widget.animationDuration,
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: _buildChild(i),
            ),
          ),
        ),
      );
      if (widget.separatorBuilder != null && i < widget.length - 1) {
        result.add(widget.separatorBuilder!(context, i));
      }
    }
    return result;
  }

  /// Builds the content of an individual PIN field (digit, cursor, hint, etc.).
  // En PinCodeMixin

  /// Construye el contenido de un campo de PIN individual (dígito, cursor, pista, etc.).
  Widget _buildChild(int index) {
    bool hasFocus = focusNode!.hasFocus;

    // Determina qué se va a mostrar: el dígito, el hint o el widget de ocultación.
    Widget characterChild;
    if (inputList[index].isNotEmpty) {
      if (widget.obscureText) {
        characterChild = widget.obscuringWidget ??
            Text(
              widget.obscuringCharacter,
              key: ValueKey('obscure_$index'),
              style: widget.textStyle,
            );
      } else {
        characterChild = Text(
          inputList[index],
          key: ValueKey('char_$index'),
          style: widget.textStyle,
        );
      }
    } else if (widget.hintCharacter != null) {
      characterChild = Text(
        widget.hintCharacter!,
        key: ValueKey('hint_$index'),
        style: widget.hintStyle,
      );
    } else {
      // Campo vacío sin hint
      characterChild = SizedBox.shrink(key: ValueKey('empty_$index'));
    }

    // Determina si el cursor debe ser visible en este campo.
    bool isCursorVisible = widget.showCursor &&
        hasFocus &&
        (selectedIndex == index ||
            (selectedIndex == index + 1 && index + 1 == widget.length));

    if (isCursorVisible) {
      final cursorColor =
          widget.cursorColor ?? Theme.of(context).colorScheme.secondary;
      final cursorHeight =
          widget.cursorHeight ?? (widget.textStyle?.fontSize ?? 20) + 8;

      // *** LA CORRECCIÓN CLAVE ***
      // Usamos un Stack para dibujar el cursor ENCIMA del dígito.
      return Stack(
        alignment: Alignment.center,
        children: [
          characterChild, // El dígito o hint va en el fondo
          FadeTransition(
            opacity: cursorAnimation,
            child: CustomPaint(
              size: Size(0, cursorHeight),
              painter: PinCodePainter(
                cursorColor: cursorColor,
                cursorWidth: widget.cursorWidth,
              ),
            ),
          ),
        ],
      );
    }

    return characterChild;
  }

  // Helper methods to get dynamic styles

  Color _getFillColor(int index) {
    if (!widget.enabled) return pinTheme.disabledColor;
    if (focusNode!.hasFocus && selectedIndex == index) {
      return pinTheme.selectedFillColor;
    }
    if (selectedIndex > index) return pinTheme.activeFillColor;
    return pinTheme.inactiveFillColor;
  }

  Border? _getBorder(int index) {
    final color = _getBorderColor(index);
    final width = _getBorderWidth(index);

    if (pinTheme.shape == PinCodeFieldShape.underline) {
      return Border(
        bottom: BorderSide(color: color, width: width),
      );
    }
    return Border.all(color: color, width: width);
  }

  Color _getBorderColor(int index) {
    if (isInErrorMode) return pinTheme.errorBorderColor;
    if (!widget.enabled) return pinTheme.disabledColor;
    if (focusNode!.hasFocus && selectedIndex == index) {
      return pinTheme.selectedColor;
    }
    if (selectedIndex > index) return pinTheme.activeColor;
    return pinTheme.inactiveColor;
  }

  double _getBorderWidth(int index) {
    if (isInErrorMode) return pinTheme.errorBorderWidth;
    if (!widget.enabled) return pinTheme.disabledBorderWidth;
    if (focusNode!.hasFocus && selectedIndex == index) {
      return pinTheme.selectedBorderWidth;
    }
    if (selectedIndex > index) return pinTheme.activeBorderWidth;
    return pinTheme.inactiveBorderWidth;
  }
}
//endregion

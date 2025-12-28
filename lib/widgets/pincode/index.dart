/// A barrel file that exports the public-facing components of the pin_code library.
///
/// This file allows consumers of the library to import all necessary widgets,
/// configurations, and painters with a single import statement:
///
/// ```dart
/// import 'package:pin_code/pin_code.dart';
/// ```
library;

/// Exports configuration classes and enums.
///
/// This includes [PinTheme] for styling the widget, and enums such as
/// [PinCodeFieldShape] and [ErrorAnimationType] that define behavior and appearance.
export 'config.dart';

/// Exports the core logic or foundational elements of the library.
///
/// This might include mixins or base classes that the main widget relies upon.
export 'core.dart';

/// Exports custom painters used within the widget.
///
/// This includes painters like [CursorPainter], which is responsible for drawing
/// the cursor in the active PIN field.
export 'pin_code_painters.dart';

/// Exports the main, public-facing widget of the library.
///
/// This is the [PinCode] widget that developers will primarily use.
export 'pin_code_widget.dart';

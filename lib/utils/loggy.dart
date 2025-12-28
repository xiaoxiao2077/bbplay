import 'dart:io';
import 'dart:async';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class Loggy {
  static File? _logFile;
  static late final Logger _logger;

  /// 必须在应用启动时调用，例如在 main 函数中
  static Future<void> init() async {
    final directory = await getTemporaryDirectory();
    _logFile = File('${directory.path}/app_logs.txt');
    if (!await _logFile!.exists()) {
      await _logFile!.create();
    }

    final consolePrinter = PrettyPrinter(
      methodCount: 2, // 打印堆栈时显示的方法数
      colors: true, // 彩色输出
    );
    _logger = Logger(
      level: Level.all, // 日志级别
      filter: ProductionFilter(), // 生产环境下也打印所有级别日志
      printer:
          _LogFilePrinter([consolePrinter, SimplePrinter(printTime: true)]),
    );

    d('Loggy initialized. Log file path: ${_logFile?.path}');
  }

  /// 将日志写入文件
  static Future<void> _writeToFile(String logMessage) async {
    if (_logFile == null) return;
    await _logFile!.writeAsString('$logMessage\n', mode: FileMode.append);
  }

  static void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  static void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  static void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}

class _LogFilePrinter extends LogPrinter {
  final List<LogPrinter> printers;

  _LogFilePrinter(this.printers);

  @override
  List<String> log(LogEvent event) {
    List<String> output = [];
    for (final printer in printers) {
      output.addAll(printer.log(event));
    }
    Loggy._writeToFile(output.join('\n'));
    return output;
  }
}

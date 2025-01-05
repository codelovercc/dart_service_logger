import 'dart:convert';

import 'package:dart_logging_abstraction/dart_logging_abstraction.dart';
import 'package:dart_service_provider/dart_service_provider.dart';
import 'package:logger/logger.dart';

/// Implementation of [ILoggerFactory] for logger package.
class LoggerLoggerFactory implements ILoggerFactory {
  final Logger _logger;
  final LoggerOptions _options;
  final LogLevelMap _levelMap;

  /// Constructor
  ///
  /// - [logger] the [Logger]
  /// - [options] options for logging.
  const LoggerLoggerFactory({required Logger logger, required LoggerOptions options, required LogLevelMap levelMap})
      : _logger = logger,
        _options = options,
        _levelMap = levelMap;

  @override
  ILogger create(String name) => LoggerLogger4(
        logger: _logger,
        minLevel: _options.minLevel,
        levelMap: _levelMap,
        name: name.isNotEmpty ? name : _options.defaultLoggerName,
      );

  @override
  ILogger4<T> createLogger<T>() => LoggerLogger4<T>(logger: _logger, minLevel: _options.minLevel, levelMap: _levelMap);
}

/// [LogLevel] to [Level] mapper
class LogLevelMap {
  const LogLevelMap();

  /// Returns the [LogLevel] corresponding to [Level]
  LogLevel mapFrom(Level l) {
    switch (l) {
      case Level.all:
      case Level.trace:
        return LogLevel.trace;
      case Level.debug:
        return LogLevel.debug;
      case Level.info:
        return LogLevel.info;
      case Level.warning:
        return LogLevel.warn;
      case Level.error:
        return LogLevel.error;
      case Level.fatal:
        return LogLevel.fatal;
      case Level.off:
        return LogLevel.none;
      default:
        throw UnsupportedError("The $l level is un supported or it's deprecated.");
    }
  }

  /// Returns the [Level] corresponding to [LogLevel]
  Level mapTo(LogLevel l) {
    switch (l) {
      case LogLevel.trace:
        return Level.trace;
      case LogLevel.debug:
        return Level.debug;
      case LogLevel.info:
        return Level.info;
      case LogLevel.warn:
        return Level.warning;
      case LogLevel.error:
        return Level.error;
      case LogLevel.fatal:
        return Level.fatal;
      case LogLevel.none:
        return Level.off;
    }
  }
}

/// Implementation of [ILogger4] for logger package.
class LoggerLogger4<T> extends ILogger4<T> {
  final LogLevelMap _levelMap;
  final Logger _logger;
  final LogLevel _minLevel;

  /// - [minLevel] the minimal log level
  LoggerLogger4({required Logger logger, required LogLevel minLevel, required LogLevelMap levelMap, super.name})
      : _logger = logger,
        _minLevel = minLevel,
        _levelMap = levelMap;

  @override
  bool isEnabled(LogLevel logLevel) => logLevel >= _minLevel && logLevel != LogLevel.none;

  @override
  void log(dynamic message, LogLevel logLevel, {Object? error, StackTrace? stackTrace}) {
    if (!isEnabled(logLevel)) {
      return;
    }
    _logger.log(
      _levelMap.mapTo(logLevel),
      LoggerMessage(message: message, loggerName: name, logLevel: logLevel),
      error: error,
      stackTrace: stackTrace,
    );
  }
}

/// Define a message entry for [Logger]
class LoggerMessage {
  /// The message that will pass to [Logger]
  final dynamic message;

  /// The logger name that this message belongs to
  final String loggerName;

  /// The level
  final LogLevel logLevel;

  /// Constructor
  ///
  /// - [message] The message that will pass to [Logger]
  /// - [loggerName] The logger name that this message belongs to
  /// - [logLevel] The level
  const LoggerMessage({required this.message, required this.loggerName, required this.logLevel});
}

/// The common logger printer
///
/// You can run the example in `example/example.dart` to view the prints.
class CommonLoggerPrinter extends PrettyPrinter {
  /// Whether to indent the message of json type
  ///
  /// In development environment, it's recommended to set to `true`.
  /// In production environment, it's recommended to set to `false`.
  final bool intentJson;

  static final Map<LogLevel, String Function(String msg)> _levelMsgColors = {
    LogLevel.trace: (msg) => msg,
    LogLevel.debug: (msg) => msg,
    LogLevel.info: (msg) => msg,
    LogLevel.warn: (msg) => AnsiColors.darkYellowFg(msg),
    LogLevel.error: (msg) => AnsiColors.redFg(msg),
    LogLevel.fatal: (msg) => AnsiColors.magentaFg(msg),
  };

  static final Map<LogLevel, String Function(String msg)> _levelLabelColors = {
    LogLevel.trace: (msg) => AnsiColors.darkGreyFg.withBg(msg, AnsiColors.blackFg),
    LogLevel.debug: (msg) => AnsiColors.grayFg.withBg(msg, AnsiColors.blackFg),
    LogLevel.info: (msg) => AnsiColors.blueFg.withBg(msg, AnsiColors.lightGrayFg),
    LogLevel.warn: (msg) => AnsiColors.yellowFg.withBg(msg, AnsiColors.blackFg),
    LogLevel.error: (msg) => AnsiColors.blackFg.withBg(msg, AnsiColors.redFg),
    LogLevel.fatal: (msg) => AnsiColors.whiteFg.withBg(msg, AnsiColors.magentaFg),
  };

  /// Construct [CommonLoggerPrinter]
  ///
  /// - [intentJson] Whether to indent the message of json type
  CommonLoggerPrinter({this.intentJson = false});

  @override
  List<String> log(LogEvent event) {
    final logMsg = event.message as LoggerMessage;
    final buffer = StringBuffer();
    final labelColor = _levelLabelColors[logMsg.logLevel] ?? (msg) => msg;
    // level
    buffer.write(labelColor("[${logMsg.logLevel.name.toUpperCase()}]"));
    // logger name
    buffer.write(" [${logMsg.loggerName}]");
    // time
    buffer.write(" [UTC ${event.time.toUtc().toIso8601String()}] [Local ${event.time.toLocal().toIso8601String()}]");
    final msgColor = _levelMsgColors[logMsg.logLevel] ?? (msg) => msg;
    // print message at new line
    buffer.write("\n${msgColor(stringifyMessage(logMsg.message))}");
    if (event.error != null) {
      final errorString = event.error.toString();
      if (errorString.isNotEmpty) {
        // print error at new line
        buffer.write("\n${msgColor(errorString)}");
      }
      final stackStr = formatStackTrace(
        event.stackTrace ?? StackTrace.current,
        null,
      );
      if (stackStr != null && stackStr.isNotEmpty) {
        // print error stack trace at new line
        buffer.write("\n${msgColor(stackStr)}");
      }
    }

    return [buffer.toString()];
  }

  /// Convert [message] to [String] and handle json type.
  @override
  String stringifyMessage(dynamic message) {
    final finalMessage = message is Function ? message() : message;
    if (finalMessage is Map || finalMessage is Iterable) {
      var encoder = JsonEncoder.withIndent(intentJson ? '  ' : null, toEncodableFallback);
      return encoder.convert(finalMessage);
    } else {
      return finalMessage.toString();
    }
  }
}

/// Static [AnsiColor]s
///
/// [256 ANSI Color Codes](https://hexdocs.pm/color_palette/ansi_color_codes.html)
abstract class AnsiColors {
  /// Black foreground color
  ///
  /// [256 ANSI Color Codes](https://hexdocs.pm/color_palette/ansi_color_codes.html)
  static AnsiColor get blackFg => AnsiColor.fg(0);

  /// White foreground color
  ///
  /// [256 ANSI Color Codes](https://hexdocs.pm/color_palette/ansi_color_codes.html)
  static AnsiColor get whiteFg => AnsiColor.fg(231);

  /// Gray foreground color
  ///
  /// [256 ANSI Color Codes](https://hexdocs.pm/color_palette/ansi_color_codes.html)
  static AnsiColor get grayFg => AnsiColor.fg(AnsiColor.grey(.5));

  /// Light gray foreground color
  ///
  /// [256 ANSI Color Codes](https://hexdocs.pm/color_palette/ansi_color_codes.html)
  static AnsiColor get lightGrayFg => AnsiColor.fg(252);

  /// Dark gray foreground color
  static AnsiColor get darkGreyFg => AnsiColor.fg(AnsiColor.grey(.25));

  /// Blue foreground color
  ///
  /// [256 ANSI Color Codes](https://hexdocs.pm/color_palette/ansi_color_codes.html)
  static AnsiColor get blueFg => AnsiColor.fg(21);

  /// Yellow foreground color
  ///
  /// [256 ANSI Color Codes](https://hexdocs.pm/color_palette/ansi_color_codes.html)
  static AnsiColor get yellowFg => AnsiColor.fg(226);

  /// Dark yellow foreground color
  ///
  /// [256 ANSI Color Codes](https://hexdocs.pm/color_palette/ansi_color_codes.html)
  static AnsiColor get darkYellowFg => AnsiColor.fg(58);

  /// Red foreground color
  ///
  /// [256 ANSI Color Codes](https://hexdocs.pm/color_palette/ansi_color_codes.html)
  static AnsiColor get redFg => AnsiColor.fg(196);

  /// Magenta foreground color
  ///
  /// [256 ANSI Color Codes](https://hexdocs.pm/color_palette/ansi_color_codes.html)
  static AnsiColor get magentaFg => AnsiColor.fg(201);
}

/// Provide [AnsiColor] extension methods
extension AnsiColorExtensions on AnsiColor {
  /// Use current color as foreground and returns [String] with [bg] color.
  ///
  /// - [msg] The message string will be colored.
  /// - [bg] The background color
  String withBg(String msg, AnsiColor bg) {
    return _colorStr(msg, this, bg);
  }

  /// Use current color as background and returns [String] with [fg] color.
  ///
  /// - [msg] The message string will be colored.
  /// - [fg] The foreground color
  String withFg(String msg, AnsiColor fg) {
    return _colorStr(msg, fg, this);
  }

  /// Whether the current [AnsiColor] is the foreground color.
  bool isFg() => fg != null;

  /// Whether the current [AnsiColor] is the background color.
  bool isBg() => bg != null;

  static String _colorStr(String msg, AnsiColor foreground, AnsiColor background) {
    String fgStr;
    if (foreground.color) {
      fgStr = foreground.isFg() ? foreground.toString() : foreground.toFg().toString();
    } else {
      fgStr = '';
    }
    String bgStr;
    if (background.color) {
      bgStr = background.isBg() ? background.toString() : background.toBg().toString();
    } else {
      bgStr = '';
    }
    return '$fgStr$bgStr$msg${AnsiColor.ansiDefault}';
  }
}

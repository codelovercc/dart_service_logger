import 'package:dart_service_logger/dart_service_logger.dart';
import 'package:dart_service_provider/dart_service_provider.dart';
import 'package:logger/logger.dart';

/// Provide extension methods that helps enable [Logger] as the logging services.
extension LoggerLoggingbuilderExtensions on LoggingBuilder {
  /// Use [Logger](https://pub.dev/packages/logger) as the logging services
  void useLogger() {
    services.tryAddSingleton<LogFilter, LogFilter>((p) {
      final env = p.getTypedService<IEnvironment>();
      return env?.isProduction == true ? ProductionFilter() : DevelopmentFilter();
    });
    services.tryAddSingleton<LogLevelMap, LogLevelMap>((_) => const LogLevelMap());

    services.tryAddSingleton<LogPrinter, LogPrinter>((p) {
      final env = p.getTypedService<IEnvironment>();
      final intentJson = env?.isProduction == true ? false : true;
      return CommonLoggerPrinter(intentJson: intentJson);
    });

    services.tryAddSingleton<LogOutput, LogOutput>((_) => ConsoleOutput());

    services.tryAddSingleton<Logger, Logger>((p) {
      final filter = p.getRequiredService<LogFilter>();
      final printer = p.getRequiredService<LogPrinter>();
      final output = p.getRequiredService<LogOutput>();
      final options = p.getRequiredService<LoggerOptions>();
      final levelMap = p.getRequiredService<LogLevelMap>();
      return Logger(filter: filter, printer: printer, output: output, level: levelMap.mapTo(options.minLevel));
    });

    replaceLoggerFactory<LoggerLoggerFactory>((p) {
      final logger = p.getRequiredService<Logger>();
      final options = p.getRequiredService<LoggerOptions>();
      final levelMap = p.getRequiredService<LogLevelMap>();
      return LoggerLoggerFactory(logger: logger, options: options, levelMap: levelMap);
    });
  }
}

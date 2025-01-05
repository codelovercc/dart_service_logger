import 'package:dart_logging_abstraction/dart_logging_abstraction.dart';
import 'package:dart_service_logger/dart_service_logger.dart';
import 'package:dart_service_provider/dart_service_provider.dart';
import 'package:test/test.dart';

void main() {
  group("Logger implementation tests", () {
    late ServiceCollection services;
    late ServiceProvider provider;
    setUp(() {
      services = ServiceCollection();
      services.addEnvironment(Environment(name: Environments.development));
      services.addLogging(config: (b) {
        b.useLogger();
        b.replaceOptions<LoggerOptions>(
          (p) => LoggerOptions(minLevel: LogLevel.trace, defaultLoggerName: "Global"),
        );
      });
      provider = services.buildServiceProvider();
    });
    tearDown(() {
      provider.dispose();
    });
    test("Global logger test", () {
      final globalLogger = provider.getRequiredService<ILogger>();
      expect(globalLogger, isA<LoggerLogger4<dynamic>>());
      final globalLoggerTester = LoggerTester(logger: globalLogger);
      final options = provider.getRequiredService<LoggerOptions>();
      expect(globalLoggerTester.name, equals(options.defaultLoggerName));

      globalLoggerTester.fatal("Fatal on globalLogger", error: Error(), stackTrace: StackTrace.current);
      globalLoggerTester.error("Error on globalLogger", error: Error(), stackTrace: StackTrace.current);
      globalLoggerTester.warn("Warning on globalLogger");
      globalLoggerTester.info("Info on globalLogger");
      globalLoggerTester.debug("Debug on globalLogger");
      globalLoggerTester.trace("Trace on globalLogger");
      globalLoggerTester.log("Should not be printed.", LogLevel.none);

      expect(globalLoggerTester.printedLevels[LogLevel.fatal], isTrue);
      expect(globalLoggerTester.printedLevels[LogLevel.error], isTrue);
      expect(globalLoggerTester.printedLevels[LogLevel.warn], isTrue);
      expect(globalLoggerTester.printedLevels[LogLevel.info], isTrue);
      expect(globalLoggerTester.printedLevels[LogLevel.debug], isTrue);
      expect(globalLoggerTester.printedLevels[LogLevel.trace], isTrue);
      expect(globalLoggerTester.printedLevels[LogLevel.none], isFalse);
    });
    test("Logger factory test", () {
      final loggerFactory = provider.getRequiredLoggerFactory();
      expect(loggerFactory, isA<LoggerLoggerFactory>());
      final logger = loggerFactory.createLogger<MyClass>();
      final loggerTester = LoggerTester(logger: logger);
      expect(loggerTester.name, equals("$MyClass"));

      loggerTester.fatal("Fatal on logger", error: Error(), stackTrace: StackTrace.current);
      loggerTester.error("Error on logger", error: Error(), stackTrace: StackTrace.current);
      loggerTester.warn("Warning on logger");
      loggerTester.info("Info on logger");
      loggerTester.debug("Debug on logger");
      loggerTester.trace("Trace on logger");
      loggerTester.log("Should not be printed.", LogLevel.none);

      expect(loggerTester.printedLevels[LogLevel.fatal], isTrue);
      expect(loggerTester.printedLevels[LogLevel.error], isTrue);
      expect(loggerTester.printedLevels[LogLevel.warn], isTrue);
      expect(loggerTester.printedLevels[LogLevel.info], isTrue);
      expect(loggerTester.printedLevels[LogLevel.debug], isTrue);
      expect(loggerTester.printedLevels[LogLevel.trace], isTrue);
      expect(loggerTester.printedLevels[LogLevel.none], isFalse);
    });
  });
}

class MyClass {}

class LoggerTester implements ILogger {
  final ILogger logger;
  final Map<LogLevel, bool> printedLevels = {};

  LoggerTester({required this.logger});

  @override
  void log(message, LogLevel logLevel, {Object? error, StackTrace? stackTrace}) {
    printedLevels[logLevel] = logger.isEnabled(logLevel);
    logger.log(message, logLevel, error: error, stackTrace: stackTrace);
  }

  @override
  bool isEnabled(LogLevel logLevel) => logger.isEnabled(logLevel);

  @override
  String get name => logger.name;
}

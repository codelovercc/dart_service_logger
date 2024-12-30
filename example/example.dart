import 'package:dart_logging_abstraction/dart_logging_abstraction.dart';
import 'package:dart_service_logger/dart_service_logger.dart';
import 'package:dart_service_provider/dart_service_provider.dart';

void main() {
  final services = ServiceCollection();
  services.addEnvironment(Environment(name: Environments.development));
  services.addLogging(config: (b) => b.useLogger());
  final provider = services.buildServiceProvider();
  final globalLogger = provider.getRequiredService<ILogger>();
  final loggerFactory = provider.getRequiredLoggerFactory();
  final logger = loggerFactory.createLogger<MyClass>();

  globalLogger.fatal("Fatal on globalLogger", error: Error(), stackTrace: StackTrace.current);
  globalLogger.error("Error on globalLogger", error: Error(), stackTrace: StackTrace.current);
  globalLogger.warn("Warning on globalLogger");
  globalLogger.info("Info on globalLogger");
  globalLogger.debug("Debug on globalLogger");
  globalLogger.trace("Trace on globalLogger");
  globalLogger.log("Should not be printed.", LogLevel.none);

  logger.fatal("Fatal on logger", error: Error(), stackTrace: StackTrace.current);
  logger.error("Error on logger", error: Error(), stackTrace: StackTrace.current);
  logger.warn("Warning on logger");
  logger.info("Info on logger");
  logger.debug("Debug on logger");
  logger.trace("Trace on logger");
  logger.log("Should not be printed.", LogLevel.none);
}

class MyClass {}

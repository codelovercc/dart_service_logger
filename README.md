<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages). 
-->

# dart_service_logger

[![pub package](https://img.shields.io/pub/v/dart_service_logger?logo=dart&logoColor=00b9fc)](https://pub.dev/packages/dart_service_logger)
[![CI](https://img.shields.io/github/actions/workflow/status/codelovercc/dart_service_logger/dart.yml?branch=main&logo=github-actions&logoColor=white)](https://github.com/codelovercc/dart_service_logger/actions)
[![Last Commits](https://img.shields.io/github/last-commit/codelovercc/dart_service_logger?logo=git&logoColor=white)](https://github.com/codelovercc/dart_service_logger/commits/main)
[![Pull Requests](https://img.shields.io/github/issues-pr/codelovercc/dart_service_logger?logo=github&logoColor=white)](https://github.com/codelovercc/dart_service_logger/pulls)
[![Code size](https://img.shields.io/github/languages/code-size/codelovercc/dart_service_logger?logo=github&logoColor=white)](https://github.com/codelovercc/dart_service_logger)
[![License](https://img.shields.io/github/license/codelovercc/dart_service_logger?logo=open-source-initiative&logoColor=green)](https://github.com/codelovercc/dart_service_logger/blob/main/LICENSE)

Provide implementation
of [dart_logging_abstraction](https://pub.dev/packages/dart_logging_abstraction) package
using [logger](https://pub.dev/packages/logger) and
support [dart_service_provider](https://pub.dev/packages/dart_service_provider) extensions.

## Getting started

```dart
void main() {
  final services = ServiceCollection();
  services.addEnvironment(Environment(name: Environments.development));
  services.addLogging(config: (b) => b.useLogger());
  final provider = services.buildServiceProvider();
  final globalLogger = provider.getRequiredService<ILogger>();
  globalLogger.info("Info log via logger");
  final loggerFactory = provider.getRequiredLoggerFactory();
  final logger = loggerFactory.createLogger<MyClass>();
  logger.debug("Debug log via logger");
}
```

## Usage

```dart

void main() {
  final services = ServiceCollection();
  services.addEnvironment(Environment(name: Environments.development));
  // call b.userLogger() to use logger package for logging services.
  services.addLogging(config: (b) => b.useLogger());
}

```

## Additional information

If you have any issues or suggests please redirect
to [repo](https://github.com/codelovercc/dart_service_logger)
or [send an email](mailto:codelovercc@gmail.com) to me.

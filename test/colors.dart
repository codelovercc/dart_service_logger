import 'package:dart_service_logger/dart_service_logger.dart';

// This file is for debug Ansi colors only

void main() {
  printAnsiColors();
}

void printAnsiColors() {
  String message = 'This is a message';

  print(AnsiColors.blackFg("$message in blackFg."));
  print(AnsiColors.whiteFg("$message in whiteFg."));
  print(AnsiColors.grayFg("$message in grayFg."));
  print(AnsiColors.darkGreyFg("$message in darkGreyFg."));
  print(AnsiColors.blueFg("$message in blueFg."));
  print(AnsiColors.yellowFg("$message in yellowFg."));
  print(AnsiColors.darkYellowFg("$message in darkYellowFg."));
  print(AnsiColors.redFg("$message in redFg."));
  print(AnsiColors.magentaFg("$message in magentaFg."));
  print('');
  var trace = AnsiColors.darkGreyFg.withBg("This is trace color", AnsiColors.blackFg);
  var debug = AnsiColors.grayFg.withBg("This is debug color", AnsiColors.blackFg);
  var info = AnsiColors.blueFg.withBg("This is info color", AnsiColors.lightGrayFg);
  var warning = AnsiColors.yellowFg.withBg("This is warning color", AnsiColors.blackFg);
  var error = AnsiColors.blackFg.withBg("This is error color", AnsiColors.redFg);
  var fatal = AnsiColors.whiteFg.withBg("This is trace color", AnsiColors.magentaFg);
  print(trace);
  print(debug);
  print(info);
  print(warning);
  print(error);
  print(fatal);
}

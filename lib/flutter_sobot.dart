import 'dart:async';

import 'package:flutter/services.dart';

class FlutterSobot {
  static const MethodChannel _channel = const MethodChannel('flutter_sobot');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future start() async {
    await _channel.invokeMethod('start');
  }
}

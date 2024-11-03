import 'package:flutter/material.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_test/flutter_test.dart' as ft;

void main() {
  ft.group('test', () {
    FlutterDriver? driver;

    ft.setUpAll(() async {
      driver = await FlutterDriver.connect(
          dartVmServiceUrl: 'ws://127.0.0.1:50265/fAmLhSqOfV8=/ws');
    });

    ft.tearDownAll(() async {
      if (driver != null) {
        driver!.close();
      }
    });

    ft.test('hello', () async {
      await driver!.tap(find.byType('TextButton'));
      await driver!.waitFor(find.text('Close'));
      await driver!.tap(find.text('Close'));
      
    });
  });
}

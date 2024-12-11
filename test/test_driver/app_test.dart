import 'package:flutter/material.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_test/flutter_test.dart' as ft;

void main() {
  ft.group('test', () {
    FlutterDriver? driver;

    ft.setUpAll(() async {
      driver = await FlutterDriver.connect(
          dartVmServiceUrl: '');
    });

    ft.tearDownAll(() async {
      if (driver != null) {
        driver!.close();
      }
    });

    ft.test('hello', () async {
     
      
    });
  });
}

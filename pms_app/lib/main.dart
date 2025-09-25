import 'package:flutter/material.dart';
import 'src/app.dart';
import 'config/app_config.dart';

void main() {
    // Simple startup diagnostics in console to confirm backend URL used by the build
    // ignore: avoid_print
    print('[PMS] Frontend starting. Using baseUrl: ' + AppConfig.baseUrl);
    runApp(const PmsApp());
}



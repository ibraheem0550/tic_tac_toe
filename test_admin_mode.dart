import 'package:flutter/material.dart';
import 'lib/main.dart';

void main() {
  // Test admin mode startup
  AppConfig.setMode(AppMode.admin);
  runApp(const UnifiedAdminApp());
}

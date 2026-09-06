import 'package:flutter/material.dart';

import 'navigation/home_shell.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MertorhanApp());
}

class MertorhanApp extends StatelessWidget {
  const MertorhanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mert Orhan',
      theme: AppTheme.light,
      home: const HomeShell(),
    );
  }
}

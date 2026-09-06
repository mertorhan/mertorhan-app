import 'package:flutter/material.dart';

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
      home: const PlaceholderScreen(),
    );
  }
}

/// Gecici yer tutucu. KB-99'da navigasyon iskeletiyle degistirilecek.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Mert Orhan')),
    );
  }
}

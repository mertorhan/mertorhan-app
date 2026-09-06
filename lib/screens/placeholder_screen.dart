import 'package:flutter/material.dart';

/// Sekmelerin ortak yer tutucusu.
///
/// GECICI: navigasyon iskeleti calissin diye var. Her sekmenin gercek ekrani
/// geldikce bu widget o sekme icin kullanimdan kalkar.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({required this.title, super.key});

  /// Hem AppBar basligi hem govdedeki metin. Sekme adiyla ayni.
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}

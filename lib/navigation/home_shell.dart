import 'package:flutter/material.dart';

import '../screens/placeholder_screen.dart';

/// Sekme tanimlari. Etiket ve ikon tek yerde durur; hem NavigationBar hem
/// govde ayni listeden okur.
const List<({String label, IconData icon})> _tabs = [
  (label: 'Yayınlar', icon: Icons.article),
  (label: 'Gezi', icon: Icons.explore),
  (label: 'Rotalarım', icon: Icons.map),
  (label: 'Profil', icon: Icons.person),
];

/// Dort sekmeli alt navigasyon kabugu.
///
/// Sekme durumu KORUNMAZ: IndexedStack yok, sekme degisince onceki ekran
/// atilir ve yenisi bastan kurulur. Bilincli sadelik karari.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  /// Acilis sekmesi her zaman Yayinlar. Kullanicinin durumuna gore akilli
  /// acilis mantigi bu kartta yok; uyelik geldiginde ele alinacak.
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dort sekme de ayni widget tipi oldugu icin, key olmadan Flutter ayni
      // Element'i yeniden kullanir ve ekran gercekten bastan kurulmaz.
      // ValueKey bunu garanti eder.
      body: PlaceholderScreen(
        key: ValueKey(_selectedIndex),
        title: _tabs[_selectedIndex].label,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() => _selectedIndex = index);
        },
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(icon: Icon(tab.icon), label: tab.label),
        ],
      ),
    );
  }
}

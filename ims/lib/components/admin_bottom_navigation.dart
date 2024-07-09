import 'package:flutter/material.dart';

class AdminBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const AdminBottomNavigation({super.key, 
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.check_circle_outline),
          label: 'Attendance',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.document_scanner),
          label: 'Documents',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: 'Resources',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.task),
          label: 'Tasks',
        ),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: Colors.amber[800],
      onTap: onItemTapped,
    );
  }
}

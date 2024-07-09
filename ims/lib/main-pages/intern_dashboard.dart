import 'package:flutter/material.dart';
import 'package:ims/main-pages/home-page.dart';
import 'package:ims/components/top_app_bar.dart';
import 'package:ims/main-pages/profil_page.dart';
import 'package:ims/main-pages/avil_internship.dart';
import 'package:ims/Dash-board-pages/attendance.dart';
import 'package:ims/Dash-board-pages/document.dart';
import 'package:ims/Dash-board-pages/resource.dart';
import 'package:ims/Dash-board-pages/task.dart';

class InternDashboard extends StatefulWidget {
  const InternDashboard({super.key});

  @override
  _InternDashboardState createState() => _InternDashboardState();
}

class _InternDashboardState extends State<InternDashboard> {
  int _selectedIndex = 2; // Set the initial index to 2 for the "Internship" page

  static const List<Widget> _pages = <Widget>[
    HomePage(),
    Center(child: Text('Jobs')), // Replace with actual Jobs page
    AvilInternshipPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => _pages[index]),
    );
  }

  void _navigateToPage(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBar(
        title: 'Intern Dashboard',
        isLoggedIn: true, // Assuming the user is logged in
        onLogout: () {
          // Handle logout logic
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0), // Reduced padding to use more space
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          children: [
            DashboardOption(
              icon: Icons.check_circle,
              label: 'Attendance',
              color: Colors.blue,
              onTap: () => _navigateToPage(const AttendancePage()),
            ),
            DashboardOption(
              icon: Icons.task,
              label: 'Task',
              color: Colors.green,
              onTap: () => _navigateToPage(const TaskPage()),
            ),
            DashboardOption(
              icon: Icons.document_scanner,
              label: 'Document',
              color: Colors.orange,
              onTap: () => _navigateToPage(const DocumentPage()),
            ),
            DashboardOption(
              icon: Icons.book,
              label: 'Resources',
              color: Colors.purple,
              onTap: () => _navigateToPage(const ResourcePage()),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business_center),
            label: 'Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Internships',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

class DashboardOption extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const DashboardOption({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  _DashboardOptionState createState() => _DashboardOptionState();
}

class _DashboardOptionState extends State<DashboardOption> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => _updateHoverState(true),
      onExit: (event) => _updateHoverState(false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Card(
          elevation: _isHovered ? 8 : 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: widget.color.withOpacity(_isHovered ? 0.2 : 0.1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.icon,
                  size: 60, // Increased icon size
                  color: widget.color,
                ),
                const SizedBox(height: 20), // Increased space between icon and text
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 20, // Increased text size
                    fontWeight: FontWeight.bold,
                    color: widget.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updateHoverState(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
  }
}

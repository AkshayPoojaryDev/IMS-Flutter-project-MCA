import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ims/main-pages/profil_page.dart';
import 'package:ims/main-pages/avil_internship.dart';
import 'package:ims/main-pages/avail_jobs.dart';
import 'package:ims/components/top_app_bar.dart';
import 'package:ims/pages/auth_page.dart';
import 'package:ims/main-pages/intern_dashboard.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

    @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AuthPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      buildHomePageContent(context),
      const AvailJobsPage(),
      const AvilInternshipPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      appBar: TopAppBar(
        title: 'IMS',
        isLoggedIn: true,
        onLogout: _logout,
      ),
      drawer: buildDrawer(context),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: pages[_selectedIndex],
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
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget buildHomePageContent(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade200, Colors.purple.shade200],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.0, _animationController.value],
                  ),
                ),
              );
            },
          ),
        SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Welcome to',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ).animate().fade(duration: 500.ms).slideX(begin: -0.5),
              Text(
                'Nicozn Technologies IMS',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ).animate().fade(duration: 500.ms).slideX(begin: -0.5, delay: 200.ms),
              const SizedBox(height: 10),
              Text(
                'Your all-in-one portal for internships, jobs, and managing your journey with us.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ).animate().fade(duration: 500.ms, delay: 400.ms),
              const SizedBox(height: 40),
              Lottie.network(
                'https://assets1.lottiefiles.com/packages/lf20_puciaact.json',
                height: 250,
              ).animate().scale(delay: 600.ms),
              const SizedBox(height: 40),
              Text(
                'Explore Opportunities',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ).animate().fade(duration: 500.ms, delay: 800.ms),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildFeatureCard(
                    context,
                    title: 'Internships',
                    icon: Icons.school,
                    color: Colors.orange,
                    onTap: () => _onItemTapped(2),
                  ).animate().slideUp(delay: 1000.ms),
                  _buildFeatureCard(
                    context,
                    title: 'Jobs',
                    icon: Icons.work,
                    color: Colors.green,
                    onTap: () => _onItemTapped(1),
                  ).animate().slideUp(delay: 1100.ms),
                  _buildFeatureCard(
                    context,
                    title: 'Dashboard',
                    icon: Icons.dashboard,
                    color: Colors.red,
                    onTap: () {
                       Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const InternDashboard()),
                      );
                    },
                  ).animate().slideUp(delay: 1200.ms),
                  _buildFeatureCard(
                    context,
                    title: 'My Profile',
                    icon: Icons.person,
                    color: Colors.purple,
                    onTap: () => _onItemTapped(3),
                  ).animate().slideUp(delay: 1300.ms),
                ],
              )
            ],
          ),
        ),
      ),]
    );
  }

  Widget _buildFeatureCard(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Drawer buildDrawer(BuildContext context) {
    return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Text(
                'IMS Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.business_center),
              title: const Text('Jobs'),
              onTap: () {
                _onItemTapped(1);
                 Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.work),
              title: const Text('Internships'),
              onTap: () {
                _onItemTapped(2);
                 Navigator.pop(context);
              },
            ),
             ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InternDashboard()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                _onItemTapped(3);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: _logout,
            ),
          ],
        ),
      );
  }
}

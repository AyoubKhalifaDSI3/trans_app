import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trans_app/screens/dashboard_screen.dart';
import 'package:trans_app/screens/courses_screen.dart';
import 'package:trans_app/screens/map_screen.dart';
import 'package:trans_app/screens/revenues_screen.dart';
import 'package:trans_app/screens/notificationspage.dart';
import 'package:trans_app/screens/support_screen.dart';
import 'package:trans_app/screens/profile_settings_screen.dart';
import 'package:trans_app/screens/signin_screen.dart';
import 'package:trans_app/screens/trajet_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(84, 131, 250, 1),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            _buildMenuItem(
              icon: Icons.dashboard,
              title: "Tableau de Bord",
              onTap: () => _navigateTo(context, const DashboardScreen()),
            ),
            _buildMenuItem(
              icon: Icons.directions_car,
              title: "Trajet",
              onTap: () => _navigateTo(context, TrajetScreen()),
            ),
            _buildMenuItem(
              icon: Icons.list_alt,
              title: "Liste des courses",
              onTap: () => _navigateTo(context, const CoursesScreen()),
            ),
            _buildMenuItem(
              icon: Icons.map,
              title: "Carte & Navigation",
              onTap: () => _navigateTo(context, const MapScreen()),
            ),
            _buildMenuItem(
              icon: Icons.attach_money,
              title: "Mes Revenus",
              onTap: () => _navigateTo(context, const RevenuesScreen()),
            ),
            _buildMenuItem(
              icon: Icons.notifications,
              title: "Notifications",
              onTap: () => _navigateTo(context, const NotificationsPage()),
            ),
            _buildMenuItem(
              icon: Icons.settings,
              title: "Profil & Paramètres",
              onTap: () => _navigateTo(context, const ProfileSettingsScreen()),
            ),
            _buildMenuItem(
              icon: Icons.support_agent,
              title: "Assistance & Support",
              onTap: () => _navigateTo(context, const SupportScreen()),
            ),
            
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              color: const Color.fromARGB(255, 243, 122, 122),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title: const Text(
                  "Déconnexion",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                onTap: () => _signOut(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: ListTile(
        leading: Icon(icon, color: Color.fromRGBO(84, 131, 250, 1)),
        title: Text(title),
        onTap: onTap,
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }
}

import 'package:admin_pfe/views/admin/eventlistweb.dart';
import 'package:admin_pfe/views/admin/userlist.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'login.dart'; // Vérifie le chemin d'importation
import 'tourist_sites_list_page.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Instance de FirebaseAuth

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  void _checkAuthentication() {
    // Rediriger vers LoginPage si l'utilisateur n'est pas connecté
    if (_auth.currentUser == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  void _logout(BuildContext context) async {
    await _auth.signOut(); // Déconnecte l'utilisateur
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Color.fromARGB(255, 123, 73, 15),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // Affichage d'informations utilisateur dans le DrawerHeader
            UserAccountsDrawerHeader(
              decoration:
                  BoxDecoration(color: Color.fromARGB(255, 123, 73, 15)),
              accountName: Text(_auth.currentUser?.displayName ?? 'Admin'),
              accountEmail: Text(_auth.currentUser?.email ?? ''),
              currentAccountPicture: CircleAvatar(
                foregroundImage: AssetImage('images/user.png'),
              ),
            ),

            ListTile(
              leading: Icon(
                  Icons.place), // Icône pour la gestion des sites touristiques
              title: Text('Tourist Sites Management'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TouristSiteListPage()),
                );
              },
            ),
            ListTile(
              leading:
                  Icon(Icons.event), // Icône pour la gestion des événements
              title: Text('Events Management'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EventListWeb()),
                );
              },
            ),
            ListTile(
              leading:
                  Icon(Icons.group), // Icône pour la gestion des utilisateurs
              title: Text('Users Management'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserListAdmin()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout), // Icône pour la déconnexion
              title: Text('Logout'),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(
              'Welcome to your dashboard, ${_auth.currentUser?.displayName ?? 'Admin'}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Zone de statistiques
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 20, // Espace entre les cartes
              runSpacing: 20, // Espace entre les lignes
              children: [
                StatCard(
                  title: "Tourist Sites",
                  icon: Icons.place,
                  stream: countDocuments(
                      'touristSites'), // Assurez-vous que le nom de la collection est correct
                ),
                StatCard(
                  title: "Upcoming Events",
                  icon: Icons.event,
                  stream: countDocuments('events'),
                ),
                StatCard(
                  title: "Users",
                  icon: Icons.group,
                  stream: countDocuments('Users'),
                ),

                // Graphiques et Analytiques
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Stream<int> countDocuments(String collectionPath) {
  return FirebaseFirestore.instance
      .collection(collectionPath)
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
}

class StatCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Stream<int> stream; // Flux pour les données dynamiques

  const StatCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.stream,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: 160,
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 40),
            SizedBox(height: 10),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            StreamBuilder<int>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    '${snapshot.data}',
                    style: TextStyle(fontSize: 24),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error');
                }
                return CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }
}

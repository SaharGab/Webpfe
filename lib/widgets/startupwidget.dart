import 'package:admin_pfe/views/admin/dashboard.dart';
import 'package:admin_pfe/views/admin/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StartupWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          // L'utilisateur est connecté, le rediriger vers le tableau de bord
          return AdminDashboard();
        } else {
          // L'utilisateur n'est pas connecté, le rediriger vers la page de connexion
          return LoginPage();
        }
      },
    );
  }
}

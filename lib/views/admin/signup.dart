import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController =
      TextEditingController(); // Contrôleur pour le nom complet

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  bool _validateEmail(String email) {
    // Simple email validation
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  bool _validatePassword(String password) {
    // Password must be at least 6 characters
    return password.length >= 6;
  }

  void _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final fullName = _fullNameController.text.trim();

    if (!_validateEmail(email)) {
      _showSnackBar('Please enter a valid email.');
      return;
    }

    if (!_validatePassword(password)) {
      _showSnackBar('Password must be at least 6 characters long.');
      return;
    }

    if (fullName.isEmpty) {
      _showSnackBar('Please enter your full name.');
      return;
    }

    try {
      // Création de l'utilisateur avec Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Enregistrement des informations de l'utilisateur, y compris le nom complet, dans Firestore
      await _firestore.collection('admins').doc(userCredential.user!.uid).set({
        'email': email,
        'fullName': fullName, // Enregistrement du nom complet
        // Ajoute d'autres champs si nécessaire
      });

      // Redirection ou affichage d'un message de succès
      // Par exemple, utiliser Navigator pour rediriger l'utilisateur vers la page de connexion
      Navigator.pop(context);
    } catch (e) {
      // Gestion des erreurs, par exemple afficher une alerte
      _showSnackBar(
          'Failed to sign up: ${e.toString()}'); // Affichage de l'erreur dans un SnackBar
      print(e); // Assurez-vous de gérer l'erreur correctement
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        position: DecorationPosition.background,
        decoration: BoxDecoration(),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 50),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 45, horizontal: 20),
                  width: 350,
                  height: 400, // Adjusted for more content
                  decoration: BoxDecoration(
                    color: Color.fromARGB(154, 185, 176, 176).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                    // Allows for scrolling
                    child: Column(
                      children: [
                        TextField(
                          controller: _fullNameController,
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            hintText: 'Full Name',
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _emailController,
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            hintText: 'Email',
                            prefixIcon: Icon(Icons.email),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _passwordController,
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            prefixIcon: Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.visibility_off),
                              onPressed: () {},
                            ),
                          ),
                          obscureText: true,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _signUp,
                          child: Text('Sign Up'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(
                                255, 123, 73, 15), // Background color
                            foregroundColor:
                                Color.fromARGB(255, 45, 43, 43), // Text color
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

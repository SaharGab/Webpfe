import 'package:admin_pfe/views/admin/signup.dart';
import 'package:admin_pfe/views/admin/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _stayLoggedIn = false;
  String _errorMessage = '';

  void _login() async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminDashboard()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        setState(() {
          _errorMessage = 'Incorrect email or password';
        });
      } else {
        setState(() {
          _errorMessage = 'An unexpected error occurred';
        });
      }
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
                if (_errorMessage.isNotEmpty)
                  Text(_errorMessage, style: TextStyle(color: Colors.red)),
                Container(
                  padding: EdgeInsets.only(
                      top: 45,
                      left: 20,
                      right: 20), // Espace intérieur de la boîte
                  width: 350,
                  height: 350, // Définissez la largeur de la boîte ici
                  decoration: BoxDecoration(
                    color: Color.fromARGB(154, 185, 176, 176)
                        .withOpacity(0.8), // Arrière-plan semi-transparent
                    borderRadius: BorderRadius.circular(12), // Coins arrondis
                  ),

                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      TextField(
                        controller: _emailController,
                        cursorColor: Colors.black,
                        // Couleur du curseur
                        decoration: InputDecoration(
                          hintText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _passwordController,
                        cursorColor: Colors.black,

                        // Couleur du curseur
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
                      SizedBox(height: 15),
                      Theme(
                        data: Theme.of(context).copyWith(
                          checkboxTheme: CheckboxThemeData(
                            fillColor: MaterialStateProperty.all(
                                const Color.fromARGB(255, 203, 190,
                                    190)), // Couleur du carré du Checkbox
                          ),
                        ),
                        child: CheckboxListTile(
                          value: _stayLoggedIn,
                          onChanged: (bool? value) {
                            setState(() {
                              _stayLoggedIn = value!;
                            });
                          },
                          title: Text('Stay logged in'),
                          controlAffinity: ListTileControlAffinity.leading,
                          dense: true, // Rend la CheckboxListTile moins haute
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _login,
                        child: Text('Login'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(
                              255, 123, 73, 15), // Couleur de fond
                          foregroundColor: const Color.fromARGB(
                              255, 45, 43, 43), // Couleur du texte
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpPage()),
                          );
                        },
                        child: Text('Sign up'),
                        style: TextButton.styleFrom(
                          foregroundColor: Color.fromARGB(255, 123, 73, 15),
                          textStyle: TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
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

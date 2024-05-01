import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pothole_app/components/my_textfield.dart';

import '../components/my_button.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({
    super.key,
    required this.onTap,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmPwController = TextEditingController();
  void displayMessageToUser(String message, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
      ),
    );
  }

  void register() async {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    if (passwordController.text != confirmPwController.text) {
      Navigator.pop(context);
      displayMessageToUser("Password incorrect", context);
    } else {
      try {
        UserCredential? userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        createUserDocument(userCredential);
        if (context.mounted) Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        displayMessageToUser(e.code, context);
      }
    }
  }

  Future<void> createUserDocument(UserCredential? userCredential) async {
    if (userCredential != null && userCredential.user != null) {
      User? currentUser = FirebaseAuth.instance.currentUser;
      String userId = currentUser?.uid ?? 'defaultUserId';
      await FirebaseFirestore.instance.collection("users").doc(userId).set({
        'email': userCredential.user!.email,
        'username': usernameController.text,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white24,
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // app name
              const Text(
                "Register Page",
                style: TextStyle(fontSize: 20),
              ),

              const SizedBox(height: 10),

              MyTextField(
                hintText: "username",
                obscureText: false,
                controller: usernameController,
              ),

              const SizedBox(height: 10),

              MyTextField(
                hintText: "email",
                obscureText: false,
                controller: emailController,
              ),

              const SizedBox(height: 10),

              MyTextField(
                hintText: "password",
                obscureText: true,
                controller: passwordController,
              ),

              const SizedBox(height: 10),

              MyTextField(
                hintText: "confirm password",
                obscureText: true,
                controller: confirmPwController,
              ),

              const SizedBox(height: 10),

              MyButton(
                text: "Register",
                onTap: register,
              ),

              const SizedBox(height: 10),
              //
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      "Login here",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

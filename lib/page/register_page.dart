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
  // text controller
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

  // register method
  void register() async {
    // show loading circle
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    // make sure passwords match
    if (passwordController.text != confirmPwController.text) {
      // loading circle
      Navigator.pop(context);

      // show error message
      displayMessageToUser("Password don't match", context);
    }
    //if passwords match
    else {
      // creating user
      try {
        // create user
        UserCredential? userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        // create a user document and add to firestore
        createUserDocument(userCredential);

        // pop loading cicle
        if (context.mounted) Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        // pop loading cicle
        Navigator.pop(context);

        // display error message to user
        displayMessageToUser(e.code, context);
      }
    }
  }

  // create a user document and collect them in firestore
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
      backgroundColor: Colors.blueAccent,
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

              // username textfield
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

              // register buton
              MyButton(
                text: "Register",
                onTap: register,
              ),

              const SizedBox(height: 10),
              //
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account? "),
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

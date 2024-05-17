import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:latest/firebase_options.dart';
import 'package:latest/home.dart';
import 'package:latest/notification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Notifierhelper.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SenSor App',
      debugShowCheckedModeBanner: false,
      home: AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Loading indicator
        } else if (snapshot.hasData) {
          return const home(); // User is logged in
        } else {
          return const login(); // User is not logged in
        }
      },
    );
  }
}

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> _signInWithEmailAndPassword() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );

      AnimatedSnackBar.material(
        'Login Successful',
        type: AnimatedSnackBarType.success,
        duration: const Duration(seconds: 1),
        mobilePositionSettings: const MobilePositionSettings(
          topOnAppearance: 100,
        ),
        mobileSnackBarPosition: MobileSnackBarPosition.top,
      ).show(context);
      print("done");

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const home()),
      );
    } catch (e) {
      AnimatedSnackBar.material(
        "Can't Login",
        type: AnimatedSnackBarType.error,
        duration: const Duration(seconds: 1),
        mobilePositionSettings: const MobilePositionSettings(
          topOnAppearance: 100,
        ),
        mobileSnackBarPosition: MobileSnackBarPosition.top,
      ).show(context);
      print("error");
    }
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double width = mediaQueryData.size.width;
    double height = mediaQueryData.size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(20)),
              child: Image.asset("assets/images/outr.png")),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(20)),
                child: Image.asset("assets/images/spectrum.png")),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 25,
              ),
              const Text(
                "LOGIN/SIGN IN",
                style: TextStyle(
                    fontFamily: "Oswaldb",
                    fontSize: 35,
                    fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 25,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      labelText: "ENTER YOUR EMAIL OR USERNAME",
                      prefixIcon: const Icon(Icons.supervisor_account)),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextField(
                  controller: password,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      labelText: "ENTER YOUR PASSWORD",
                      prefixIcon: const Icon(Icons.key)),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              GestureDetector(
                onTap: () {
                  if (email.text.isEmpty || password.text.isEmpty) {
                    AnimatedSnackBar.material(
                      'The above fields are required',
                      type: AnimatedSnackBarType.info,
                      duration: const Duration(seconds: 1),
                      mobilePositionSettings: const MobilePositionSettings(
                        topOnAppearance: 100,
                      ),
                      mobileSnackBarPosition: MobileSnackBarPosition.top,
                    ).show(context);
                    print("Empty");
                  } else {
                    _signInWithEmailAndPassword();
                  }
                },
                child: Container(
                  height: height / 15,
                  width: width / 1.5,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.black),
                  child: const Center(
                    child: Text(
                      "Continue",
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Oswaldb",
                          fontSize: 25),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

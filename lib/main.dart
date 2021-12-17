import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:sergipe_shop/login_page/login_page.dart';
import 'firebase_options.dart';
import 'home_page/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseAuth auth = FirebaseAuth.instance;
  runApp(Phoenix(
      child: MaterialApp(
    debugShowCheckedModeBanner: false,
    home: auth.currentUser != null ? const HomePage() : const LoginPage(),
    theme: ThemeData(
      primarySwatch: Colors.green,
    ),
  )));
}

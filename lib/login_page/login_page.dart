import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:sergipe_shop/home_page/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    Key? key,
    this.homePage = false,
  }) : super(key: key);
  final bool homePage;
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FirebaseAuth auth = FirebaseAuth.instance;

  Future<bool> validLogin() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: controllerEmail.text,
        password: controllerSenha.text,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        debugPrint('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        debugPrint('Wrong password provided for that user.');
      }
      return false;
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  bool obscureText = true;

  TextEditingController controllerEmail =
      TextEditingController(text: 'admin@sergipe.com');
  TextEditingController controllerSenha = TextEditingController(text: '123456');
  bool emailEsenhaLogin = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            child: Icon(
              Icons.shopping_cart_sharp,
              size: 100,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              const Text(
                'Sergipe Shopping',
                style: TextStyle(fontSize: 35),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          if (emailEsenhaLogin)
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    controller: controllerEmail,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'example@example.com',
                        labelText: 'Email'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    controller: controllerSenha,
                    obscureText: obscureText,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                          onPressed: () {
                            obscureText = !obscureText;
                            setState(() {});
                          },
                          icon: Icon(
                            obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                          )),
                      border: const OutlineInputBorder(),
                      labelText: 'Senha',
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      padding: MaterialStateProperty.all(
                          const EdgeInsets.fromLTRB(30, 15, 30, 15))),
                  onPressed: () async {
                    // validLogin();
                    if (await validLogin()) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomePage(),
                          ));
                      ScaffoldMessenger.of(context).clearSnackBars();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.red,
                          content: Text('Email ou Senha Incorretos'),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Entrar',
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    emailEsenhaLogin = false;
                    setState(() {});
                  },
                  child: const Icon(
                    Icons.arrow_back,
                  ),
                  style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(), primary: Colors.green),
                )
              ],
            ),
          if (!emailEsenhaLogin)
            SignInButton(
              Buttons.Email,
              text: 'Entrar com Email e Senha',
              onPressed: () {
                emailEsenhaLogin = true;
                setState(() {});
              },
            ),
          if (!emailEsenhaLogin)
            SignInButton(
              Buttons.Google,
              text: 'Entrar com Google',
              onPressed: () async {
                if (await signInWithGoogle()
                    .then((value) => value.credential != null)) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomePage(),
                      ));
                }
              },
            )
        ],
      )),
    );
  }
}

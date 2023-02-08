import 'dart:convert';

import 'package:fika_and_fokus/screens/MyGoogleMap.dart';
import 'package:fika_and_fokus/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../GoogleSignIn.dart';
import 'SignUp.dart';
import '../models/UserModel.dart';
import 'dart:developer';



class LogIn extends StatefulWidget {
  const LogIn({Key? key}) : super(key: key);

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final _formKey = GlobalKey<FormState>(); //a globalkey for validation.

  UserModel user = UserModel.login("", "");
  String loginMessage = "";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Container(
        child: SafeArea(
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Color(0xFFE0DBCF),
            body: Builder(
                // this widget is needed for ScaffoldMessenger.of(context) to work.
                builder: (context) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(30, 50, 30, 0),
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    Image.asset('images/logo-white.png',
                        width: 600, height: 200),
                    Center(
                      child: Text(
                        "ACCOUNT LOGIN",
                        style: GoogleFonts.oswald(
                            textStyle:
                                const TextStyle(color: Color(0xFF75AB98)),
                            fontSize: 45.00,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: Card(
                        child: TextFormField(
                          cursorColor: Color(0xFF75AB98),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 0, vertical: 5),
                            border: InputBorder.none,
                            prefixIcon: Align(
                              widthFactor: 1.0,
                              heightFactor: 1.0,
                              child: FaIcon(
                                FontAwesomeIcons.solidUser,
                                color: Color(0xFF696969),
                              ),
                            ),
                            labelText: 'Email',
                            labelStyle: TextStyle(
                              color: Color(0xFF696969),
                              fontSize: 20,
                            ),
                          ),
                          style:
                              GoogleFonts.roboto(fontWeight: FontWeight.w300),
                          validator: (value) {
                            EmailFieldValidator.validate(value!);
                          },
                          controller:
                              TextEditingController(text: user.getEmail),
                          onChanged: (val) {
                            user.email = val;
                          },
                        ),
                        color: const Color.fromARGB(255, 255, 255, 255),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                      child: Card(
                        child: TextFormField(
                          cursorColor: Color(0xFF75AB98),
                          obscureText: true,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 0, vertical: 5),
                            border: InputBorder.none,
                            prefixIcon: Align(
                              widthFactor: 1.0,
                              heightFactor: 1.0,
                              child: FaIcon(
                                FontAwesomeIcons.lock,
                                color: Color(0xFF696969),
                              ),
                            ),
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              color: Color(0xFF696969),
                              fontSize: 20,
                            ),
                          ),
                          style:
                              GoogleFonts.roboto(fontWeight: FontWeight.w300),
                          validator: (value) {
                            PasswordFieldValidator.validate(value!);
                          },
                          controller:
                              TextEditingController(text: user.getPassword),
                          onChanged: (val) {
                            user.password = val;
                          },
                        ),
                        color: const Color.fromARGB(255, 255, 255, 255),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Container(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {

                            login(user.getEmail, user.getPassword)
                                .then((value) {
                              if (value.trim() != "") {
                                final snackBar = SnackBar(content: Text(value));

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              }
                            });
                          },
                          child: Text(
                            'LOG IN',
                            style: GoogleFonts.oswald(
                                fontSize: 28, fontWeight: FontWeight.normal),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Color(0xFF696969),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: ElevatedButton.icon(
                        icon: Image.asset(
                          "images/google_logo.png",
                          width: 32,
                        ),
                        label: Text(
                          'Log in with Google',
                          style: GoogleFonts.roboto(
                              fontSize: 20.00, fontWeight: FontWeight.w300),
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          primary: Colors.white,
                          onPrimary: Colors.black,
                          minimumSize: Size(double.infinity, 50),
                        ),
                        onPressed: () async {
                          final provider = Provider.of<GoogleSignInProvider>(
                              context,
                              listen: false);
                          await provider
                              .signOutWithGoogle(); // apparently needed for login options dialog to show up
                          final isloggedInWithGoogle =
                              await provider.loginWithGoogle();
                          bool isLoggedInWithGoogle = false;
                          await provider.loginWithGoogle().then((value) {
                            isLoggedInWithGoogle = value;
                          });
                          log("isLoggedInWithGoogle: " +
                              isLoggedInWithGoogle.toString());
                          if (isLoggedInWithGoogle) {
                            registerUser(
                              provider.user.email,
                              provider.user.displayName!,
                              "google",
                            );

                            // user details to be sent to navbar
                            user.email = provider.user.email.toString();
                            user.userName =
                                provider.user.displayName.toString();
                            user.password = "google";

                            // trying to get google profile photo, to replace default photo.
                            NetworkImage temp =
                                await NetworkImage(provider.user.photoUrl!);
                            if (temp != null ||
                                provider.user.photoUrl?.trim() == "") {
                              user.profilePicture = temp;
                            }

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => NavBar(user: user)));
                          }
                        },
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        "Forgotten password/username?",
                        style: GoogleFonts.roboto(
                            textStyle: const TextStyle(
                                color: Color(0xFF871801), letterSpacing: .5),
                            fontSize: 15.00,
                            fontWeight: FontWeight.w300),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                      child: Container(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUp(),
                              ),
                            );
                          },
                          child: Text(
                            'SIGN UP',
                            style: GoogleFonts.oswald(
                                fontSize: 28.00, fontWeight: FontWeight.normal),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Color(0xFF75AB98),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }



  UserModel getLoggedInUser() {
    return user;
  }

  Future<String> login(String email, String password) async {
    if (email.isEmpty) return "Email is empty";
    if (password.isEmpty) return "Password is empty";

    Uri url = Uri.parse(
        "https://group-1-75.pvt.dsv.su.se/fikafocus-0.0.1-SNAPSHOT/user/login?"
                "email=" +
            email +
            "&password=" +
            password);

    var response = await http.get(url);
    print(response.toString());

    if (response.statusCode == 200) {
      print("log in successfull");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NavBar(user: user),
        ),
      );
    } else {
      return "login failed: wrong username or password";
    }
    return "";
  }

  Future<UserModel> registerUser(
      String email, String username, String password) async {
    print("test");
    //Uri url = Uri.parse("http://192.168.0.14:8080/user/add?"
    Uri url = Uri.parse(
        "https://group-1-75.pvt.dsv.su.se/fikafocus-0.0.1-SNAPSHOT/user/add?" +
            "email=" +
            email +
            "&username=" +
            username +
            "&password=" +
            password);
    print(url.toString());
    final response = await http.post(url);

    if (response.statusCode == 200) {
      print("success, status code 200 when adding user");
      return UserModel(email: email, userName: username, password: password);
    } else {
      throw "Error: " + response.statusCode.toString();
    }
  }
}

class EmailFieldValidator {
  static String validate(String value) {
    return value.isEmpty ? 'Email can\'t be empty' : '';
  }
}

class PasswordFieldValidator {
  static String validate(String value) {
    return value.isEmpty ? 'Password can\'t be empty' : '';
  }
}
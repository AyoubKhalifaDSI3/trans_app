import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trans_app/screens/signup_screen.dart';


class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  String email = "";
  TextEditingController mailcontroller = TextEditingController();
   final _formSignInKey = GlobalKey<FormState>();
   resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        "Password Reset Email has been sent !",
        style: TextStyle(fontSize: 20.0),
      )));
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          "No user found for that email.",
          style: TextStyle(fontSize: 20.0),
        )));
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 51, 78, 231),
      body: Column(
        children: [
          SizedBox(
            height: 70.0,
          ),
          Container(
            alignment: Alignment.topCenter,
            child: Text(
              "Password Recovery",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          Text(
            "Enter your mail",
            style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold),
          ),
          Expanded(
              child: Form(
                  key: _formSignInKey,
                  child: Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: ListView(
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 10.0),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.white70, width: 2.0),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter Email';
                              }
                              return null;
                            },
                            controller: mailcontroller,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                                hintText: "Email",
                                hintStyle: TextStyle(
                                    fontSize: 18.0, color: Colors.white),
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: Colors.white70,
                                  size: 30.0,
                                ),
                                border: InputBorder.none),
                          ),
                        ),
                        SizedBox(
                          height: 40.0,
                        ),
                        GestureDetector(
                          onTap: () {
                            if(_formSignInKey.currentState!.validate()){
                              setState(() {
                                email=mailcontroller.text;
                              });
                              resetPassword();
                            }
                          },
                          child: Container(
                            width: 140,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(
                              child: Text(
                                "Send Email",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 50.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.white),
                            ),
                            SizedBox(
                              width: 5.0,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SignUpScreen()));
                              },
                              child: Text(
                                "Create",
                                style: TextStyle(
                                    color: Color.fromARGB(225, 184, 166, 6),
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w500),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ))),
        ],
      ),
    );
  }
}



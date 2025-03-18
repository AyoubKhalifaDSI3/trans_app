import 'package:flutter/material.dart';
import 'package:trans_app/screens/signin_screen.dart';
import 'package:trans_app/screens/signup_screen.dart';

import 'package:trans_app/widgets/custom_scaffold.dart';
import 'package:trans_app/widgets/welcome_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          Flexible(
              flex: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 40.0,
                ),
                child: Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      children: [
                        TextSpan(
                            text: 'Content de te revoir!\n',
                            style: TextStyle(
                              fontSize: 45.0,
                              fontWeight: FontWeight.w600,
                              color: Color.fromRGBO(84, 131, 250, 1),
                            )),
                        TextSpan(
                            text:
                                '\nSaisissez vos informations personnelles ',
                            style: TextStyle(
                              fontSize: 20,
                              color: Color.fromRGBO(84, 131, 250, 1),
                              // height: 0,
                            ))
                      ],
                    ),
                  ),
                ),
              )),
          Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Row(
                children: [
                  const Expanded(
                    child: WelcomeButton(
                      buttonText: 'Se connecter',
                      onTap: SignInScreen(),
                      color: Colors.transparent,
                      textColor: Color.fromRGBO(84, 131, 250, 1),
                    ),
                  ),
                  Expanded(
                    child: WelcomeButton(
                      buttonText: "S'inscrire",
                      onTap: const SignUpScreen(),
                      color: Colors.white,
                      textColor: Color.fromRGBO(84, 131, 250, 1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
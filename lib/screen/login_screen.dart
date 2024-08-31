import 'package:cab/screen/forget.dart';
import 'package:cab/screen/register_screen.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../global/global.dart';
import 'main_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  final emailTextEditor = TextEditingController();
  final passwordTextEditor = TextEditingController();
  bool passwordVisible = false;

  //GlobalKey

  final _formkey = GlobalKey<FormState>();

  void _Submit() async {
    if (_formkey.currentState!.validate()) {
      await firebaseAuth
          .signInWithEmailAndPassword(
        email: emailTextEditor.text.trim(),
        password: passwordTextEditor.text.trim(),
      )
          .then((auth) async {
        currentuser = auth.user;
        await Fluttertoast.showToast(msg: "Successfully Logged ");
        Navigator.push(
            context, MaterialPageRoute(builder: (x) => const main_page()));
      }).catchError((errorMessage) {
        Fluttertoast.showToast(msg: "Error occures \n $errorMessage");
      });
    } else {
      Fluttertoast.showToast(msg: "Not all Filed are valid !");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darktheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            Image.asset(darktheme ? 'images/citydark.jpg' : 'images/city.jpg'),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Login',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 40,
                color: darktheme ? Colors.yellowAccent : Colors.red,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 20, 15, 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Form(
                    key: _formkey,
                    child: Column(
                      children: [
                        TextFormField(
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(50)
                          ],
                          decoration: InputDecoration(
                              hintText: "Enter your email",
                              hintStyle: const TextStyle(
                                color: Colors.grey,
                              ),
                              filled: true,
                              fillColor:
                                  darktheme ? Colors.black : Colors.white,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                  borderSide: const BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  )),
                              prefixIcon: Icon(
                                Icons.email_rounded,
                                color: darktheme
                                    ? Colors.yellowAccent
                                    : Colors.red,
                              )),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (email) {
                            if (email == null || email.isEmpty) {
                              return "Email is required";
                            }
                            if (email.length < 2 || email.length > 25) {
                              return "Please Enter Valid Name";
                            }
                            if (EmailValidator.validate(email)) {
                              return null;
                            }
                            return null;
                          },
                          onChanged: (Text) => setState(() {
                            emailTextEditor.text = Text;
                          }),
                        ),
                        //Password Box
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          obscureText: !passwordVisible,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(50)
                          ],
                          decoration: InputDecoration(
                            hintText: "Enter Password",
                            hintStyle: const TextStyle(
                              color: Colors.grey,
                            ),
                            filled: true,
                            fillColor: darktheme ? Colors.black : Colors.white,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(80),
                                borderSide: const BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                )),
                            prefixIcon: Icon(
                              Icons.password,
                              color: darktheme ? Colors.yellow : Colors.red,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: darktheme ? Colors.green : Colors.red,
                              ),
                              onPressed: () {
                                //Update the state of password visible variable
                                setState(() {
                                  passwordVisible = !passwordVisible;
                                });
                              },
                            ),
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return "Enter Password";
                            }
                            if (text.length < 8 || text.length > 30) {
                              return "Please Enter Valid password";
                            }
                            return null;
                          },
                          onChanged: (text) => setState(() {
                            passwordTextEditor.text = text;
                          }),
                        ),
                        const SizedBox(
                          height: 50,
                        ),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                darktheme ? Colors.yellowAccent : Colors.red,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            minimumSize: const Size(200, 40),
                          ),
                          onPressed: () {
                            _Submit();
                          },
                          child: const Text(
                            'Sign in',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (c) => const forgetScreen()));
                          },
                          child: Text(
                            'Forget Password',
                            style: TextStyle(
                              color:
                                  darktheme ? Colors.yellowAccent : Colors.red,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                          width: 10,
                        ),
                        //Create Accounts
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (c) => const register_screen()));
                          },
                          child: const Center(
                            child: Text(
                              "Doesn't have an account?",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                          height: 10,
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

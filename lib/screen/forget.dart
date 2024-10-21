
import 'package:cab/global/global.dart';
import 'package:cab/screen/login_screen.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
class forgetScreen extends StatefulWidget {
  const forgetScreen({super.key});

  @override
  State<forgetScreen> createState() => _forgetScreenState();
}

class _forgetScreenState extends State<forgetScreen> {
  final emailTextEditor=TextEditingController();
  final _formkey = GlobalKey<FormState>();
  void _Submit()
  {
    firebaseAuth.sendPasswordResetEmail(
        email: emailTextEditor.text.trim()
    ).then((value){
      Fluttertoast.showToast(msg: "We have sent you an email to recover password, please check email ");
    }).onError((error, stackTrace){
      Fluttertoast.showToast(msg: "Error Occurred \n ${error.toString()}");
    });
  }

  @override

  Widget build(BuildContext context) {
    bool darkTheme=MediaQuery.of(context).platformBrightness==Brightness.dark;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            Image.asset(darkTheme ? 'images/citydark.jpg' : 'images/city.jpg'),
            const SizedBox(height: 40,),
            Text(
              'Recovery',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 40,
                color: darkTheme ? Colors.greenAccent : Colors.orangeAccent,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height:50,),
            Padding(
              padding:  const EdgeInsets.fromLTRB(15,20,15,50),
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

                          decoration:  InputDecoration(
                              hintText: "Enter your registered email",
                              hintStyle: const TextStyle(
                                color: Colors.grey,
                              ),
                              filled: true,
                              fillColor: darkTheme ? Colors.black : Colors.white,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                  borderSide: const BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  )
                              ),
                              prefixIcon: Icon(Icons.email_rounded,color: darkTheme ? Colors.greenAccent: Colors.orange,)

                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (email){
                            if(email==null || email.isEmpty)
                            {
                              return "Email is required";
                            }
                            if(email.length <2 || email.length>25)
                            {
                              return"Please Enter Valid Name";
                            }
                            if(EmailValidator.validate(email))
                            {
                              return null;
                            }
                            return null;
                          },
                          onChanged: (Text)=>setState(() {
                            emailTextEditor.text=Text;
                          }),
                        ),
                        const SizedBox(height:20,),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkTheme ? Colors.green : Colors.orange,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(80.0),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
                            minimumSize: const Size(double.minPositive,40,),

                          ),
                          onPressed: (){
                            _Submit();

                          }, child: const Text(
                           "Send password reset link",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),

                        ),
                        ),

                        const SizedBox(height:60, width: 10,),
                        //Create Accounts
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(context,MaterialPageRoute(builder:  (c)=>const LoginScreen()));
                          },
                          child: const Center( child:
                          Text(
                            "Already have an account?",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ),
                        ),
                        const SizedBox(width: 10, height: 10,)
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

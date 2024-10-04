import 'package:cab/global/global.dart';
import 'package:cab/screen/login_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'forget.dart';
class register_screen extends StatefulWidget {
  const register_screen({super.key});

  @override
  State<register_screen> createState() => _register_screenState();

}


class _register_screenState extends State<register_screen> {
  final NameTextEditingControler = TextEditingController();
  final EmailTextEditingControler = TextEditingController();
  final PhoneTextEditingControler = TextEditingController();
  final AddressTextEditingControler = TextEditingController();
  final PasswordTextEditingControler = TextEditingController();
  final CnfPasswordTextEditingControler = TextEditingController();
  bool passwordvisible = false;
  bool cnfpassword = false;

  //GlobalKey
  final _formkey = GlobalKey<FormState>();

  void _Submit() async {
    if (_formkey.currentState!.validate()) {
      await firebaseAuth.createUserWithEmailAndPassword(
        email: EmailTextEditingControler.text.trim(),
        password: PasswordTextEditingControler.text.trim(),
      ).then((auth) async {
        currentUser = auth.user;
        if (currentUser != null) {
          Map UserMap = {
            "id": currentUser!.uid,
            "name": NameTextEditingControler.text.trim(),
            "email": EmailTextEditingControler.text.trim(),
            "address": AddressTextEditingControler.text.trim(),
            "phone": PhoneTextEditingControler.text.trim(),
          };
          DatabaseReference UserRef = FirebaseDatabase.instance.ref().child(
              "users");
          UserRef.child(currentUser!.uid).set(UserMap);
        }
        await Fluttertoast.showToast(msg: "Successfully Registerd , Login now");
        Navigator.push(context, MaterialPageRoute(builder: (c) => const LoginScreen()));
      }).catchError((errorMessage) {
        Fluttertoast.showToast(msg: "User already registered \n Please login" );
      });
    }
    else {
      Fluttertoast.showToast(msg: "Not all Filed are valid !");
    }
  }


  @override
  Widget build(BuildContext context) {
    bool darktheme=MediaQuery.of(context).platformBrightness==Brightness.dark;
    return GestureDetector(
      onTap:(){ FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            Image.asset(darktheme ? 'images/citydark.jpg' : 'images/city.jpg'),
            const SizedBox(height: 2,),
            Text(
              'Register',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: darktheme ? Colors.amber.shade400:Colors.red,
                fontSize: 30,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,

              ),

            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15,20,15,50),
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
                              hintText: "Name",
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
                                )
                              ),
                              prefixIcon: Icon(Icons.person,color: darktheme ? Colors.yellow : Colors.red,)

                            ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (text){
                            if(text == null || text.isEmpty)
                              {
                                return "name can`t be Empty";
                              }
                            if(text.length <2 || text.length>25 ){
                              return "Please Enter Valid Name";
                            }
                            return null;
                          },
                          onChanged: (Text)=>setState(() {
                            NameTextEditingControler.text=Text;
                          }),
                        ),
                  //EMail Box
                        const SizedBox(height: 10,),
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(50)
                          ],
                          decoration: InputDecoration(
                              hintText: "Email",

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
                                  )
                              ),
                              prefixIcon: Icon(Icons.email,color: darktheme ? Colors.yellow : Colors.red,)

                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,

                          validator: (email){

                            if(email == null || email.isEmpty){
                              return "Email can`t be Empty";
                            }
                            if(EmailValidator.validate(email)==true)
                              {
                                return null;
                              }
                            return null;
                            /*if(email.length <10 || email.length>30 ){
                              return "Please Enter Valid Email Address";
                            }*/
                          },
                          onChanged: (text)=>setState(() {
                            EmailTextEditingControler.text=text;
                          }),
                        ),
                        const SizedBox(height: 10,),
                       //PhoneBox For enter phone number
                         IntlPhoneField(
                           showCountryFlag: true,
                           dropdownIcon: Icon(
                             Icons.arrow_drop_down_rounded,
                             color: darktheme ? Colors.yellow : Colors.red,
                           ),
                           decoration: InputDecoration(
                             hintText: "Phone Number",
                             hintStyle: const TextStyle(
                               color: Colors.grey,
                             ),
                             filled: true,
                             fillColor: darktheme ? Colors.black : Colors.white,
                             border: OutlineInputBorder(
                                 borderRadius: BorderRadius.circular(50),
                                 borderSide: const BorderSide(
                                   width: 0,
                                   style: BorderStyle.none,
                                 )
                             ),
                           ),
                           initialCountryCode: 'IN',
                           onChanged: (text)=>setState(() {
                             PhoneTextEditingControler.text=text.completeNumber;
                           }),
                         ),
                        //Address
                        TextFormField(
                          keyboardType: TextInputType.streetAddress,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(50)
                          ],
                          decoration: InputDecoration(
                              hintText: "Enter your address",

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
                                  )
                              ),
                              prefixIcon: Icon(Icons.home_filled,color: darktheme ? Colors.yellow : Colors.red,)

                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,

                          validator: (address){

                            if(address == null || address.isEmpty){
                              return "Address can`t be Empty";
                            }

                            if(address.length <10 || address.length>50 ){
                              return "Please Enter Valid  Address";
                            }
                            return null;
                          },
                          onChanged: (text)=>setState(() {
                            AddressTextEditingControler.text=text;
                          }),
                        ),
                        const SizedBox(height: 10,),
                        //Password Fields
                        //password
                        TextFormField(
                          obscureText: !passwordvisible,
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
                                )
                            ),
                            prefixIcon: Icon(Icons.password,color: darktheme ? Colors.yellow : Colors.red,),
                            suffixIcon: IconButton(
                              icon: Icon(
                                passwordvisible ? Icons.visibility: Icons.visibility_off,
                                color: darktheme ? Colors.green : Colors.red,
                              ),
                              onPressed: (){
                                //Update the state of password visible variable
                                setState(() {
                                  passwordvisible =! passwordvisible;
                                });
                              },

                            ),

                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,

                          validator: (text){

                            if(text == null || text.isEmpty){
                              return "Enter Password";
                            }
                            if(text.length <8 || text.length>30 ){
                              return "Please Enter Valid password";
                            }
                            return null;
                          },
                          onChanged: (text)=>setState(() {
                            PasswordTextEditingControler.text=text;
                          }),
                        ),
                        const SizedBox(height: 10,),
                        //cnf password
                        TextFormField(
                          obscureText: !cnfpassword,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(50)
                          ],
                          decoration: InputDecoration(
                            hintText: "Confirm Password",

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
                                )
                            ),
                            prefixIcon: Icon(Icons.password,color: darktheme ? Colors.yellow : Colors.red,),
                            suffixIcon: IconButton(
                              icon: Icon(
                                cnfpassword ? Icons.visibility: Icons.visibility_off,
                                color: darktheme ? Colors.green : Colors.red,
                              ),
                              onPressed: (){
                                //Update the state of password visible variable
                                setState(() {
                                  cnfpassword =! cnfpassword;
                                });
                              },

                            ),

                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,

                          validator: (text){

                            if(text == null || text.isEmpty){
                              return "Confirm Password";
                            }
                            if(text != PasswordTextEditingControler.text)
                              {
                                return"Password Don`t match";
                              }
                            return null;
                          },
                          onChanged: (text)=>setState(() {
                            CnfPasswordTextEditingControler .text=text;
                          }),
                        ),
                        const SizedBox(height: 20,),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darktheme ? Colors.yellowAccent : Colors.red,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            minimumSize: const Size(200,40),

                          ),
                            onPressed: (){
                            _Submit();
                            }, child: const Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),

                        ),
                        ),
                        const SizedBox(height: 20,),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(context,MaterialPageRoute(builder:  (c)=>const forgetScreen()));
                          },
                          child: Text(
                            'Forget Password',
                            style: TextStyle(
                              color: darktheme ? Colors.yellowAccent : Colors.red,
                              fontSize: 20,
                            ),
                          ),

                        ),
                        const SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Have an account?",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),),
                            const SizedBox(width: 10,),
                            GestureDetector(
                              onTap: (){
                                Navigator.pushReplacement(context,MaterialPageRoute(builder: (c)=>const LoginScreen() ));
                              },
                              child: Text(
                                "Sign in",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: darktheme ? Colors.grey :Colors.grey,
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

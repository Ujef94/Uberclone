import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:user_app/authentication/login_screen.dart';
import 'package:user_app/methods/common_methods.dart';
import 'package:user_app/pages/home_page.dart';
import 'package:user_app/widgets/loading_dialog.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  bool isShowText = false;
  bool isShowButtonSignUp = false;
  bool isGETOTPButton = true;
  // var inputPhoneNumber = "";


  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController userPhoneTextEditingController = TextEditingController();

  CommonMethods cMethods = CommonMethods();

  checkIfNetworkAvailable() {
    cMethods.checkConnectivity(context);

    signUpFormValidation();
  }

  signUpFormValidation() {
    if (userNameTextEditingController.text.trim().length < 3) {
      cMethods.displaySnackBar(
          "Your name must be at-least 4 or more then 4 characters ", context);
    } else if (userPhoneTextEditingController.text.trim().length < 10) {
      cMethods.displaySnackBar("Your number must be of 10 digit", context);
    } else if (!emailTextEditingController.text.contains("@")) {
      cMethods.displaySnackBar("Please check your email!!", context);
    } else if (passwordTextEditingController.text.trim().length < 8) {
      cMethods.displaySnackBar(
          "Your password must be of 8 digit or more", context);
    } else {
      // register user
      registerNewUser();
    }
  }

  // firstName
  // last Name
  // email
  // gender
  // email
  // id
  // status
  // phone       verifyButton  ->  OTP screen Enter Otp - true -> checkmark
  // password
  // register
  ///--------------------------------------------

  // Login
  // email
  // password
  // true  -> Home/Dashboard




  registerNewUser() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: "Registering your account..."),
    );
    final User? userFirebase = (
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim(),
        )
            .catchError((errorMsg) {
          Navigator.pop(context);
          cMethods.displaySnackBar(errorMsg.toString(), context);
        }))
        .user;

    if (!context.mounted) return;
    Navigator.pop(context);

    DatabaseReference userRef =
    FirebaseDatabase.instance.ref().child("users").child(userFirebase!.uid);
    Map userDataMap = {
      "name": userNameTextEditingController.text.trim(),
      "email": emailTextEditingController.text.trim(),
      "phone": userPhoneTextEditingController.text.trim(),
      "id": userFirebase.uid,
      "blockStatus": "no",
    };
    userRef.set(userDataMap);

    Navigator.push(context, MaterialPageRoute(builder: (c) => HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Image.asset("assets/images/logo.png"),
              const Text(
                "Create a User\'s Account",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Text Fields + button
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    TextField(
                      controller: userNameTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "User Name",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    TextField(
                      controller: userPhoneTextEditingController,
                      keyboardType: TextInputType.text,
                      // onChanged: (value) {
                      //   inputPhoneNumber = value;
                      // },
                      decoration: const InputDecoration(
                        labelText: "User Phone ",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "User Email",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    TextField(
                      controller: passwordTextEditingController,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "User Password",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    Visibility(
                      visible: isShowText,
                      child: const TextField(
                        // controller: passwordTextEditingController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: "Enter OTP",
                          labelStyle: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 32,
                    ),

                    Visibility(
                      visible: isGETOTPButton,
                      child:   ElevatedButton(
                        onPressed: () async{
                          // print("checking function sms call!!!!");
                          // print(userPhoneTextEditingController.text);
                          await FirebaseAuth.instance.verifyPhoneNumber(

                            phoneNumber: '+91'+userPhoneTextEditingController.text,

                            verificationCompleted: (PhoneAuthCredential credential) {},

                            verificationFailed: (FirebaseAuthException e) {
                              cMethods.displaySnackBar("Error Occurred${e.code}", context);
                            },

                            codeSent: (String verificationId, int? resendToken) {},

                            codeAutoRetrievalTimeout: (String verificationId) {},

                          );

                          setState(() {
                            if(isShowText == false && isShowButtonSignUp == false && isGETOTPButton == true) {
                              isShowText = true;
                              isShowButtonSignUp = true;
                              isGETOTPButton = false;
                            }
                          });
                        },
                        style: const ButtonStyle(
                          shape: MaterialStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          padding: MaterialStatePropertyAll(
                            EdgeInsets.symmetric(horizontal: 80, vertical: 10),
                          ),
                          backgroundColor:
                          MaterialStatePropertyAll(Colors.purple),
                        ),
                        child: const Text("Get OTP"),
                      ),),



                    Visibility(visible: isShowButtonSignUp,
                      child:  ElevatedButton(
                        onPressed: () {
                          checkIfNetworkAvailable();
                        },
                        style: const ButtonStyle(
                          shape: MaterialStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          padding: MaterialStatePropertyAll(
                            EdgeInsets.symmetric(horizontal: 80, vertical: 10),
                          ),
                          backgroundColor:
                          MaterialStatePropertyAll(Colors.purple),
                        ),

                        child: const Text("Sign Up"),
                      ),
                    ),


                  ],
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              // textButton
              TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (c) => LoginScreen()));
                },
                child: const Text(
                  "Already have an Account? Login Here",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
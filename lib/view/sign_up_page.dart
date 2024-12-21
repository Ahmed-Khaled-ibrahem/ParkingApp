import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:parking/bloc/app_bloc/app_bloc.dart';
import 'package:parking/bloc/auth_bloc/auth_bloc.dart';
import 'package:parking/bloc/auth_bloc/auth_bloc.dart';
import 'package:parking/view/widgets/elevated_button_std.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final formKey = GlobalKey<FormState>();
  var isSelected = [true, false];
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final passwordController = TextEditingController();
  final parkingUnitIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (authContext, state) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      // Transform.scale(
                      //   scale: 1.5,
                      //   child: Lottie.asset('assets/signup.json', height: 100,
                      //     width: 100,
                      //     // frameRate: FrameRate(500),
                      //   ),
                      // ),
                      ToggleButtons(
                        onPressed: (int index) {
                          setState(() {
                            isSelected = [false, false];
                            isSelected[index] = true;
                          });
                          print(index);
                        },
                        isSelected: isSelected,
                        children: [
                          SizedBox(
                            height: 100,
                            width: MediaQuery.of(context).size.width / 2 - 30,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.cabin_rounded,
                                  size: 50,
                                ),
                                Text('Unit Owner'),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 100,
                            width: MediaQuery.of(context).size.width / 2 - 30,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.route,
                                  size: 50,
                                ),
                                Text('Customer'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      TextFormField(
                        controller: firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'First Name is required';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Last Name is required';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: phoneNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Phone',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Phone is required';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          return null;
                        },
                      ),
                      isSelected[0]
                          ? TextFormField(
                              controller: parkingUnitIdController,
                              decoration: const InputDecoration(
                                labelText: 'Parking Unit ID',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Parking Unit is required';
                                }
                                return null;
                              },
                            )
                          : Container(),
                      SizedBox(
                        height: 30,
                      ),
                      BlocBuilder<AppBloc, AppState>(
                        builder: (context, state) {
                          return ElevatedButtonStd(
                            onPressed: () async {

                              late UserCredential userCredential;

                              if (formKey.currentState!.validate()) {
                                formKey.currentState!.save();
                                print('Signing Up');

                                try {
                                   userCredential =
                                      await authContext
                                          .read<AuthBloc>()
                                          .auth
                                          .createUserWithEmailAndPassword(
                                              email: emailController.text,
                                              password:
                                                  passwordController.text);
                                } on FirebaseAuthException catch (e) {
                                  if (e.code == 'weak-password') {
                                    print('The password provided is too weak.');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'The password provided is too weak.')));
                                  } else if (e.code == 'email-already-in-use') {
                                    print(
                                        'The account already exists for that email.');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'The account already exists for that email.')));
                                  }
                                } catch (e) {
                                  print(e);
                                }
                                print('heeeere');

                                FirebaseDatabase.instance.ref().child('users/${userCredential.user!.uid}').update({
                                    'first_name': firstNameController.text,
                                    'last_name': lastNameController.text,
                                    'email': emailController.text,
                                    'phone': phoneNumberController.text,
                                    'password': passwordController.text,
                                    'is_unit_owner': isSelected[0],
                                    'parking_unit_id': isSelected[0]
                                        ? parkingUnitIdController.text : ""
                                }).whenComplete(() {
                                  Navigator.pushNamed(context, '/thankyou');
                                });
                              }
                            },
                            child: const Text('Create Account'),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

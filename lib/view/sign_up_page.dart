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
  final plateNumberController = TextEditingController();

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
                        keyboardType: TextInputType.phone,
                        maxLength: 11,
                        decoration: const InputDecoration(
                          labelText: 'Phone',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Phone is required';
                          }
                          if (value.length < 10) {
                            return 'Phone must be at least 10 digits';
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
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      isSelected[0]
                          ? TextFormField(
                              controller: parkingUnitIdController,
                              decoration: const InputDecoration(
                                labelText: 'Parking Unit ID',
                                counterText: "Comma Separated for Multiple Units",
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Parking Unit is required';
                                }
                                return null;
                              },
                            )
                          : TextFormField(
                              controller: plateNumberController,
                              decoration: const InputDecoration(
                                labelText: 'Plate Number',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Plate Number is required';
                                }
                                return null;
                              },
                            ),
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

                                await authContext
                                    .read<AuthBloc>()
                                    .auth
                                    .createUserWithEmailAndPassword(
                                        email: emailController.text.trim(),
                                        password: passwordController.text).then((userCredential) {

                                  FirebaseDatabase.instance
                                      .ref()
                                      .child('users/${userCredential.user!.uid}')
                                      .update({
                                    'first_name': firstNameController.text,
                                    'last_name': lastNameController.text,
                                    'email': emailController.text.trim(),
                                    'phone': phoneNumberController.text,
                                    'password': passwordController.text,
                                    'is_unit_owner': isSelected[0],
                                    'plate_number': plateNumberController.text,
                                    'verified': false,
                                    'parking_unit_id': parkingUnitIdController.text
                                  }).whenComplete(() {
                                    Navigator.pushNamed(context, '/thankyou');
                                  });
                                }).catchError((e) {
                                  print('Error');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                       SnackBar(content: Text(e.toString())));
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

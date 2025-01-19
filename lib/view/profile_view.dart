import 'package:lottie/lottie.dart' as lottie;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/app_bloc/app_bloc.dart';
import '../bloc/auth_bloc/auth_bloc.dart';

class ProfileView extends StatelessWidget {
  ProfileView({super.key});

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController numberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
        ),
        body: SingleChildScrollView(
          child: Builder(builder: (context) {

            var uid = context.read<AuthBloc>().auth.currentUser!.uid;
            print(uid);
            String firstName = context
                .read<AppBloc>()
                .usersData!
                .child(uid.toString())
                .child('first_name')
                .value
                .toString();
            String lastName = context
                .read<AppBloc>()
                .usersData!
                .child(uid.toString())
                .child('last_name')
                .value
                .toString();
            String phone = context
                .read<AppBloc>()
                .usersData!
                .child(uid.toString())
                .child('phone')
                .value
                .toString();
            String plateNumber = context
                .read<AppBloc>()
                .usersData!
                .child(uid.toString())
                .child('plate_number')
                .value
                .toString();
            firstNameController.text = firstName;
            lastNameController.text = lastName;
            phoneController.text = phone;
            numberController.text = plateNumber;
            return Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Transform.scale(
                    scale: 1,
                    child: lottie.Lottie.asset(
                      'assets/pro.json',
                      height: 200,
                      width: 200,
                    ),
                  ),
                  Text(
                    'Email',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(context.read<AuthBloc>().auth.currentUser!.email!),
                  Divider(),
                  Text(
                    'Account Type',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(context
                              .read<AppBloc>()
                              .usersData!
                              .child(uid.toString())
                              .child('is_unit_owner')
                              .value ==
                          true
                      ? "Unit Owner"
                      : "User"),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  context
                              .read<AppBloc>()
                              .usersData!
                              .child(uid.toString())
                              .child('is_unit_owner')
                              .value ==
                          true
                      ? Container()
                      : TextField(
                          controller: numberController,
                          decoration: const InputDecoration(
                            labelText: 'Plate Number',
                            border: OutlineInputBorder(),
                          ),
                        ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 0.1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        updateValues(context);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Save',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  updateValues(BuildContext context) {
    String uid = context.read<AuthBloc>().auth.currentUser!.uid;
    context.read<AppBloc>().setValues(uid, firstNameController.text,
        lastNameController.text, phoneController.text, numberController.text);
    context.read<AppBloc>().read_values();
  }
}

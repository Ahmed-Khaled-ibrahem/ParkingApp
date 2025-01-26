import 'package:lottie/lottie.dart' as lottie;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking/view/widgets/verficationDialog.dart';
import '../bloc/app_bloc/app_bloc.dart';
import '../bloc/auth_bloc/auth_bloc.dart';

class ProfileView extends StatefulWidget {
  ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController numberController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
          actions: [
            BlocBuilder<AppBloc, AppState>(
              builder: (context, state) {
                var uid = context.read<AuthBloc>().auth.currentUser!.uid;
                print(uid);

                bool isAdmin = context
                    .read<AppBloc>()
                    .usersData!
                    .child(uid.toString())
                    .child('is_unit_owner')
                    .value as bool;

                if (isAdmin) {
                  bool isVerified = context
                      .read<AppBloc>()
                      .usersData!
                      .child(uid.toString())
                      .child('verified')
                      .value as bool;
                  String deviceID = context
                      .read<AppBloc>()
                      .usersData!
                      .child(uid.toString())
                      .child('parking_unit_id')
                      .value
                      .toString();

                  return IconButton(
                      onPressed: () {
                        if (isVerified) {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Verified'),
                                  content: Icon(
                                    Icons.verified,
                                    color: Colors.green,
                                    size: 80,
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () async {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('OK'))
                                  ],
                                );
                              });
                        } else {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return verificationDialog(context, deviceID, (){setState(() {
                                });});
                              });
                        }
                      },
                      icon: Icon(
                        Icons.verified,
                        color: isVerified ? Colors.green : Colors.red,
                        size: 30,
                      ));
                }
                return Container();
              },
            ),
          ],
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
            String unitNumber = context
                .read<AppBloc>()
                .usersData!
                .child(uid.toString())
                .child('parking_unit_id')
                .value
                .toString();
            bool isUnitOwner = context
                .read<AppBloc>()
                .usersData!
                .child(uid.toString())
                .child('is_unit_owner')
                .value as bool;
            firstNameController.text = firstName;
            lastNameController.text = lastName;
            phoneController.text = phone;
            numberController.text = isUnitOwner ? unitNumber : plateNumber;
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
                    maxLength: 11,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Builder(builder: (context) {
                    if (context
                            .read<AppBloc>()
                            .usersData!
                            .child(uid.toString())
                            .child('is_unit_owner')
                            .value ==
                        true) {
                      return TextField(
                        controller: numberController,
                        decoration: const InputDecoration(
                          labelText: 'Unit Number',
                          counterText: "Comma Separated for Multiple Units",
                          border: OutlineInputBorder(),
                        ),
                      );
                    }
                    return TextField(
                      controller: numberController,
                      decoration: const InputDecoration(
                        labelText: 'Plate Number',
                        border: OutlineInputBorder(),
                      ),
                    );
                  }),
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
    context
        .read<AppBloc>()
        .setValues(uid, firstNameController.text, lastNameController.text,
            phoneController.text, numberController.text)
        .then((d) {
      context.read<AppBloc>().read_values();
      context.read<AppBloc>().add(Updater());
      setState(() {});
    });
  }
}

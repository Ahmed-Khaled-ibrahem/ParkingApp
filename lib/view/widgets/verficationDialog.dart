import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/app_bloc/app_bloc.dart';
import '../../bloc/auth_bloc/auth_bloc.dart';

Widget verificationDialog(BuildContext context, String devicesIDs, Function onTap) {
  List<String> devices = devicesIDs.split(',');
  Map? verifiedDevicesMap = context.read<AppBloc>().usersData!.child(context.read<AuthBloc>().auth.currentUser!.uid.toString()).child('verified_list').value as Map?;
  // context.read<AppBloc>().add_verified_device(context.read<AuthBloc>().auth.currentUser!.uid.toString(), devicesIDs);
  return AlertDialog(
    title: Text('Devices Verification', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
    content: SizedBox(
      height: 200, width: 300,
      child: Column(
        children: [
          Text('You have ${devices.length} devices', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
          ListView.builder(
            shrinkWrap: true,
            itemCount: devices.length,
            itemBuilder: (context, index) {

              String deviceID = devices[index].trim();
              bool isExist = context.read<AppBloc>().data!.child(deviceID).child('pass').value != null;

              return isExist ? ListTile(
                title: Text(deviceID),
                subtitle: Text(verifiedDevicesMap != null && verifiedDevicesMap.containsKey(deviceID) ? 'Verified' : 'Not Verified', style: TextStyle(color: verifiedDevicesMap != null && verifiedDevicesMap.containsKey(deviceID) ? Colors.green : Colors.red),),
                trailing: Builder(builder: (context) {
                  if (verifiedDevicesMap != null && verifiedDevicesMap.containsKey(deviceID)) {
                    return Icon(Icons.check, color: Colors.green, size: 30,);
                  }
                  return ElevatedButton(
                    child: Text('Verify'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierColor: Colors.blueGrey.withOpacity(0.8),
                        builder: (BuildContext context) {
                          var passwordController = TextEditingController();
                          return AlertDialog(
                            title: Text('Enter Password'),
                            content: TextField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: InputDecoration(hintText: 'Password'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  String enteredPassword = passwordController.text;
                                  String password = context.read<AppBloc>().data!.child(deviceID).child('pass').value.toString();
                                  if (enteredPassword == password) {
                                    context.read<AppBloc>().add_verified_device(context.read<AuthBloc>().auth.currentUser!.uid.toString(), deviceID);
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Done verifying")));
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Wrong Password")));
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: Text('Verify'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                }),
              ) : ListTile(
                title: Text(deviceID),
                subtitle: Text('Hardware Not Found', style: TextStyle(color: Colors.red),),);
            },),
        ],
      ),
    ),
    actions: [
      TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel')),

      TextButton(
          onPressed: () async {
            if(verifiedDevicesMap == null){ Navigator.of(context).pop(); return; }
            bool isVerified = true;
            devices.forEach((element){
              if( !verifiedDevicesMap.containsKey(element.trim()) ){
                isVerified = false;
              }
            });
            if (isVerified) {
              context.read<AppBloc>().setVerified(context.read<AuthBloc>().auth.currentUser!.uid);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("your account is verified")));
              await context.read<AppBloc>().read_values();
              Navigator.of(context).pop();
              onTap();
            } else {
              Navigator.of(context).pop();
            }
          },
          child: Text('Save'))
    ],
  );
}

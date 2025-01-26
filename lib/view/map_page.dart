
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:parking/bloc/app_bloc/app_bloc.dart';
import 'package:parking/bloc/auth_bloc/auth_bloc.dart';
import 'package:parking/view/widgets/elevated_button_std.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:workmanager/workmanager.dart';
import 'bottom_sheet.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';

class MapPage extends StatefulWidget {
  MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? selectedLocation;
  bool isPublic = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      buildWhen: (state, previousState) {
        return true;
      },
      bloc: context.read<AppBloc>(),
      builder: (context, state) {
        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) async {
            await context.read<AppBloc>().serviceStatusStream.cancel();
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text('ParkPro'),
              leading: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/profile');
                },
                child: const Icon(Icons.person),
              ),
              centerTitle: true,
              actions: [
                Builder(builder: (context) {
                  if (context.read<AppBloc>().usersData != null) {
                    String parkingUnitId = context
                        .read<AppBloc>()
                        .usersData!
                        .child(context
                            .read<AuthBloc>()
                            .auth
                            .currentUser!
                            .uid
                            .toString())
                        .child('parking_unit_id')
                        .value
                        .toString();
                    List? waiting = context
                        .read<AppBloc>()
                        .data!
                        .child(parkingUnitId)
                        .child('waiting')
                        .value as List?;
                    if (waiting != null && waiting.isNotEmpty) {
                      return IconButton(
                        icon: Icon(
                          Icons.notification_important,
                          color: Colors.deepOrange,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (dialogContext) {
                              return AlertDialog(
                                title: const Text('Waiting List'),
                                content: Container(
                                  height: 250,
                                  width: 300,
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: waiting.length,
                                      itemBuilder: (context, index) {
                                        String? name = context
                                            .read<AppBloc>().usersData!
                                            .child(waiting[index])
                                            .child('first_name').value as String?;

                                        return ListTile(
                                            title: Text(name ?? "User"),
                                            trailing: ElevatedButton.icon(
                                              onPressed: () {
                                                context.read<AppBloc>().acceptedBook(waiting[index], parkingUnitId);

                                                context.read<AppBloc>().ref.child('hardware').child(parkingUnitId).update({
                                                  'waiting': []
                                                });

                                                Navigator.of(dialogContext).pop();
                                              },
                                              icon: Icon(
                                                Icons.done_outline,
                                                color: Colors.white,
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.green,
                                                elevation: 0
                                              ),
                                              label: Text('Accept', softWrap: true,style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                            ));
                                      }),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop();
                                    },
                                    child: const Text('Ok'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    }
                    return Container();
                  }
                  return CircularProgressIndicator();
                }),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (authContext, state) {
                    return IconButton(
                      icon: Icon(
                        Icons.logout_rounded,
                        color: Colors.red,
                      ),
                      onPressed: () async {
                        await authContext.read<AuthBloc>().auth.signOut();
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                        await context
                            .read<AppBloc>()
                            .serviceStatusStream
                            .cancel();
                        // Navigator.pushNamed(context, '/login');
                      },
                    );
                  },
                ),
              ],
            ),
            body: context.read<AppBloc>().currentLocation == null ||
                    context.read<AppBloc>().data == null
                ? Center(
                    child: Transform.scale(
                        scale: 3, child: CircularProgressIndicator()))
                : Builder(builder: (context) {
                    var isOwner = context
                        .read<AppBloc>()
                        .usersData!
                        .child(context
                            .read<AuthBloc>()
                            .auth
                            .currentUser!
                            .uid
                            .toString())
                        .child('is_unit_owner')
                        .value as bool;
                    var isVerified = context
                        .read<AppBloc>()
                        .usersData!
                        .child(context
                            .read<AuthBloc>()
                            .auth
                            .currentUser!
                            .uid
                            .toString())
                        .child('verified')
                        .value as bool;
                    var isBoth = isOwner && isVerified;
                    return Stack(
                      children: [
                        FlutterMap(
                          options: MapOptions(
                              initialZoom: 15.0,
                              initialCenter: context.read<AppBloc>().currentLocation ?? LatLng(35.2003774, 29.9513856),
                              onLongPress: (context2, point) {
                                if (isBoth) {
                                  setState(() {
                                    selectedLocation = point;
                                  });
                                }
                              }),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              // subdomains: ['a', 'b', 'c'],
                              // attributionBuilder: (_) {
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: context.read<AppBloc>().currentLocation!,
                                  width: 40.0,
                                  height: 40.0,
                                  child: Icon(
                                    Icons.location_history_rounded,
                                    color: Colors.blue,
                                    size: 40,
                                  ),
                                ),
                                selectedLocation == null
                                    ? Marker(
                                        point: LatLng(0, 0), child: Container())
                                    : Marker(
                                        point: selectedLocation!,
                                        width: 40.0,
                                        height: 40.0,
                                        child: InkWell(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                List<String> devicesIds = context
                                                    .read<
                                                    AppBloc>()
                                                    .usersData!
                                                    .child(context
                                                    .read<
                                                    AuthBloc>()
                                                    .auth
                                                    .currentUser!
                                                    .uid
                                                    .toString())
                                                    .child(
                                                    'parking_unit_id')
                                                    .value
                                                    .toString().split(',');

                                                return AlertDialog(
                                                  title: Text('Confirm Location'),
                                                  content: SizedBox(
                                                    width: 300,
                                                    height: 300,
                                                    child: Column(
                                                      children: [
                                                        Text('Please select your Unit'),
                                                        Divider(),
                                                        ListView.separated(
                                                          separatorBuilder: (context, index) => Divider(),
                                                          shrinkWrap: true,
                                                          itemCount: devicesIds.length,
                                                          itemBuilder: (BuildContext context, int index) {
                                                            return  ListTile(
                                                              title: Text(devicesIds[index].trim()),
                                                              leading: Icon(Icons.location_on),
                                                              onTap: () {
                                                                setState(() {
                                                                  context.read<AppBloc>().setHardwareLocation(
                                                                      devicesIds[index].trim(),
                                                                      selectedLocation!
                                                                          .latitude,
                                                                      selectedLocation!
                                                                          .longitude);
                                                                });
                                                                selectedLocation = null;
                                                                Navigator.of(context).pop();
                                                              },
                                                            );
                                                          },
                                                          ),
                                                        Divider()
                                                      ],
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child: Text('Cancel'),
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                        setState(() {
                                                          selectedLocation = null;
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          child: Icon(
                                            Icons.directions_car_filled,
                                            color: Colors.indigo,
                                            size: 40,
                                          ),
                                        ),
                                      ),
                                ...context
                                    .read<AppBloc>()
                                    .data!
                                    .children
                                    .map((e) {
                                  var lat = e.child('lat').value ?? 0;

                                  var lng = e.child('lng').value ?? 0;

                                  return Marker(
                                    point: LatLng(double.parse(lat.toString()),
                                        double.parse(lng.toString())),
                                    width: 40.0,
                                    height: 40.0,
                                    child: InkWell(
                                      onTap: () => showDialog<String>(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            Dialog(
                                          child: Padding(
                                            padding: const EdgeInsets.all(30),
                                            child: Stack(
                                              children: [
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      'ID',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(e.key.toString()),
                                                    Divider(),
                                                    Text(
                                                      'Address',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    SizedBox(
                                                      width: 150,
                                                      child: FutureBuilder(
                                                          future: placemarkFromCoordinates(
                                                              double.parse(lat
                                                                  .toString()),
                                                              double.parse(lng
                                                                  .toString())),
                                                          builder: (context,
                                                              snapshot) {
                                                            if (snapshot
                                                                .hasData) {
                                                              return Text(
                                                                snapshot
                                                                        .data!
                                                                        .first
                                                                        .street ??
                                                                    '',
                                                              );
                                                            }
                                                            return Text(
                                                                '------');
                                                          }),
                                                    ),
                                                    Divider(),
                                                    Text(
                                                      'State',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(e
                                                                .child('status')
                                                                .value ==
                                                            1
                                                        ? "Available"
                                                        : "Busy"),
                                                    // Divider(),
                                                    const SizedBox(height: 15),
                                                    Builder(builder: (context) {

                                                      var myID = context.read<AuthBloc>().auth.currentUser!.uid.toString();
                                                      var espID = e.key.toString();
                                                      List alldevices = context.read<AppBloc>().usersData!.child(myID).child('parking_unit_id').value.toString().split(',');

                                                      bool isMine = alldevices.any((e) => e.trim() == espID);

                                                      if (isMine) {
                                                        if (isBoth) {
                                                          return Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(
                                                                'Access',
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              Builder(builder:
                                                                  (context) {
                                                                bool? isPublic = context
                                                                    .read<
                                                                        AppBloc>()
                                                                    .data!
                                                                    .child(e.key
                                                                        .toString())
                                                                    .child(
                                                                        'is_public')
                                                                    .value as bool?;
                                                                print(isPublic);
                                                                if (!(isPublic ??
                                                                    true)) {
                                                                  return TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        context.read<AppBloc>().setHardwarePublic(e
                                                                            .key
                                                                            .toString());
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child: Text(
                                                                          'Make it Public'));
                                                                } else {
                                                                  return TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        context.read<AppBloc>().setHardwarePrivate(e
                                                                            .key
                                                                            .toString());
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child: Text(
                                                                          'Make it Private'));
                                                                }
                                                              }),
                                                            ],
                                                          );
                                                        }
                                                      }
                                                      return Container();
                                                    }),
                                                    ElevatedButtonStd(
                                                      onPressed: () async {
                                                        Navigator.pop(context);
                                                        MapsLauncher
                                                            .launchCoordinates(
                                                                double.parse(lat
                                                                    .toString()),
                                                                double.parse(lng
                                                                    .toString()));
                                                      },
                                                      child: const Text(
                                                          'Navigate'),
                                                    ),
                                                  ],
                                                ),
                                                Positioned(
                                                  right: 0,
                                                  child: Transform.scale(
                                                    scale: 3,
                                                    child: Image.asset(
                                                      'assets/image.png',
                                                      height: 100,
                                                      width: 100,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      child: Image.asset(
                                        'assets/image.png',
                                        height: 200,
                                        width: 200,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                            PolylineLayer(
                              polylines: [
                                Polyline(
                                  points: context.read<AppBloc>().polyPoints,
                                  color: Colors.blue,
                                  strokeWidth: 4.0,
                                ),
                              ],
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 20),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: state is NavigationModeOn
                                ? Card(
                                    color: Colors.blueAccent,
                                    child: ListTile(
                                      onTap: () {
                                        context.read<AppBloc>().polyPoints = [];
                                        context.read<AppBloc>().polyLines = {};
                                        context
                                            .read<AppBloc>()
                                            .add(CloseNavigation());
                                      },
                                      trailing: Icon(
                                        Icons.navigation,
                                        color: Colors.deepOrangeAccent.shade100,
                                        size: 50,
                                      ),
                                      title: Text(
                                        "Navigating",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineLarge
                                            ?.copyWith(color: Colors.white),
                                      ),
                                      subtitle: Text(
                                        'Click to cancel navigation',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(color: Colors.white),
                                      ),
                                    ),
                                  )
                                : Card(
                                    elevation: 8,
                                    child: ListTile(
                                      onTap: () {
                                        showModalBottomSheet<void>(
                                          context: context,
                                          useSafeArea: true,
                                          builder: (BuildContext context) {
                                            return BottomSheetDetail();
                                          },
                                        );
                                      },
                                      trailing: Text(
                                          context
                                              .read<AppBloc>()
                                              .data!
                                              .children
                                              .length
                                              .toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineLarge),
                                      title: Text('Active Parking Units'),
                                      subtitle: Text('Click for more details'),
                                    )),
                          ),
                        ),
                      ],
                    );
                  }),
          ),
        );
      },
    );
  }
}

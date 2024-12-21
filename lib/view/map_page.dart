import 'package:lottie/lottie.dart' as lottie;
import 'package:flutter/material.dart';
import 'package:parking/bloc/app_bloc/app_bloc.dart';
import 'package:parking/bloc/auth_bloc/auth_bloc.dart';
import 'package:parking/view/widgets/elevated_button_std.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'bottom_sheet.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';

class MapPage extends StatelessWidget {
  MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    var uid = context.read<AuthBloc>().auth.currentUser!.uid;

    return BlocBuilder<AppBloc, AppState>(
      // bloc: BlocProvider.of<AppBloc>(context)..add(loadInitials()),
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
                onPressed: () => showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => Dialog(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Transform.scale(
                            scale: 1.1,
                            child: lottie.Lottie.asset(
                              'assets/pro.json',
                              height: 100,
                              width: 100,
                            ),
                          ),
                          Text(
                            "${context.read<AppBloc>().usersData!.child(uid.toString()).child('first_name').value.toString()} ${context.read<AppBloc>().usersData!.child(uid.toString()).child('last_name').value.toString()}",
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Divider(),

                          Text(
                            'Email',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(context
                              .read<AuthBloc>()
                              .auth
                              .currentUser!
                              .email!),
                          Divider(),
                          Text(
                            'Phone',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(context
                              .read<AppBloc>()
                              .usersData!
                              .child(uid.toString())
                              .child('phone')
                              .value
                              .toString()),
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
                                      .value !=
                                  null
                              ? "Unit Owner"
                              : "User"),
                          // Divider(),

                          // const SizedBox(height: 15),
                          // TextButton(
                          //   onPressed: () {
                          //     Navigator.pop(context);
                          //   },
                          //   child: const Text('Okay'),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
                child: const Icon(Icons.person),
              ),
              centerTitle: true,
              actions: [
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (authContext, state) {
                    return IconButton(
                      icon: Icon(
                        Icons.logout_rounded,
                        color: Colors.red,
                      ),
                      onPressed: () async {
                        await authContext.read<AuthBloc>().auth.signOut();
                        Navigator.of(context).popUntil((route) => route.isFirst);
                        await context.read<AppBloc>().serviceStatusStream.cancel();
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
                : Stack(
                    children: [
                      FlutterMap(
                        options: MapOptions(
                          initialZoom: 15.0,
                          initialCenter:
                              context.read<AppBloc>().currentLocation ??
                                  LatLng(35.2003774, 29.9513856),
                        ),
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
                              ...context
                                  .read<AppBloc>()
                                  .data!
                                  .children
                                  .map((e) {
                                var lat = e.child('lat').value;

                                var lng = e.child('lng').value;

                                return Marker(
                                  point: LatLng(double.parse(lat.toString()),
                                      double.parse(lng.toString())),
                                  width: 40.0,
                                  height: 40.0,
                                  child: InkWell(
                                    onTap: () => showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) => Dialog(
                                        child: Padding(
                                          padding: const EdgeInsets.all(30),
                                          child: Stack(
                                            children: [
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
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
                                                        future:
                                                            placemarkFromCoordinates(
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
                                                          return Text('------');
                                                        }),
                                                  ),
                                                  Divider(),
                                                  Text(
                                                    'State',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(e.child('status').value ==
                                                          1
                                                      ? "Available"
                                                      : "Busy"),
                                                  // Divider(),

                                                  const SizedBox(height: 15),
                                                  ElevatedButtonStd(
                                                    onPressed: () async {
                                                      Navigator.pop(context);
                                                      MapsLauncher.launchCoordinates(double.parse(lat.toString()),double.parse(lng.toString()));
                                                    },
                                                    child:
                                                        const Text('Navigate'),
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
                  ),
          ),
        );
      },
    );
  }
}

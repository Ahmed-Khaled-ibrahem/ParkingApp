import 'dart:async';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:parking/model/line_string.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:workmanager/workmanager.dart';
import '../../repo/network.dart';

part 'app_event.dart';

part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  LatLng? currentLocation;
  DatabaseReference ref = FirebaseDatabase.instance.ref();
  DataSnapshot? data;
  DataSnapshot? usersData;

  double startLat = 23.551904;
  double startLng = 90.532171;
  double endLat = 31.199896;
  double endLng = 29.927821;
  var data2;

  LatLng destination = LatLng(31.199896, 29.927821);

  List<LatLng> polyPoints = [];
  Set<Polyline> polyLines = {};

  late StreamSubscription<Position> serviceStatusStream;

  AppBloc() : super(AppInitial()) {
    on<AppEvent>((event, emit) {});

    on<loadInitials>((event, emit) async {
      await getCurrentLocation();
      print('done');
      await read_values();
      emit(MyLocationLoaded());
      ref.onValue.listen((event) async {
        await read_values();
        add(Updater());
      });
    });

    on<StartButtonOnPressed>((event, emit) async {
      // in release make it un commented
      // serviceStatusStream =
      //     Geolocator.getPositionStream().listen((Position status) async {
      //       print("location position changed");
      //       print(status);
      //       await getCurrentLocation();
      //       add(Updater());
      //     });
    });

    on<NavigationStarted>((event, emit) async {
      await getJsonData();
      print('navigation started');
      emit(NavigationModeOn());
    });

    on<Updater>((event, emit) async {
      print("updating");
      emit(Refresh1());
      emit(Refresh2());
    });

    on<CloseNavigation>((event, emit) async {
      print('navigation off');
      emit(NavigationModeOff());
    });
  }

  Future<DataSnapshot?> read_values() async {
    await ref.get().then((value) {
      data = value.child('hardware');
      usersData = value.child('users');
      add(Updater());
      return data;
    });
    return null;
  }

  Future setValues(String userId, String firstName, String lastName,
      String phone, String? number) async {
    bool isUnitOwner = usersData!
        .child(userId.toString())
        .child('is_unit_owner')
        .value as bool;
    String currentFirstName = usersData!
        .child(userId.toString())
        .child('first_name')
        .value
        .toString();
    String currentLastName =
        usersData!.child(userId.toString()).child('last_name').value.toString();
    String currentPhone =
        usersData!.child(userId.toString()).child('phone').value.toString();
    String currentNumber = isUnitOwner
        ? usersData!
            .child(userId.toString())
            .child('parking_unit_id')
            .value
            .toString()
        : usersData!
            .child(userId.toString())
            .child('plate_number')
            .value
            .toString();

    if (currentFirstName != firstName ||
        currentLastName != lastName ||
        currentPhone != phone ||
        currentNumber != number) {
      if (isUnitOwner) {
        await ref.child('users').child(userId).update({
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
          'parking_unit_id': number,
          'verified': false
        });
      } else {
        await ref.child('users').child(userId).update({
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
          'plate_number': number
        });
      }
    } else {
      print('no change');
    }
  }

  setVerified(String userId) async {
    await ref.child('users').child(userId).update({'verified': true});
  }

  setHardwareLocation(String HardId, double lat, double lng) async {
    await ref
        .child('hardware')
        .child(HardId)
        .update({'lat': lat, 'lng': lng}).then((d) {
      read_values();
    });
  }

  setHardwarePublic(String HardId) async {
    await ref
        .child('hardware')
        .child(HardId)
        .update({'is_public': true}).then((d) {
      read_values();
    });
  }

  setHardwarePrivate(String HardId) async {
    await ref
        .child('hardware')
        .child(HardId)
        .update({'is_public': false}).then((d) {
      read_values();
    });
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );
    // Get the current location
    Position position =
        await Geolocator.getCurrentPosition(locationSettings: locationSettings);

    currentLocation = LatLng(position.latitude, position.longitude);
  }

  Future getJsonData() async {
    NetworkHelper network = NetworkHelper(
      startLat: currentLocation!.latitude,
      startLng: currentLocation!.longitude,
      endLat: destination.latitude,
      endLng: destination.longitude,
    );

    try {
      // getData() returns a json Decoded data
      data2 = await network.getData();

      // We can reach to our desired JSON data manually as following
      LineString ls =
          LineString(data2['features'][0]['geometry']['coordinates']);

      for (int i = 0; i < ls.lineString.length; i++) {
        polyPoints.add(LatLng(ls.lineString[i][1], ls.lineString[i][0]));
      }

      Polyline polyline = Polyline(
        color: Colors.red,
        points: polyPoints,
      );
      return polyLines.add(polyline);
    } catch (e) {
      print(e);
    }
  }

  void scheduleEmail(String Target) {
    Workmanager().registerOneOffTask(
      "sendEmailTask",
      "sendEmailTask",
      initialDelay: Duration(minutes: 9,seconds: 30),
      inputData: <String, dynamic>{
        "target": Target
      },
    );
  }

  void bookParkingUnit(String userId, String parkingUnitId) async {
    bool? isPublic = data!.child(parkingUnitId).child('is_public').value as bool?;
    if(isPublic == true || isPublic == null){
      await ref.child('hardware').child(parkingUnitId).update({
        'booked': {
          'by': userId,
          'until': DateTime.now().add(Duration(minutes: 10)).toIso8601String()
        }
      });
      scheduleEmail(usersData!.child(userId).child('email').value.toString());
    }
    else{
      await ref.child('hardware').child(parkingUnitId).child('waiting').get().then((value) {
        if(value.value != null){
          ref.child('hardware').child(parkingUnitId).update({
            'waiting': [...(value.value as List), userId],
          });
        }
        else{
           ref.child('hardware').child(parkingUnitId).update({
            'waiting': [userId],
          });
        }
      });
    }
  }
  acceptedBook(String userId, String parkingUnitId) async {
    await ref.child('hardware').child(parkingUnitId).update({
      'booked': {
        'by': userId,
        'until': DateTime.now().add(Duration(minutes: 10)).toIso8601String()
      }
    });
    scheduleEmail(usersData!.child(userId).child('email').value.toString());
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:parking/bloc/app_bloc/app_bloc.dart';
import '../bloc/auth_bloc/auth_bloc.dart';

class BottomSheetDetail extends StatefulWidget {
  const BottomSheetDetail({super.key});

  @override
  State<BottomSheetDetail> createState() => _BottomSheetDetailState();
}

class _BottomSheetDetailState extends State<BottomSheetDetail> {
  Timer _timer = Timer(const Duration(seconds: 1), () {});

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 40),
          child: Column(
            children: [
              Text(
                'Active Parking Units',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              Divider(),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    var lat = context.read<AppBloc>().data!.children.elementAt(index).child("lat").value ?? 0;
                    var lng = context.read<AppBloc>().data!.children.elementAt(index).child('lng').value ?? 0;
                    var deviceId = context.read<AppBloc>().data!.children.elementAt(index).key.toString();
                    var myDeviceIds = context.read<AppBloc>().usersData!.child(context.read<AuthBloc>().auth.currentUser!.uid.toString()).child('parking_unit_id').value.toString().split(',');
                    bool verified = context.read<AppBloc>().usersData!.child(context.read<AuthBloc>().auth.currentUser!.uid.toString()).child('verified').value as bool;

                    return ListTile(
                      onTap: (){
                        MapsLauncher.launchCoordinates(double.parse(lat.toString()),double.parse(lng.toString()));
                        Navigator.pop(context);
                      },
                      leading: Icon(Icons.local_parking),
                      title: Builder(builder: (context) {

                        bool isMine = myDeviceIds.any((e) => e.trim() == deviceId);

                        if(verified){
                          if(isMine){
                            return Text(deviceId + ' (MY UNIT)',style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),);
                          }
                        }

                        bool? isPublic = context.read<AppBloc>().data!.children.elementAt(index).child('is_public').value as bool?;
                        if(isPublic == null){
                          return Text(deviceId + ' (PUBLIC)');
                        }
                        if(isPublic == false){
                          return Text(deviceId + ' (Private)');
                        }
                        return Text(deviceId + ' (PUBLIC)');
                      }

                      ),
                      subtitle: SingleChildScrollView(
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
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                  softWrap: true,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                );
                              }
                              return Text('------');
                            }),
                      ),
                      trailing: Builder(
                        builder: (context) {
                          bool isAvailable = context
                              .read<AppBloc>()
                              .data!
                              .children
                              .elementAt(index)
                              .child('status')
                              .value
                              == 0;

                          var Booked = context
                              .read<AppBloc>()
                              .data!
                              .children
                              .elementAt(index)
                              .child('booked');

                          if(isAvailable == false){
                            return Icon(
                              Icons.event_busy_rounded,
                              color: Colors.red,
                              size: 40,
                            );
                          }

                          List? waitingQueue = context.read<AppBloc>().data!.children.elementAt(index).child('waiting').value as List?;

                          if(waitingQueue != null && waitingQueue.isNotEmpty && waitingQueue.contains(context.read<AuthBloc>().auth.currentUser!.uid.toString())){
                            return Text('Waiting \nAcceptance', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16),);
                          }

                          if(Booked.value != null){
                            var until = Booked.child('until').value.toString();
                            var now = DateTime.now();
                            var untilDateTime = DateTime.parse(until);
                            var differenceInSeconds = untilDateTime.difference(now).inSeconds;

                            if(differenceInSeconds <= 0){
                              return InkWell(
                                  onTap: () {
                                    context.read<AppBloc>().bookParkingUnit( context.read<AuthBloc>().auth.currentUser!.uid.toString(), deviceId);
                                  },
                                  child: Text('Book\nNow', softWrap: true,style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),));
                            }
                             _timer = Timer(Duration(seconds: 1), () {
                               try {
                                 setState(() {});
                               }
                              catch (e) {}
                             });

                            return Column(
                              children: [
                                Text('Booked', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),),
                                Text("${differenceInSeconds~/60}:${differenceInSeconds%60}", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),),
                              ],
                            );
                          }

                          if(isAvailable){
                            return InkWell(
                                onTap: () {
                                  context.read<AppBloc>().bookParkingUnit( context.read<AuthBloc>().auth.currentUser!.uid.toString(), deviceId);
                                },
                                child: Text('Book\nNow', softWrap: true,style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),));
                          }

                          return Icon(
                            Icons.event_busy_rounded,
                            color: Colors.red,
                            size: 40,
                          );
                        }
                      ),
                    );
                  },
                  itemCount: context.read<AppBloc>().data?.children.length,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


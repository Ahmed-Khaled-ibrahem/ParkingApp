import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:parking/bloc/app_bloc/app_bloc.dart';

class BottomSheetDetail extends StatelessWidget {
  const BottomSheetDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            children: [
              Text(
                'Active Parking Units',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              Divider(),
              ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  var lat = context.read<AppBloc>().data!.children.elementAt(index).child("lat").value;
                  var lng = context.read<AppBloc>().data!.children.elementAt(index).child('lng').value;

                  return ListTile(
                    onTap: (){
                      MapsLauncher.launchCoordinates(double.parse(lat.toString()),double.parse(lng.toString()));
                      Navigator.pop(context);
                    },
                    leading: Icon(Icons.local_parking),
                    title: Text(context
                        .read<AppBloc>()
                        .data!
                        .children
                        .elementAt(index)
                        .key
                        .toString()),
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
                    trailing: context
                        .read<AppBloc>()
                        .data!
                        .children
                        .elementAt(index)
                        .children
                        .firstWhere((element) => element.key == 'status')
                        .value
                        == 1 ? Icon(
                      Icons.event_available,
                      color: Colors.green,
                      size: 40,
                    ):Icon(
                      Icons.event_busy_rounded,
                      color: Colors.red,
                      size: 40,
                    ),
                  );
                },
                itemCount: context.read<AppBloc>().data?.children.length,
              ),
            ],
          ),
        );
      },
    );
  }
}

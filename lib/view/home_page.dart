import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:parking/bloc/app_bloc/app_bloc.dart';
import '../bloc/auth_bloc/auth_bloc.dart';
import 'widgets/elevated_button_std.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return Column(
                      children: [
                        Lottie.asset('assets/location.json', height: 350,
                            width: 350,
                            fit: BoxFit.cover),
                        Text('Welcome To \nSmart Parking', style: Theme
                            .of(context)
                            .textTheme
                            .displayLarge),
                        SizedBox(height: 20,),
                        ElevatedButtonStd(
                            onPressed: () async {
                              // read auth if user exist go map if no user go login
                              if (context.read<AuthBloc>().auth.currentUser != null) {
                                context.read<AppBloc>().add(StartButtonOnPressed());
                                Navigator.pushNamed(context, '/map');
                              }
                              else{
                                Navigator.pushNamed(context, '/login');
                              }
                            }, child: Text(context.read<AuthBloc>().auth.currentUser == null? 'Login': 'Get Started')),
                      ]);
                },
              ),
            ),
          ),
        ));
  }
}

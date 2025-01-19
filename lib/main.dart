import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking/bloc/auth_bloc/auth_bloc.dart';
import 'package:parking/view/home_page.dart';
import 'package:parking/view/login_page.dart';
import 'package:parking/view/map_page.dart';
import 'package:parking/view/profile_view.dart';
import 'package:parking/view/sign_up_page.dart';
import 'package:parking/view/thank_you_page.dart';
import 'bloc/app_bloc/app_bloc.dart';
import 'config/theme/dark_theme.dart';
import 'config/theme/light_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
          AppBloc()
            ..add(loadInitials()),
        ),
        BlocProvider(
          create: (context) => AuthBloc()..init(),
        ),
      ],
      child: MaterialApp(
        title: 'ParkPro',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.light,
        initialRoute: '/',
        routes: {
          '/': (context) => const HomePage(),
          '/map': (context) => MapPage(),
          '/login': (context) => LoginPage(),
          '/signup': (context) => SignUpPage(),
          '/thankyou': (context) => ThankYouPage(),
          '/profile': (context) => ProfileView(),
        },
      ),
    );
  }
}

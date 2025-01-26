import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:parking/bloc/auth_bloc/auth_bloc.dart';
import 'package:parking/view/home_page.dart';
import 'package:parking/view/login_page.dart';
import 'package:parking/view/map_page.dart';
import 'package:parking/view/profile_view.dart';
import 'package:parking/view/sign_up_page.dart';
import 'package:parking/view/thank_you_page.dart';
import 'package:workmanager/workmanager.dart';
import 'bloc/app_bloc/app_bloc.dart';
import 'config/theme/dark_theme.dart';
import 'config/theme/light_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print('background task is running');
    String username = 'Zshadowclashroyal@gmail.com';
    String password = 'gqqt thry fhei ddza';
    final smtpServer = gmail(username, password);
    // Create our message.
    final message = Message()
      ..from = Address(username, 'Smart Parking App')
      ..recipients.add(inputData!['target'])
      ..subject = 'Smart Parking Alert :: 😀 :: ${DateTime.now()}'
      ..text = inputData['content'];

    try {
      final sendReport = await send(message, smtpServer).catchError((e,s){
        print(e);
      });
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
    // sendmail(target: inputData!['target']);
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );

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

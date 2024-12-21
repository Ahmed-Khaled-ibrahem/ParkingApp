import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:parking/view/widgets/elevated_button_std.dart';


class ThankYouPage extends StatelessWidget {
  const ThankYouPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        centerTitle: true,
        title: Text('Account Created'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.scale(
              scale: 2,
              child: Lottie.asset('assets/thankyou.json', height: 200,
                width: 200,),
            ),
            ElevatedButtonStd(
              onPressed: () {
                Navigator.pushNamed(context, '/map');
              },
              child: Text('Start'),
            ),
          ],
        ),
      ),
    );
  }
}

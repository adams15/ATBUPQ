// import 'package:atbu_pq/pages/onboarding_page.dart';
// import 'package:atbu_pq/styles/colors.dart';
// import 'package:atbu_pq/styles/fonts.dart';
// import 'package:atbu_pq/utils/routers.dart';
// import 'package:atbu_pq/utils/show_message.dart';
// import 'package:atbu_pq/widgets/btn.dart';
// import 'package:atbu_pq/widgets/formfield.dart';
// import 'package:flutter/material.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     Navigate();
//   }

//   void Navigate() {
//     Future.delayed(Duration(seconds: 5), () {
//       PageNavigator(context: context).nextPageOnly(page: OnboardingPage());
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: splashScreenColor,
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Image.asset('images/logo.png'),
//               Text(
//                 'ATBUPQ',
//                 style: klogoText,
//               )
//             ],
//           ),
//         ));
//   }
// }

import 'package:atbu_pq/pages/login_page.dart';
import 'package:atbu_pq/pages/onboarding_page.dart';
import 'package:atbu_pq/styles/colors.dart';
import 'package:atbu_pq/styles/fonts.dart';
import 'package:atbu_pq/utils/routers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    navigate();
  }

  void navigate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    Future.delayed(Duration(seconds: 5), () {
      if (isFirstLaunch) {
        prefs.setBool('isFirstLaunch', false);
        PageNavigator(context: context).nextPageOnly(page: OnboardingPage());
      } else {
        PageNavigator(context: context).nextPageOnly(page: LoginPage());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: splashScreenColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('images/logo.png'),
            Text(
              'ATBUPQ',
              style: klogoText,
            ),
          ],
        ),
      ),
    );
  }
}

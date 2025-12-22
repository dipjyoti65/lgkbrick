// import 'package:flutter/material.dart';

// /// Splash screen displayed during app initialization
// /// 
// /// Shows a loading indicator while the app checks for stored credentials
// /// and attempts to restore the user session.
// class SplashScreen extends StatelessWidget {
//   const SplashScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.business,
//               size: 100,
//               color: Theme.of(context).primaryColor,
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               'LGK Brick Management',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 48),
//             const CircularProgressIndicator(),
//           ],
//         ),
//       ),
//     );
//   }
// }

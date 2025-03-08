import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:movie_app/widgets/bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'utils/navigation_manager.dart';
import 'widgets/app_scaffold.dart';
import 'profile/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NavigationManager(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ReelsTek',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.brown,
          useMaterial3: true,
        ),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            if (snapshot.hasData) {
              return Consumer<NavigationManager>(
                builder: (context, navManager, _) {
                  return Scaffold(
                    body: navManager.getCurrentScreen(),
                  );
                },
              );
            }
            
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}

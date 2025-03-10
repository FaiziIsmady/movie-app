import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:movie_app/profile/services/profile_service.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utils/navigation_manager.dart';
import 'profile/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Initialize Firebase

  await SharedPreferences.getInstance(); // Retrieve sharedpreferences data

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationManager()),
        ChangeNotifierProvider(create: (_) => ProfileService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ReelsTek',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.deepPurple[50],
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
              // Firebase Auth state shows user is logged in
              return FutureBuilder<bool>(
                future: _checkLoginState(),
                builder: (context, stateSnapshot) {
                  if (stateSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Use NavigationManager to load the appropriate screen based on current user login state
                  return Consumer<NavigationManager>(
                    builder: (context, navManager, _) {
                      return Scaffold(
                        body: navManager.getCurrentScreen(), // NavigationManager controls which screen is shown
                      );
                    },
                  );
                },
              );
            } else {
              // User is logged out, show login screen
              return const LoginScreen();
            }
          },
        ),
      ),
    );
  }
  Future<bool> _checkLoginState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    return isLoggedIn;
  }
}

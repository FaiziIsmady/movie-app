import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:movie_app/profile/services/profile_service.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utils/navigation_manager.dart';
import 'profile/screens/login_screen.dart';
import 'utils/auth_state_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Initialize Firebase

  await SharedPreferences.getInstance(); // Initialize SharedPreferences

  // Run a check for the current user if they're logged in
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    final profileService = ProfileService();
    await profileService.ensureUserDocumentExists(
      currentUser.uid,
      currentUser.email
    );
  }

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
        ChangeNotifierProvider(create: (_) => AuthStateProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ReelsTek',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.deepPurple[50],
          useMaterial3: true,
        ),
        home: Consumer<AuthStateProvider>(
          builder: (context, authProvider, _) {
            // Show loading indicator while checking initial state
            if (authProvider.isLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            
            // Redirect based on login state
            if (authProvider.isLoggedIn) {
              return Consumer<NavigationManager>(
                builder: (context, navManager, _) {
                  return Scaffold(
                    body: navManager.getCurrentScreen(),
                  );
                },
              );
            } else {
              return const LoginScreen();
            }
          },
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movie_app/profile/services/profile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // AuthService() {
  //   // Connect to emulator
  //   _auth.useAuthEmulator('localhost', 9099);
  //   _firestore.useFirestoreEmulator('localhost', 8080);
  // }

  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userEmail', email);
      
      // Ensure user document exists
      final profileService = ProfileService();
      await profileService.ensureUserDocumentExists(
        userCredential.user!.uid, 
        userCredential.user!.email
      );
      
      return userCredential.user;
    } catch (e) {
      // Clear login state on failure
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      return null;
    }
  }

  Future<User?> register(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = userCredential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'name':'',
          'profilePictureUrl':'',
          'nickname': '',
          'hobbies': '',
          'socialMedia': '',
          'aboutMe': '',
        });
        // Save login state to SharedPreferences after successful registration
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userEmail', email);
      }

      return user;
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();

    // Clear login state in SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userEmail');
  }
}
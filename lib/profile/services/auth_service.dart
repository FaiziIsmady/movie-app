import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthService() {
    // Connect to emulator
    _auth.useAuthEmulator('localhost', 9099);
    _firestore.useFirestoreEmulator('localhost', 8080);
  }

  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      // Handle error
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
      }

      return user;
    } catch (e) {
      // Handle error
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
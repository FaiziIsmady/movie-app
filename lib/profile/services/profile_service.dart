import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ProfileService() { // Connect to firestore emulator
    _firestore.useFirestoreEmulator('localhost', 8080);
  }

  Future<UserProfile> getUserProfile(userId) async {
    if (userId == null) {
      throw Exception('User not logged in');
    }

    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      final data = doc.data()!;
      return UserProfile(
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        profilePictureUrl: data['profilePictureUrl'] ?? '',
        nickname: data['nickname'] ?? '',
        hobbies: data['hobbies'] ?? '',
        socialMedia: data['socialMedia'] ?? '',
        aboutMe: data['aboutMe'] ?? '',
      );
    } else {
      throw Exception('User not found');
    }
  }

  Future<void> updateUserProfile(UserProfile profile, String userId) async {
    await _firestore.collection('users').doc(userId).set({
      'name': profile.name,
      'email': profile.email,
      'profilePictureUrl': profile.profilePictureUrl,
      'nickname': profile.nickname,
      'hobbies': profile.hobbies,
      'socialMedia': profile.socialMedia,
      'aboutMe': profile.aboutMe,
    });
  }

  bool hasProfileData(UserProfile profile) {
    return profile.name.isNotEmpty || 
           profile.nickname.isNotEmpty || 
           profile.hobbies.isNotEmpty || 
           profile.socialMedia.isNotEmpty ||
           profile.aboutMe.isNotEmpty;
  }
}
import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movie_app/profile/models/user_profile.dart';
import 'package:flutter/foundation.dart';

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
      String profilePictureUrl = data['profilePictureUrl'] ?? '';
      
      // Check if it's a Firestore reference
      if (profilePictureUrl.startsWith('firestore://')) {
        // Retrieve the actual image data
        final imageData = await getProfileImageFromFirestore(userId);
        if (imageData != null) {
          profilePictureUrl = imageData;
        }
      }
      
      return UserProfile(
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        profilePictureUrl: profilePictureUrl,
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
  
  // Add method to upload image to Firestore
  Future<String> uploadImage(Uint8List imageBytes, String userId) async {
    try {
      print('Converting image to Base64');
      
      // Compress the image to reduce size
      final compressedBytes = await compute(_compressImage, imageBytes);
      
      // Convert to Base64
      final base64String = base64Encode(compressedBytes);
      
      // Create a data URL
      final imageUrl = 'data:image/jpeg;base64,$base64String';
      
      print('Image converted to Base64 (${base64String.length} chars)');
      
      // Store the Base64 string in a separate document to avoid size limits
      await _firestore.collection('profile_images').doc(userId).set({
        'imageData': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      print('Image stored in Firestore');
      
      // Return a reference URL
      return 'firestore://profile_images/$userId';
    } catch (e) {
      print('Error storing image in Firestore: $e');
      throw Exception('Failed to store profile image: $e');
    }
  }
  
  // Method to compress image (run in isolate)
  static Uint8List _compressImage(Uint8List bytes) {
    // Simple compression - in a real app, use a proper image compression library
    // This is a placeholder that just returns the original bytes
    return bytes;
  }
  
  // Method to retrieve the Base64 image
  Future<String?> getProfileImageFromFirestore(String userId) async {
    try {
      final doc = await _firestore.collection('profile_images').doc(userId).get();
      if (doc.exists && doc.data()!.containsKey('imageData')) {
        return doc.data()!['imageData'] as String;
      }
      return null;
    } catch (e) {
      print('Error retrieving image from Firestore: $e');
      return null;
    }
  }
}
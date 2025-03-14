import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movie_app/profile/models/user_profile.dart';
import 'package:flutter/foundation.dart';
import 'package:movie_app/profile/models/user_review.dart';

class ProfileService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ProfileService() { // Connect to firestore emulator
  //   _firestore.useFirestoreEmulator('localhost', 8080);
  // }

  Future<UserProfile> getUserProfile(userId) async {
    if (userId == null) {
      throw Exception('User not logged in');
    }

    try {
      // Get the current user's email if available
      final currentUser = FirebaseAuth.instance.currentUser;
      final email = currentUser?.email;

      // Ensure document exists before trying to read it
      await ensureUserDocumentExists(userId, email);

      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data()!;
        String profilePictureUrl = data['profilePictureUrl'] ?? '';

        // Check if it's a Firestore reference
        if (profilePictureUrl.startsWith('firestore://')) {
          // Retrieve image data
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
        throw Exception('User document not found even after creation attempt');
      }
    } catch (e) {
      print("Error in getUserProfile: $e");
      throw Exception('Failed to load user profile: $e');
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
      
      // Compress the image
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
  Future<void> addReview(Review review) async {
    await _firestore.collection('reviews').doc(review.id).set(review.toMap());
  }

  Future<void> updateReview(Review review) async {
    await _firestore.collection('reviews').doc(review.id).update({
      'reviewText': review.reviewText,
      'rating': review.rating,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> deleteReview(String reviewId) async {
    await _firestore.collection('reviews').doc(reviewId).delete();
  }

  Future<List<Review>> getUserReviews(String userId) async {
    final query = await _firestore
        .collection('reviews')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    
    return query.docs.map((doc) => Review.fromMap(doc.data(), doc.id)).toList();
  }

  Future<List<Review>> getMovieReviews(String movieId) async {
    final query = await _firestore
        .collection('reviews')
        .where('movieId', isEqualTo: movieId)
        .orderBy('createdAt', descending: true)
        .get();
    
    return query.docs.map((doc) => Review.fromMap(doc.data(), doc.id)).toList();
  }

  Future<void> ensureUserDocumentExists(String userId, String? email) async {
    try {
      // Check if document exists
      final docSnapshot = await _firestore.collection('users').doc(userId).get();
      
      // If document doesn't exist, create it
      if (!docSnapshot.exists) {
        print("Creating missing user document for user: $userId");
        
        await _firestore.collection('users').doc(userId).set({
          'uid': userId,
          'email': email ?? '',
          'name': '',
          'profilePictureUrl': '',
          'nickname': '',
          'hobbies': '',
          'socialMedia': '',
          'aboutMe': '',
        });
        
        print("User document created successfully");
      }
    } catch (e) {
      print("Error ensuring user document exists: $e");
    }
  }
}
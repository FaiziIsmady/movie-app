import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movie_app/profile/models/user_profile.dart';

class SocialService {
  // Query the users collection in Firestore based on the search query
  Future<List<UserProfile>> searchUsers(String query) async {
    final userCollection = FirebaseFirestore.instance.collection('users');

    // Perform a query that matches name, nickname, or email
    final result = await userCollection
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    final additionalResult = await userCollection
        .where('nickname', isGreaterThanOrEqualTo: query)
        .where('nickname', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    final emailResult = await userCollection
        .where('email', isGreaterThanOrEqualTo: query)
        .where('email', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    // Combine all results from different fields (name, nickname, email)
    List<UserProfile> users = [];
    users.addAll(result.docs
        .map((doc) => UserProfile.fromMap(doc.data() as Map<String, dynamic>, doc.id)));
    users.addAll(additionalResult.docs
        .map((doc) => UserProfile.fromMap(doc.data() as Map<String, dynamic>, doc.id)));
    users.addAll(emailResult.docs
        .map((doc) => UserProfile.fromMap(doc.data() as Map<String, dynamic>, doc.id)));

    return users;
  }
}

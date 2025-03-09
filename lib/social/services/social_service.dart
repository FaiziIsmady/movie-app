import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movie_app/profile/models/user_profile.dart';

class SocialService {
  // Query the users collection in Firestore based on the search query
  Future<List<UserProfile>> searchUsers(String query) async {
    final userCollection = FirebaseFirestore.instance.collection('users');

    // Perform queries for name, nickname, and email separately
    final resultName = await userCollection
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    final resultNickname = await userCollection
        .where('nickname', isGreaterThanOrEqualTo: query)
        .where('nickname', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    final resultEmail = await userCollection
        .where('email', isGreaterThanOrEqualTo: query)
        .where('email', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    // Combine all results from different fields (name, nickname, email)
    List<UserProfile> users = [];
    
    users.addAll(resultName.docs
        .map((doc) => UserProfile.fromMap(doc.data() as Map<String, dynamic>, doc.id)));

    users.addAll(resultNickname.docs
        .map((doc) => UserProfile.fromMap(doc.data() as Map<String, dynamic>, doc.id)));

    users.addAll(resultEmail.docs
        .map((doc) => UserProfile.fromMap(doc.data() as Map<String, dynamic>, doc.id)));

    // Remove duplicates based on email or userId since email is unique
    var uniqueUsers = <UserProfile>[];

    for (var user in users) {
      if (!uniqueUsers.any((u) => u.email == user.email)) {
        uniqueUsers.add(user);
      }
    }

    return uniqueUsers;
  }
}

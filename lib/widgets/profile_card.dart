import 'package:flutter/material.dart';
import 'package:movie_app/profile/models/user_profile.dart';

class ProfileCard extends StatelessWidget {
  final UserProfile userProfile;

  const ProfileCard({Key? key, required this.userProfile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(userProfile.profilePictureUrl),
        ),
        title: Text(userProfile.name),
        subtitle: Text(userProfile.email),
        onTap: () {
          // Show user profile details (not implemented yet)
        },
      ),
    );
  }
}

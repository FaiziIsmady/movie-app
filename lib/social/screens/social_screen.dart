import 'package:flutter/material.dart';
import 'package:movie_app/profile/models/user_profile.dart';
import 'package:movie_app/social/services/social_service.dart';
import 'package:movie_app/widgets/profile_card.dart';
import 'package:movie_app/utils/navigation_manager.dart';
import 'package:movie_app/widgets/app_scaffold.dart';
import 'package:provider/provider.dart';

class FriendActivityScreen extends StatefulWidget {
  const FriendActivityScreen({Key? key}) : super(key: key);

  @override
  _FriendActivityScreenState createState() => _FriendActivityScreenState();
}

class _FriendActivityScreenState extends State<FriendActivityScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SocialService _socialService = SocialService();
  List<UserProfile> _searchResults = [];

  void _searchUsers() async {
    if (_searchController.text.isNotEmpty) {
      final results = await _socialService.searchUsers(_searchController.text);
      setState(() {
        _searchResults = results;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Social',
      currentIndex: Provider.of<NavigationManager>(context).currentIndex,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Users',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                _searchUsers();
              },
            ),
            const SizedBox(height: 16),
            // Display search results
            Expanded(
              child: _searchResults.isEmpty
                  ? const Center(child: Text('No users found'))
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final userProfile = _searchResults[index];
                        return ProfileCard(userProfile: userProfile);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

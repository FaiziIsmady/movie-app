import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/profile/models/user_profile.dart';
import 'package:movie_app/profile/services/auth_service.dart';
import 'package:movie_app/profile/services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  final AuthService _authService = AuthService(); // Add AuthService
  UserProfile? _userProfile;
  bool _isLoading = true;
  bool _isEditing = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Controllers for editing
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _hobbiesController = TextEditingController();
  final TextEditingController _socialMediaController = TextEditingController();
  final TextEditingController _aboutMeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = _auth.currentUser;

    try {
      if (user == null) {
        throw Exception('User not logged in');
      }
      
      _userProfile = await _profileService.getUserProfile(user.uid);
      
      // Initialize controllers with current values
      _nameController.text = _userProfile?.name ?? '';
      _nicknameController.text = _userProfile?.nickname ?? '';
      _hobbiesController.text = _userProfile?.hobbies ?? '';
      _socialMediaController.text = _userProfile?.socialMedia ?? '';
      _aboutMeController.text = _userProfile?.aboutMe ?? ''; // Initialize About Me controller
      
    } catch (e) {
      print('Error loading profile: $e'); // For debugging
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
        // If profile is empty, go straight to edit mode
        if (_userProfile != null && 
            _userProfile!.name.isEmpty && 
            _userProfile!.nickname.isEmpty &&
            _userProfile!.hobbies.isEmpty &&
            _userProfile!.socialMedia.isEmpty &&
            _userProfile!.aboutMe.isEmpty) { // Include aboutMe in check
          _isEditing = true;
        }
      });
    }
  }
  
  Future<void> _saveProfile() async {
    if (_userProfile == null) return;
    
    final user = _auth.currentUser;
    if (user == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final updatedProfile = UserProfile(
        name: _nameController.text,
        email: _userProfile!.email,
        profilePictureUrl: _userProfile!.profilePictureUrl,
        nickname: _nicknameController.text,
        hobbies: _hobbiesController.text,
        socialMedia: _socialMediaController.text,
        aboutMe: _aboutMeController.text, // Include About Me field
      );
      
      await _profileService.updateUserProfile(updatedProfile, user.uid);
      _userProfile = updatedProfile;
      
      setState(() {
        _isEditing = false;
      });
    } catch (e) {
      // Handle error
      print('Error saving profile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Add logout method
  Future<void> _logout() async {
    try {
      await _authService.signOut();
      // No need to navigate - main.dart handles this via auth state
    } catch (e) {
      print('Error signing out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!_isLoading && _userProfile != null && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          // Add logout button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userProfile != null
              ? _buildProfileContent()
              : const Center(child: Text('User not found')),
    );
  }
  
  Widget _buildProfileContent() {
    if (_isEditing) {
      return _buildEditForm();
    } else {
      return _buildProfileDisplay();
    }
  }
  
  Widget _buildProfileDisplay() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile picture
          CircleAvatar(
            radius: 60,
            backgroundImage: _userProfile!.profilePictureUrl.isNotEmpty
                ? NetworkImage(_userProfile!.profilePictureUrl)
                : null,
            child: _userProfile!.profilePictureUrl.isEmpty
                ? const Icon(Icons.person, size: 60)
                : null,
          ),
          const SizedBox(height: 16),
          
          // Name
          Text(
            _userProfile!.name.isNotEmpty ? _userProfile!.name : 'No name provided',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          
          // Email
          Text(
            _userProfile!.email,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          // About Me section
          if (_userProfile!.aboutMe.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About Me',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _userProfile!.aboutMe,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          
          // Other details
          _buildInfoSection('Nickname', _userProfile!.nickname),
          _buildInfoSection('Hobbies', _userProfile!.hobbies),
          _buildInfoSection('Social Media', _userProfile!.socialMedia),
        ],
      ),
    );
  }
  
  Widget _buildInfoSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            content.isNotEmpty ? content : 'Not provided',
            style: TextStyle(
              fontSize: 16,
              color: content.isNotEmpty ? Colors.black : Colors.grey,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
  
  Widget _buildEditForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile picture (placeholder for now)
          Center(
            child: CircleAvatar(
              radius: 60,
              backgroundImage: _userProfile!.profilePictureUrl.isNotEmpty
                  ? NetworkImage(_userProfile!.profilePictureUrl)
                  : null,
              child: _userProfile!.profilePictureUrl.isEmpty
                  ? const Icon(Icons.person, size: 60)
                  : null,
            ),
          ),
          const SizedBox(height: 24),
          
          // Form fields
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _nicknameController,
            decoration: const InputDecoration(
              labelText: 'Nickname',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          
          // About Me field
          TextField(
            controller: _aboutMeController,
            decoration: const InputDecoration(
              labelText: 'About Me',
              border: OutlineInputBorder(),
              hintText: 'Tell us about yourself...',
            ),
            maxLines: 4, // Allow multiple lines for About Me
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _hobbiesController,
            decoration: const InputDecoration(
              labelText: 'Hobbies',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _socialMediaController,
            decoration: const InputDecoration(
              labelText: 'Social Media',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          
          // Save button
          ElevatedButton(
            onPressed: _saveProfile,
            child: const Text('Save Profile'),
          ),
          
          if (!_userProfile!.name.isEmpty && !_userProfile!.nickname.isEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = false;
                });
              },
              child: const Text('Cancel'),
            ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _hobbiesController.dispose();
    _socialMediaController.dispose();
    _aboutMeController.dispose();
    super.dispose();
  }
}
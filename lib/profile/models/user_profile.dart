class UserProfile {
  final String name;
  final String email;
  final String profilePictureUrl;
  final String nickname;
  final String hobbies;
  final String socialMedia;
  final String aboutMe;

  UserProfile({
    required this.name,
    required this.email,
    required this.profilePictureUrl,
    this.nickname = '',
    this.hobbies = '',
    this.socialMedia = '',
    this.aboutMe = '',
  });

    factory UserProfile.fromMap(Map<String, dynamic> data, String id) {
    return UserProfile(
      name: data['name'],
      email: data['email'],
      profilePictureUrl: data['profilePictureUrl'] ?? '',
      nickname: data['nickname'] ?? '',
      hobbies: data['hobbies'] ?? '',
      socialMedia: data['socialMedia'] ?? '',
      aboutMe: data['aboutMe'] ?? '',
    );
  }
}
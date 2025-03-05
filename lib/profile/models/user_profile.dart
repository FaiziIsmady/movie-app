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

  bool hasData() {
    return name.isNotEmpty || 
           nickname.isNotEmpty || 
           hobbies.isNotEmpty || 
           socialMedia.isNotEmpty ||
           aboutMe.isNotEmpty;
  }
}
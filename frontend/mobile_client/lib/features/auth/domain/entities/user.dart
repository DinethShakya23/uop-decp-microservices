class User {
  final int id;
  final String username;
  final String email;
  final String fullName;
  final String? bio;
  final String? profilePictureUrl;
  final String role;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    this.bio,
    this.profilePictureUrl,
    required this.role
  });
}
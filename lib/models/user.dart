/// User Model for Conven TV
/// -------------------------------------------------------------
/// Defines the structure for a user in the Conven TV app, including
/// authentication details and local language preference for recommendations.
/// -------------------------------------------------------------

class User {
  final String id;
  final String email;
  final String localLanguage;

  User({required this.id, required this.email, required this.localLanguage});

  // Factory constructor to create a User from Supabase response
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      email: map['email'] as String,
      localLanguage: map['local_language'] as String? ?? '',
    );
  }
}

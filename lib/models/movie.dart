/// Movie Model for Conven TV
/// -------------------------------------------------------------
/// Defines the structure for a movie in the Conven TV app, including
/// metadata for recommendations and playback.
/// -------------------------------------------------------------

class Movie {
  final String id;
  final String title;
  final String language;
  final String thumbnailUrl;
  final String videoUrl;

  Movie({
    required this.id,
    required this.title,
    required this.language,
    required this.thumbnailUrl,
    required this.videoUrl,
  });

  // Factory constructor to create a Movie from Supabase response
  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      id: map['id'] as String,
      title: map['title'] as String,
      language: map['language'] as String,
      thumbnailUrl: map['thumbnail_url'] as String,
      videoUrl: map['video_url'] as String,
    );
  }
}

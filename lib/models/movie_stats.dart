/// MovieStats Model for Conven TV
/// -------------------------------------------------------------
/// Defines the structure for movie statistics, including views,
/// searches, and watch history. Used for recommendations and
/// analytics in the app.
/// -------------------------------------------------------------

// ignore_for_file: dangling_library_doc_comments

class MovieStats {
  final String movieId;
  final int views;
  final int searches;
  final int watches;

  MovieStats({
    required this.movieId,
    required this.views,
    required this.searches,
    required this.watches,
  });

  factory MovieStats.fromMap(Map<String, dynamic> map) {
    return MovieStats(
      movieId: map['movie_id'] as String,
      views: map['views'] as int? ?? 0,
      searches: map['searches'] as int? ?? 0,
      watches: map['watches'] as int? ?? 0,
    );
  }
}

/// Supabase Service for Conven TV
/// -------------------------------------------------------------
/// Handles all Supabase API interactions, including authentication,
/// user profile management, and movie data fetching. Ensures security
/// and efficient queries as per project documentation.
/// -------------------------------------------------------------

// ignore_for_file: dangling_library_doc_comments

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as local;
import '../models/movie.dart';
// ignore: unused_import
import '../models/movie_stats.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  /// Fetch current user profile from Supabase
  Future<local.User?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final data = await _client
        .from('users')
        .select()
        .eq('id', user.id)
        .single();
    return local.User.fromMap(data);
  }

  /// Fetch movies, optionally filtered by language
  Future<List<Movie>> fetchMovies({String? language}) async {
    final query = _client.from('movies').select();
    if (language != null) {
      query.eq('language', language);
    }
    final data = await query;
    return (data as List).map((m) => Movie.fromMap(m)).toList();
  }

  /// Fetch most searched movies
  Future<List<Movie>> fetchMostSearchedMovies() async {
    // Assumes a 'movie_stats' table with 'searches' field
    final data = await _client
        .from('movie_stats')
        .select('movie_id, searches')
        .order('searches', ascending: false)
        .limit(10);
    final movieIds = (data as List)
        .map((m) => m['movie_id'] as String)
        .toList();
    if (movieIds.isEmpty) return [];
    final moviesData = await _client
        .from('movies')
        .select()
        .inFilter('id', movieIds);
    return (moviesData as List).map((m) => Movie.fromMap(m)).toList();
  }

  /// Fetch most popular movies (by views)
  Future<List<Movie>> fetchPopularMovies() async {
    final data = await _client
        .from('movie_stats')
        .select('movie_id, views')
        .order('views', ascending: false)
        .limit(10);
    final movieIds = (data as List)
        .map((m) => m['movie_id'] as String)
        .toList();
    if (movieIds.isEmpty) return [];
    final moviesData = await _client
        .from('movies')
        .select()
        .inFilter('id', movieIds);
    return (moviesData as List).map((m) => Movie.fromMap(m)).toList();
  }

  /// Fetch most watched movies
  Future<List<Movie>> fetchMostWatchedMovies() async {
    final data = await _client
        .from('movie_stats')
        .select('movie_id, watches')
        .order('watches', ascending: false)
        .limit(10);
    final movieIds = (data as List)
        .map((m) => m['movie_id'] as String)
        .toList();
    if (movieIds.isEmpty) return [];
    final moviesData = await _client
        .from('movies')
        .select()
        .inFilter('id', movieIds);
    return (moviesData as List).map((m) => Movie.fromMap(m)).toList();
  }

  /// Fetch user's watch history
  Future<List<Movie>> fetchUserHistory(String userId) async {
    // Assumes a 'watch_history' table with 'user_id' and 'movie_id'
    final data = await _client
        .from('watch_history')
        .select('movie_id')
        .eq('user_id', userId)
        .order('watched_at', ascending: false)
        .limit(10);
    final movieIds = (data as List)
        .map((m) => m['movie_id'] as String)
        .toList();
    if (movieIds.isEmpty) return [];
    final moviesData = await _client
        .from('movies')
        .select()
        .inFilter('id', movieIds);
    return (moviesData as List).map((m) => Movie.fromMap(m)).toList();
  }
}

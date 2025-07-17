/// HomeScreen for Conven TV
/// -------------------------------------------------------------
/// Displays a list of movies fetched from Supabase. Movies matching
/// the user's local language are recommended and highlighted. This
/// screen uses Riverpod for state management and SupabaseService for
/// backend queries. The UI is futuristic and orange-themed.
/// -------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/movie.dart';
import '../services/supabase_service.dart';
import 'movie_detail_screen.dart';
import 'section_carousel.dart';

// Provider for user's local language (from Supabase profile)
final localLanguageProvider = FutureProvider<String?>((ref) async {
  final user = await SupabaseService().getCurrentUser();
  return user?.localLanguage;
});

// Provider for movies list, with recommendations logic
final moviesProvider = FutureProvider<List<Movie>>((ref) async {
  final localLanguage = await ref.watch(localLanguageProvider.future);
  final movies = await SupabaseService().fetchMovies();
  movies.sort((a, b) {
    if (a.language == localLanguage && b.language != localLanguage) return -1;
    if (a.language != localLanguage && b.language == localLanguage) return 1;
    return 0;
  });
  return movies;
});

// Provider for most searched movies
final mostSearchedProvider = FutureProvider<List<Movie>>((ref) async {
  return SupabaseService().fetchMostSearchedMovies();
});

// Provider for most popular movies
final popularProvider = FutureProvider<List<Movie>>((ref) async {
  return SupabaseService().fetchPopularMovies();
});

// Provider for most watched movies
final mostWatchedProvider = FutureProvider<List<Movie>>((ref) async {
  return SupabaseService().fetchMostWatchedMovies();
});

// Provider for user watch history
final historyProvider = FutureProvider<List<Movie>>((ref) async {
  final user = await SupabaseService().getCurrentUser();
  if (user == null) return [];
  return SupabaseService().fetchUserHistory(user.id);
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moviesAsync = ref.watch(moviesProvider);
    final localLanguageAsync = ref.watch(localLanguageProvider);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Conven TV'),
        backgroundColor: Colors.orange,
      ),
      body: localLanguageAsync.when(
        data: (localLanguage) {
          return moviesAsync.when(
            data: (movies) {
              if (movies.isEmpty) {
                return const Center(
                  child: Text(
                    'No movies available.',
                    style: TextStyle(color: Colors.orangeAccent),
                  ),
                );
              }
              // Section: Recommended for you (local language)
              final recommended = movies
                  .where((m) => m.language == localLanguage)
                  .toList();
              final others = movies
                  .where((m) => m.language != localLanguage)
                  .toList();
              return ListView(
                children: [
                  // Netflix-style horizontal carousels for each section
                  SectionCarousel(
                    title: 'Recommended for You',
                    movies: recommended,
                    badge: 'Recommended',
                    badgeColor: Colors.orange,
                  ),
                  Consumer(
                    builder: (context, ref, _) {
                      final searchedAsync = ref.watch(mostSearchedProvider);
                      return searchedAsync.when(
                        data: (searched) => SectionCarousel(
                          title: 'Most Searched',
                          movies: searched,
                          badge: 'Trending',
                          badgeColor: Colors.redAccent,
                        ),
                        loading: () => const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                        error: (err, stack) => Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Error loading most searched: $err',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      );
                    },
                  ),
                  Consumer(
                    builder: (context, ref, _) {
                      final popularAsync = ref.watch(popularProvider);
                      return popularAsync.when(
                        data: (popular) => SectionCarousel(
                          title: 'Popular Movies',
                          movies: popular,
                          badge: 'Popular',
                          badgeColor: Colors.purpleAccent,
                        ),
                        loading: () => const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.purpleAccent,
                            ),
                          ),
                        ),
                        error: (err, stack) => Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Error loading popular: $err',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      );
                    },
                  ),
                  Consumer(
                    builder: (context, ref, _) {
                      final watchedAsync = ref.watch(mostWatchedProvider);
                      return watchedAsync.when(
                        data: (watched) => SectionCarousel(
                          title: 'Most Watched',
                          movies: watched,
                          badge: 'Watched',
                          badgeColor: Colors.blueAccent,
                        ),
                        loading: () => const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                        error: (err, stack) => Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Error loading most watched: $err',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      );
                    },
                  ),
                  Consumer(
                    builder: (context, ref, _) {
                      final historyAsync = ref.watch(historyProvider);
                      return historyAsync.when(
                        data: (history) => SectionCarousel(
                          title: 'Your Watch History',
                          movies: history,
                          badge: 'History',
                          badgeColor: Colors.greenAccent,
                        ),
                        loading: () => const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.greenAccent,
                            ),
                          ),
                        ),
                        error: (err, stack) => Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Error loading history: $err',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      );
                    },
                  ),
                  // Other movies (vertical list)
                  if (others.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Other Movies',
                        style: TextStyle(
                          color: Colors.orangeAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ...others.map(
                    (movie) => Card(
                      color: Colors.grey[900],
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: Image.network(
                          movie.thumbnailUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                        title: Text(
                          movie.title,
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Language: ${movie.language}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => MovieDetailScreen(movie: movie),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            ),
            error: (err, stack) => Center(
              child: Text(
                'Error loading movies: $err',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.orange),
        ),
        error: (err, stack) => Center(
          child: Text(
            'Error loading user profile: $err',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}

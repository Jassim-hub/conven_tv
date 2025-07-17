/// MovieDetailScreen for Conven TV
/// -------------------------------------------------------------
/// Displays detailed information about a selected movie, including
/// title, language, thumbnail, and video playback. The UI is
/// futuristic and orange-themed. Integrates with Supabase for
/// secure video streaming and user experience.
/// -------------------------------------------------------------

import 'package:flutter/material.dart';
import '../models/movie.dart';

class MovieDetailScreen extends StatelessWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text(movie.title), backgroundColor: Colors.orange),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.network(
                  movie.thumbnailUrl,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                movie.title,
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Language: ${movie.language}',
                style: const TextStyle(color: Colors.white70, fontSize: 18),
              ),
              const SizedBox(height: 24),
              // TODO: Integrate video player for movie.videoUrl
              Center(
                child: Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.orange.withOpacity(0.2),
                  child: const Center(
                    child: Text(
                      'Video player coming soon...',
                      style: TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movie_app/api_constants.dart';
import 'package:movie_app/movie/services/movie_service.dart';
import 'package:movie_app/widgets/app_scaffold.dart';

class MovieCastScreen extends StatefulWidget {
  final int movieId;

  const MovieCastScreen({Key? key, required this.movieId}) : super(key: key);

  @override
  State<MovieCastScreen> createState() => _MovieCastScreenState();
}

class _MovieCastScreenState extends State<MovieCastScreen> {
  final MovieService _movieService = MovieService();
  List<dynamic> _cast = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCast();
  }

  Future<void> _fetchCast() async {
    try {
      final cast = await _movieService.getMovieCredits(widget.movieId);
      if (mounted) {
        setState(() => _cast = cast);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading cast: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Cast',
      showBackButton: true,
      currentIndex: 0, // 0 for Movies tab
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cast.isEmpty
              ? const Center(child: Text('No cast information available'))
              : _buildCastGrid(),
    );
  }

  Widget _buildCastGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _cast.length,
      itemBuilder: (context, index) => _buildCastCard(_cast[index]),
    );
  }

  Widget _buildCastCard(Map<String, dynamic> actor) {
    final profilePath = actor['profile_path'];
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: _buildProfileImage(profilePath),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    actor['name'] ?? 'Unknown',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    actor['character'] ?? 'Unknown role',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(String? profilePath) {
    if (profilePath != null) {
      return CachedNetworkImage(
        imageUrl: '${ApiConstants.imageBaseUrl}$profilePath',
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => _buildDefaultProfileIcon(),
      );
    }
    return _buildDefaultProfileIcon();
  }

  Widget _buildDefaultProfileIcon() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.person, size: 50, color: Colors.grey),
    );
  }
}

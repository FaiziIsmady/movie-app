import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movie_app/api_constants.dart';
import 'package:movie_app/movie/services/movie_service.dart';
import 'package:movie_app/utils/navigation_manager.dart';
import 'package:movie_app/widgets/app_scaffold.dart';
import 'package:provider/provider.dart';

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
      currentIndex: Provider.of<NavigationManager>(context).currentIndex,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            // Removed expandedHeight to eliminate the gap
            pinned: true,
            title: const Text('Cast'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                final navManager = Provider.of<NavigationManager>(context, listen: false);
                navManager.exitCast();
              },
            ),
          ),
          _isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : _cast.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(child: Text('No cast information available')),
                    )
                  : SliverPadding(
                      // Reduced top padding to minimize gap
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildCastCard(_cast[index]),
                          childCount: _cast.length,
                        ),
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _buildCastCard(Map<String, dynamic> actor) {
    final profilePath = actor['profile_path'];
    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 4,
            child: _buildProfileImage(profilePath),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                const SizedBox(height: 2),
                Text(
                  actor['character'] ?? 'Unknown role',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
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
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).primaryColor,
          ),
        ),
        errorWidget: (context, url, error) => _buildDefaultProfileIcon(),
      );
    }
    return _buildDefaultProfileIcon();
  }

  Widget _buildDefaultProfileIcon() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.person, size: 50, color: Colors.grey),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:movie_app/api_constants.dart';
import 'package:movie_app/movie/models/movie.dart';
import 'package:movie_app/movie/services/movie_service.dart';
import 'package:movie_app/profile/screens/user_review_movie.dart';
import 'package:movie_app/utils/navigation_manager.dart';
import 'package:movie_app/widgets/app_scaffold.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen({Key? key, required this.movie}) : super(key: key);

  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final MovieService _movieService = MovieService();

  List _recommendations = [];
  List _videos = [];
  bool _isLoading = true;
  String? _director;

  @override
  void initState() {
    super.initState();
    _loadMovieDetails();
  }

  Future _loadMovieDetails() async {
    try {
      final recommendationsData = _movieService.getMovieRecommendations(widget.movie.id);
      final videosData = _movieService.getMovieVideos(widget.movie.id);
      final directorData = _movieService.getMovieDirector(widget.movie.id);

      final results = await Future.wait([recommendationsData, videosData, directorData]);

      setState(() {
        _recommendations = results[0] as List;
        _videos = results[1] as List;
        _director = results[2] as String?;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading movie details: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _getTrailerKey() {
    for (var video in _videos) {
      if (video['site'] == 'YouTube' && 
          (video['type'] == 'Trailer' || video['type'] == 'Teaser')) {
        return video['key'];
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: Provider.of<NavigationManager>(context).currentIndex,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                final navManager = Provider.of<NavigationManager>(context, listen: false);
                navManager.goBack();
              },
            ),
            // Add this flexibleSpace property here
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                'https://image.tmdb.org/t/p/w500${widget.movie.backdropPath}',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.movie.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        widget.movie.voteAverage.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Release Date: ${widget.movie.releaseDate}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  if (_director != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Director: $_director',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Text(
                    'Overview',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.movie.overview,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Provider.of<NavigationManager>(context, listen: false)
                            .showMovieCast(widget.movie.id);
                        },
                        child: const Text('Cast'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final trailerKey = _getTrailerKey();
                          if (trailerKey != null) {
                            final youtubeUrl = Uri.parse('https://www.youtube.com/watch?v=$trailerKey');
                            if (await canLaunchUrl(youtubeUrl)) {
                              await launchUrl(youtubeUrl, mode: LaunchMode.externalApplication);
                            } else {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Could not launch YouTube'),
                                  ),
                                );
                              }
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No trailer available for this movie'),
                              ),
                            );
                          }
                        },
                        child: const Text('Trailer'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserReviewMovieScreen(movieId: widget.movie.id.toString()),
                            ),
                          );
                        },
                        child: const Text('Add Review'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Movies Like This',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          height: 180,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _recommendations.length,
                            itemBuilder: (context, index) {
                              final recommendedMovie = _recommendations[index];
                              return GestureDetector(
                                onTap: () {
                                  Provider.of<NavigationManager>(context, listen: false)
                                      .showMovieDetails(recommendedMovie);
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                  width: 120,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        '${ApiConstants.imageBaseUrl}${recommendedMovie.posterPath}',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
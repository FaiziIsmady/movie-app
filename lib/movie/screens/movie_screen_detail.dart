import 'package:flutter/material.dart';
import 'package:movie_app/movie/screens/movie_cast.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';
import '../../api_constants.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen({Key? key, required this.movie}) : super(key: key);

  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final MovieService _movieService = MovieService();
  List _credits = [];
  List _recommendations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMovieDetails();
  }

  Future _loadMovieDetails() async {
    try {
      _credits = await _movieService.getMovieCredits(widget.movie.id);
      _recommendations = await _movieService.getMovieRecommendations(widget.movie.id);
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                '${ApiConstants.imageBaseUrl}${widget.movie.backdropPath}',
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MovieCastScreen(movieId: widget.movie.id),
                            ),
                          );
                        },
                        child: const Text('Cast'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to trailer
                        },
                        child: const Text('Trailer'),
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
                                  // Navigate to recommended movie details
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

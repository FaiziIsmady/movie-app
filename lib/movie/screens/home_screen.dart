import 'package:flutter/material.dart';
import 'package:movie_app/movie/models/movie.dart';
import 'package:movie_app/movie/services/movie_service.dart';
import 'package:movie_app/widgets/movie_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MovieService _movieService = MovieService();
  List<Movie> _popularMovies = [];
  List<Movie> _trendingMovies = [];
  List<Movie> _nowPlayingMovies = [];
  List<Movie> _topRatedMovies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    try {
      final popular = await _movieService.getPopularMovies();
      final trending = await _movieService.getTrendingMovies();
      final nowPlaying = await _movieService.getNowPlayingMovies();
      final topRated = await _movieService.getTopRatedMovies();

      setState(() {
        _popularMovies = popular;
        _trendingMovies = trending;
        _nowPlayingMovies = nowPlaying;
        _topRatedMovies = topRated;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading movies: $e')),
        );
      }
    }
  }

  Widget _buildMovieSection(String title, List<Movie> movies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 300,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              return SizedBox(
                width: 180,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: MovieCard(
                    movie: movies[index],
                    onTap: () {
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ReelsTek'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadMovies,
              child: ListView(
                children: [
                  _buildMovieSection('Popular Movies', _popularMovies),
                  const SizedBox(height: 16),
                  _buildMovieSection('Trending This Week', _trendingMovies),
                  const SizedBox(height: 16),
                  _buildMovieSection('Now Playing', _nowPlayingMovies),
                  const SizedBox(height: 16),
                  _buildMovieSection('Top Rated', _topRatedMovies),
                ],
              ),
            ),
    );
  }
}
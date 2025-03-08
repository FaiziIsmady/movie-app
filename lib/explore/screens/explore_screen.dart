import 'package:flutter/material.dart';
import 'package:movie_app/movie/models/movie.dart';
import 'package:movie_app/movie/screens/movie_screen_detail.dart';
import 'package:movie_app/movie/services/movie_service.dart';
import 'package:movie_app/widgets/app_scaffold.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final MovieService _movieService = MovieService();
  final TextEditingController _searchController = TextEditingController();
  List<Movie> _movies = [];
  bool _isLoading = false;
  String _selectedGenre = ''; // Genre filter

  // TMDB Genre IDs
  final Map<String, int> _genres = {
    'Action': 28,
    'Comedy': 35,
    'Drama': 18,
    'Thriller': 53,
  };

  @override
  void initState() {
    super.initState();
    _fetchTrendingMovies(); // Show trending movies by default
  }

  // Fetch movies by title search
  Future<void> _searchMovies(String query) async {
    if (query.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final movies = await _movieService.searchMovies(query);
      setState(() => _movies = movies);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }

    setState(() => _isLoading = false);
  }

  // Fetch movies by genre
  Future<void> _fetchMoviesByGenre(int genreId) async {
    setState(() => _isLoading = true);

    try {
      final movies = await _movieService.getMoviesByGenre(genreId);
      setState(() => _movies = movies);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }

    setState(() => _isLoading = false);
  }

  // Fetch trending movies for default view
  Future<void> _fetchTrendingMovies() async {
    setState(() => _isLoading = true);

    try {
      final movies = await _movieService.getTrendingMovies();
      setState(() => _movies = movies);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Explore',
      currentIndex: 1, // 0 for Movies tab
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            // Your action here
          },
        ),
      ],
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onSubmitted: _searchMovies,
              decoration: InputDecoration(
                hintText: 'Search for movies...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _fetchTrendingMovies(); // Reset to trending movies
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          // Genre Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _genres.keys.map((genre) {
                final isSelected = _selectedGenre == genre;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(genre),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedGenre = selected ? genre : '');
                      if (selected) {
                        _fetchMoviesByGenre(_genres[genre]!);
                      } else {
                        _fetchTrendingMovies();
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          // Movie List/Grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _movies.isEmpty
                    ? const Center(child: Text('No movies found.'))
                    : GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _movies.length,
                        itemBuilder: (context, index) {
                          final movie = _movies[index];
                          return GestureDetector(
                            onTap: () => {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MovieDetailScreen(movie: movie),
                                ),
                              ),
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Image.network(
                                    'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Text(movie.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

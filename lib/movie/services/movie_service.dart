import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movie_app/api_constants.dart';
import 'package:movie_app/movie/models/movie.dart';

class MovieService {
  Future<List<Movie>> getPopularMovies() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/movie/popular?api_key=${ApiConstants.apiKey}'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return (data['results'] as List)
          .map((movieData) => Movie.fromJson(movieData))
          .toList();
    } else {
      throw Exception('Failed to load popular movies');
    }
  }

  Future<List<Movie>> getTrendingMovies() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/trending/movie/week?api_key=${ApiConstants.apiKey}'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return (data['results'] as List)
          .map((movieData) => Movie.fromJson(movieData))
          .toList();
    } else {
      throw Exception('Failed to load trending movies');
    }
  }

  Future<List<Movie>> getNowPlayingMovies() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/movie/now_playing?api_key=${ApiConstants.apiKey}'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return (data['results'] as List)
          .map((movieData) => Movie.fromJson(movieData))
          .toList();
    } else {
      throw Exception('Failed to load now playing movies');
    }
  }

  Future<List<Movie>> getTopRatedMovies() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/movie/top_rated?api_key=${ApiConstants.apiKey}'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return (data['results'] as List)
          .map((movieData) => Movie.fromJson(movieData))
          .toList();
    } else {
      throw Exception('Failed to load top rated movies');
    }
  }

  Future<Movie> getMovieDetails(int movieId) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/movie/$movieId?api_key=${ApiConstants.apiKey}'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Movie.fromJson(data);
    } else {
      throw Exception('Failed to load movie details');
    }
  }

  Future<List<dynamic>> getMovieCredits(int movieId) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/movie/$movieId/credits?api_key=${ApiConstants.apiKey}'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['cast'];
    } else {
      throw Exception('Failed to load movie credits');
    }
  }

  Future<List<Movie>> getMovieRecommendations(int movieId) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/movie/$movieId/recommendations?api_key=${ApiConstants.apiKey}'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return (data['results'] as List)
          .map((movieData) => Movie.fromJson(movieData))
          .toList();
    } else {
      throw Exception('Failed to load movie recommendations');
    }
  }

  Future<List<dynamic>> getMovieReviews(int movieId) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/movie/$movieId/reviews?api_key=${ApiConstants.apiKey}'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['results']; // Return the reviews list
    } else {
      throw Exception('Failed to load movie reviews');
    }
  }

  Future<List<dynamic>> getMovieVideos(int movieId) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/movie/$movieId/videos?api_key=${ApiConstants.apiKey}'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['results']; // Return the videos list
    } else {
      throw Exception('Failed to load movie videos');
    }
  }

  Future<String?> getMovieDirector(int movieId) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/movie/$movieId/credits?api_key=${ApiConstants.apiKey}'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      
      // Find the director in the crew list
      final director = (data['crew'] as List)
          .firstWhere(
            (crewMember) => crewMember['job'] == 'Director',
            orElse: () => null,
          );

      return director?['name']; // Return director's name if found
    } else {
      throw Exception('Failed to load movie director');
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/search/movie?api_key=${ApiConstants.apiKey}&query=$query'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List).map((movieData) => Movie.fromJson(movieData)).toList();
    } else {
      throw Exception('Failed to search movies');
    }
  }

  Future<List<Movie>> getMoviesByGenre(int genreId) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/discover/movie?api_key=${ApiConstants.apiKey}&with_genres=$genreId'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List).map((movieData) => Movie.fromJson(movieData)).toList();
    } else {
      throw Exception('Failed to fetch movies by genre');
    }
  }

  Future<List<Movie>> getUpcomingMovies() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/movie/upcoming?api_key=${ApiConstants.apiKey}'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return (data['results'] as List)
          .map((movieData) => Movie.fromJson(movieData))
          .toList();
    } else {
      throw Exception('Failed to load upcoming movies');
    }
  }
}
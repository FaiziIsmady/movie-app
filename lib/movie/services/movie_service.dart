import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';
import '/api_constants.dart';

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
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movie_app/api_constants.dart';
import 'package:movie_app/movie/models/movie.dart';

class MovieService {
  // Search Movies by Title
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

  // Get Movies by Genre
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
}
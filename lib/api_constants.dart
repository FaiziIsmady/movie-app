import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static String apiKey = dotenv.env['TMDB_API_KEY'] ??'';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
}
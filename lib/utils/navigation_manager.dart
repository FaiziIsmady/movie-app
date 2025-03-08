import 'package:flutter/material.dart';
import 'package:movie_app/movie/screens/home_screen.dart';
import 'package:movie_app/explore/screens/explore_screen.dart';
import 'package:movie_app/movie/screens/movie_cast.dart';
import 'package:movie_app/movie/screens/movie_screen_detail.dart';
import 'package:movie_app/social/screens/social_screen.dart';
import 'package:movie_app/profile/screens/profile_screen.dart';
import 'package:movie_app/movie/models/movie.dart';
class NavigationManager with ChangeNotifier {
  int _currentIndex = 0;
  Movie? _selectedMovie;
  final List<Movie?> _movieHistory = [];

  int? _currentMovieIdForCast;
  Movie? _movieForCast; // Add this to store the movie for cast
  bool _showingCast = false;

  int get currentIndex => _currentIndex;
  Movie? get selectedMovie => _selectedMovie;
  bool get showingCast => _showingCast;
  int? get currentMovieIdForCast => _currentMovieIdForCast;

  void setIndex(int index) {
    // If we're showing cast, exit cast view first
    if (_showingCast) {
      _showingCast = false;
      // If we had a movie for cast, restore it as selected movie
      if (_movieForCast != null) {
        _selectedMovie = _movieForCast;
        _movieForCast = null;
      }
    }
    
    _currentIndex = index;
    _selectedMovie = null;
    _movieHistory.clear();
    notifyListeners();
  }

  void showMovieDetails(Movie movie) {
    if (_selectedMovie != null) {
      _movieHistory.add(_selectedMovie);
    }
    _selectedMovie = movie;
    notifyListeners();
  }

  void goBack() {
    if (_movieHistory.isNotEmpty) {
      _selectedMovie = _movieHistory.removeLast();
      notifyListeners();
    } else {
      _selectedMovie = null;
      notifyListeners();
    }
  }

  void showMovieCast(int movieId) {
    _currentMovieIdForCast = movieId;
    // Store the current movie before showing cast
    _movieForCast = _selectedMovie;
    _showingCast = true;
    notifyListeners();
  }

  void exitCast() {
    _showingCast = false;
    // Restore the movie that was being viewed
    if (_movieForCast != null) {
      _selectedMovie = _movieForCast;
      _movieForCast = null;
    }
    notifyListeners();
  }

  Widget getCurrentScreen() {
    if (_showingCast && _currentMovieIdForCast != null) {
      return MovieCastScreen(movieId: _currentMovieIdForCast!);
    }

    if (_selectedMovie != null) {
      return MovieDetailScreen(movie: _selectedMovie!);
    }

    switch (_currentIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        return const ExploreScreen();
      case 2:
        return const FriendActivityScreen();
      case 3:
        return const ProfileScreen();
      default:
        return const HomeScreen();
    }
  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/profile/models/user_review.dart';
import 'package:movie_app/profile/services/profile_service.dart';
import 'package:movie_app/movie/services/movie_service.dart';
import 'package:provider/provider.dart';

class UserReviewMovieScreen extends StatefulWidget {
  final String movieId;

  const UserReviewMovieScreen({Key? key, required this.movieId}) : super(key: key);

  @override
  _UserReviewMovieScreenState createState() => _UserReviewMovieScreenState();
}

class _UserReviewMovieScreenState extends State<UserReviewMovieScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reviewController = TextEditingController();
  double _rating = 3.0;
  bool _isSubmitting = false;
  late Future<Map<String, String>> _movieDetailsFuture;

  @override
  void initState() {
    super.initState();
    // Fetch movie details based on movieId
    _movieDetailsFuture = _fetchMovieDetails(widget.movieId);
  }

  // Fetch movie details (including poster)
  Future<Map<String, String>> _fetchMovieDetails(String movieId) async {
    try {
      final movie = await MovieService().getMovieDetails(int.parse(movieId));
      return {
        'title': movie.title,
        'posterPath': movie.posterPath,
      };
    } catch (e) {
      return {'title': 'Unknown Movie', 'posterPath': ''};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Review'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            FutureBuilder<Map<String, String>>(
              future: _movieDetailsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final movieDetails = snapshot.data!;
                  return Column(
                    children: [
                      // Display the movie poster and title
                      if (movieDetails['posterPath'] != null && movieDetails['posterPath']!.isNotEmpty)
                        Image.network(
                          'https://image.tmdb.org/t/p/w500${movieDetails['posterPath']}',
                          width: 150,
                          height: 225,
                          fit: BoxFit.cover,
                        ),
                      const SizedBox(height: 8),
                      Text(
                        movieDetails['title'] ?? 'Unknown Movie',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }
              },
            ),
            // Review text field
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _reviewController,
                decoration: const InputDecoration(
                  labelText: 'Your Review',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your review';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            // Rating slider
            Text('Rating: ${_rating.toStringAsFixed(1)}'),
            Slider(
              value: _rating,
              min: 1,
              max: 5,
              divisions: 4,
              onChanged: (value) {
                setState(() {
                  _rating = value;
                });
              },
            ),
            const SizedBox(height: 16),
            // Submit button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReview,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReview() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw Exception('User not logged in');
        }

        final review = Review(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          movieId: widget.movieId,
          userId: user.uid,
          userName: user.displayName ?? 'Anonymous',
          reviewText: _reviewController.text,
          rating: _rating,
          createdAt: DateTime.now(),
        );

        final profileService = Provider.of<ProfileService>(context, listen: false);
        await profileService.addReview(review);

        Navigator.pop(context);
      } catch (e) {
        print('Error submitting review: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit review: $e')),
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }
}

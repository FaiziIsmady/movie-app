import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/profile/models/user_review.dart';
import 'package:movie_app/profile/services/profile_service.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Review'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
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
              const SizedBox(height: 16),
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
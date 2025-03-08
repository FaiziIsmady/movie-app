import 'package:flutter/material.dart';
import 'package:movie_app/profile/models/user_review.dart';
import 'package:movie_app/profile/services/profile_service.dart';
import 'package:provider/provider.dart';

class EditReviewScreen extends StatefulWidget {
  final Review review;

  const EditReviewScreen({Key? key, required this.review}) : super(key: key);

  @override
  _EditReviewScreenState createState() => _EditReviewScreenState();
}

class _EditReviewScreenState extends State<EditReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _reviewController;
  late double _rating;

  @override
  void initState() {
    super.initState();
    _reviewController = TextEditingController(text: widget.review.reviewText);
    _rating = widget.review.rating;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Review'),
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
                onPressed: _updateReview,
                child: const Text('Update Review'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateReview() async {
    if (_formKey.currentState!.validate()) {
      final updatedReview = Review(
        id: widget.review.id,
        movieId: widget.review.movieId,
        userId: widget.review.userId,
        userName: widget.review.userName,
        reviewText: _reviewController.text,
        rating: _rating,
        createdAt: widget.review.createdAt,
        updatedAt: DateTime.now(),
      );

      final profileService = Provider.of<ProfileService>(context, listen: false);
      await profileService.updateReview(updatedReview);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }
}
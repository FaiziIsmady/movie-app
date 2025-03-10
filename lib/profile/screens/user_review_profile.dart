import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/profile/models/user_review.dart';
import 'package:movie_app/profile/screens/edit_review_screen.dart';
import 'package:movie_app/profile/services/profile_service.dart';
import 'package:movie_app/movie/services/movie_service.dart';
import 'package:movie_app/utils/navigation_manager.dart';
import 'package:provider/provider.dart';
import 'package:movie_app/widgets/app_scaffold.dart';

class UserReviewProfileScreen extends StatefulWidget {
  const UserReviewProfileScreen({Key? key}) : super(key: key);

  @override
  _UserReviewProfileScreenState createState() =>
      _UserReviewProfileScreenState();
}

class _UserReviewProfileScreenState extends State<UserReviewProfileScreen> {
  late Future<List<Review>> _reviewsFuture;
  final MovieService _movieService = MovieService();

  @override
  void initState() {
    super.initState();
    _reviewsFuture = _loadReviews();
  }

  Future<List<Review>> _loadReviews() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    final profileService = Provider.of<ProfileService>(context, listen: false);
    return profileService.getUserReviews(user.uid);
  }

  Future<Map<String, String>> _getMovieDetails(String movieId) async {
    try {
      final movie = await _movieService.getMovieDetails(int.parse(movieId));
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
    return AppScaffold(
      currentIndex: Provider.of<NavigationManager>(context).currentIndex,
      title: 'My Reviews',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text(''),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Review>>(
              future: _reviewsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No reviews found'));
                }

                final reviews = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviews[index];

                    return FutureBuilder<Map<String, String>>(
                      future: _getMovieDetails(review.movieId),
                      builder: (context, movieSnapshot) {
                        if (movieSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (movieSnapshot.hasError) {
                          return const Center(child: Text('Error loading movie details'));
                        } else {
                          final movieDetails = movieSnapshot.data ?? {'title': 'Unknown Movie', 'posterPath': ''};
                          return Card(
                            child: ListTile(
                              title: Text('Rating: ${review.rating}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Movie: ${movieDetails['title']}'),
                                  const SizedBox(height: 4),
                                  Text('Review: ${review.reviewText}'),
                                ],
                              ),
                              leading: movieDetails['posterPath']!.isNotEmpty
                                  ? Image.network(
                                      'https://image.tmdb.org/t/p/w500${movieDetails['posterPath']}',
                                      width: 50,
                                      height: 75,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(Icons.movie, size: 50), 
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _editReview(review),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _deleteReview(review.id),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _editReview(Review review) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditReviewScreen(review: review),
      ),
    ).then((_) {
      setState(() {
        _reviewsFuture = _loadReviews();
      });
    });
  }

  Future<void> _deleteReview(String reviewId) async {
    final profileService = Provider.of<ProfileService>(context, listen: false);
    await profileService.deleteReview(reviewId);
    setState(() {
      _reviewsFuture = _loadReviews();
    });
  }
}

import 'package:flutter/material.dart';
import 'package:movie_app/api_constants.dart';
import 'package:movie_app/movie/models/movie.dart';
import 'package:movie_app/utils/navigation_manager.dart';
import 'package:provider/provider.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;

  const MovieCard({
    Key? key,
    required this.movie,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
          Provider.of<NavigationManager>(context, listen: false)
          .showMovieDetails(movie);
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                '${ApiConstants.imageBaseUrl}${movie.posterPath}',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  );
                },
              ),
            ),
        ),
    );
  }
}
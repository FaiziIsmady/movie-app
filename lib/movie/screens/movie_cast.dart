import 'package:flutter/material.dart';
import '../services/movie_service.dart';
import '../models/movie.dart';
import '../../api_constants.dart';

class MovieCastScreen extends StatefulWidget {
  final int movieId;

  const MovieCastScreen({Key? key, required this.movieId}) : super(key: key);

  @override
  _MovieCastScreenState createState() => _MovieCastScreenState();
}

class _MovieCastScreenState extends State<MovieCastScreen> {
  final MovieService _movieService = MovieService();
  List<dynamic> _cast = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCast();
  }

  Future<void> _loadCast() async {
    try {
      _cast = await _movieService.getMovieCredits(widget.movieId);
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cast'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _cast.length,
              itemBuilder: (context, index) {
                final actor = _cast[index];
                return ListTile(
                  title: Text(actor['name']),
                  subtitle: Text(actor['character']),
                );
              },
            ),
    );
  }
}

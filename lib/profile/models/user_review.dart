import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String movieId;
  final String userId;
  final String userName;
  final String reviewText;
  final double rating;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Review({
    required this.id,
    required this.movieId,
    required this.userId,
    required this.userName,
    required this.reviewText,
    required this.rating,
    required this.createdAt,
    this.updatedAt,
  });

  factory Review.fromMap(Map<String, dynamic> data, String id) {
    return Review(
      id: id,
      movieId: data['movieId'],
      userId: data['userId'],
      userName: data['userName'],
      reviewText: data['reviewText'],
      rating: data['rating'].toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'movieId': movieId,
      'userId': userId,
      'userName': userName,
      'reviewText': reviewText,
      'rating': rating,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}
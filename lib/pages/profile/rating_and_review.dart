import 'package:flutter/material.dart';

class RatingAndReview extends StatelessWidget {
  final double rating;
  final List<String> reviews;

  const RatingAndReview(
      {super.key, required this.rating, required this.reviews});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Rating: $rating',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const Text('Reviews:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ...reviews.map((service) => ListTile(title: Text(service))),
      ],
    );
  }
}

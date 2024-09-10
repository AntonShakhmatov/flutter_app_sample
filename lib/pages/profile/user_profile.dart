import 'package:flutter/material.dart';
import 'package:munacha_app/pages/profile/user_info.dart' as local;
import 'package:munacha_app/pages/profile/profile_screen.dart';
import 'service_list.dart';
import 'rating_and_review.dart';

class UserProfile extends StatelessWidget {
  final ProfileScreen user;

  const UserProfile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Логика редактирования профиля
            },
          ),
        ],
      ),
      //UserInfo(name: user.name, surname: user.surname, email: user.email, photoUrl: user.photoUrl),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            local.UserInfo(
                name: user.name,
                surname: user.surname,
                email: user.email,
                phone: user.phone,
                photoUrl: user.photoUrl),
            ServiceList(services: user.services),
            RatingAndReview(rating: user.rating, reviews: user.reviews),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

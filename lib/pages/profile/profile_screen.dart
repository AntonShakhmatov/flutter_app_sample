import 'package:flutter/material.dart';
import 'rating_and_review.dart';
import 'service_list.dart';
import 'user_info.dart';
import 'database/get/get_data.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Widget _title() {
    return const Text('Cabinet');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
      ),
      body: FutureBuilder<Map<String, String?>>(
        future: _getProfileData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final String? name = snapshot.data?['name'];
            final String? surname = snapshot.data?['surname'];
            final String? email = snapshot.data?['email'];
            final String? phone = snapshot.data?['phone'];

            return Padding(
              padding: const EdgeInsets.all(50.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserInfo(
                      name: name ?? 'No name available',
                      surname: surname ?? 'No surname available',
                      email: email ?? 'No email available',
                      phone: phone ?? 'No phone available',
                      photoUrl: 'URL',
                    ),
                    const SizedBox(height: 20),
                    const ServiceList(services: []),
                    const SizedBox(height: 20),
                    const RatingAndReview(rating: 0.0, reviews: []),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  Future<Map<String, String?>> _getProfileData() async {
    final String name = await GetData().getName();
    final String surname = await GetData().getSurname();
    final String email = await GetData().getEmail();
    final String phone = await GetData().getPhone();

    return {'name': name, 'surname': surname, 'email': email, 'phone': phone};
  }
}

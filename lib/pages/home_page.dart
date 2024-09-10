import 'package:firebase_auth/firebase_auth.dart';
import 'package:munacha_app/auth.dart';
import 'package:flutter/material.dart';
import 'map/google_map.dart';
import 'profile/profile_screen.dart';
import 'profile/users/users.dart';
import 'components/my_list_title.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final User? user = Auth().currentUser;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget _title() {
    return const Text('Choose your destiny');
  }

  Widget _signOutButton() {
    return SizedBox(
      width: 200,
      child: ElevatedButton(
        onPressed: signOut,
        child: const Row(
          children: [
            Icon(Icons.person, size: 25, color: Colors.grey),
            SizedBox(width: 10),
            Text(
              'Sign Out',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 25),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileScreen() {
    return const ProfileScreen();
  }

  Widget _usersScreen() {
    return const Users();
  }

  Widget _homePage() {
    return const MapSample();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
      ),
      drawer: Drawer(
        backgroundColor: Colors.grey[900],
        child: ListView(
          children: [
            const DrawerHeader(
              child: Icon(
                Icons.settings,
                color: Colors.white,
                size: 64,
              ),
            ),
            MyListTitle(
              icon: Icons.person,
              text: "P R O F I L E",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => _profileScreen()),
                );
              },
            ),
            MyListTitle(
              icon: Icons.people,
              text: "U S E R S",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => _usersScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: _homePage(),
            ),
            _signOutButton(),
          ],
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GetData {
  // FirebaseAuth во Flutter отвечает за управление аутентификацией пользователей в приложении
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser =>
      _firebaseAuth.currentUser; // Получение текущего пользователя

  getUserId() {
    User? user = _firebaseAuth.currentUser; // Получение текущего пользователя
    if (user != null) {
      String uid = user.uid;
      return uid;
    }
  }

  getEmail() async {
    var uid = getUserId();
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists) {
      String? email = userDoc['email'];
      return email;
    } else {
      return null;
    }
  }

  getName() async {
    var uid = getUserId();
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists) {
      String? name = userDoc['name'];
      return name;
    } else {
      return null;
    }
  }

  updateName() async {
    var uid = getUserId();
    final TextEditingController nameController = TextEditingController();
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists) {
      String? name = userDoc['name'];

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': nameController,
      });
      return nameController;
    } else {
      return null;
    }
  }

  getSurname() async {
    var uid = getUserId();
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists) {
      String? surname = userDoc['surname'];
      return surname;
    } else {
      return null;
    }
  }

  updateSurname() async {
    var uid = getUserId();
    final TextEditingController surnameController = TextEditingController();
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists) {
      String? surname = userDoc['surname'];

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'surname': surnameController,
      });
      return surnameController;
    } else {
      return null;
    }
  }

  getPhone() async {
    var uid = getUserId();
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists) {
      String? phone = userDoc['phone'];
      return phone;
    } else {
      return null;
    }
  }

  updatePhone() async {
    var uid = getUserId();
    final TextEditingController phoneController = TextEditingController();
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists) {
      String? phone = userDoc['phone'];

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'phone': phoneController,
      });

      return phoneController;
    } else {
      return null;
    }
  }

  getPhotoUrl() async {
    var uid = getUserId();
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists) {
      String? photoUrl = userDoc['photoUrl'];
      return photoUrl;
    } else {
      return null;
    }
  }

  updatePhotoUrl() async {
    var uid = getUserId();
    final TextEditingController photoUrlController = TextEditingController();
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists) {
      String? photoUrl = userDoc['photoUrl'];

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'photoUrl': photoUrlController,
      });

      return photoUrlController;
    } else {
      return null;
    }
  }
}

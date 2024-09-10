import 'package:firebase_auth/firebase_auth.dart';

// Загружаем нужные для нас функции из firebase_auth

class Auth {
  // FirebaseAuth во Flutter отвечает за управление аутентификацией пользователей в приложении
  final FirebaseAuth _firebaseAuth = FirebaseAuth
      .instance; // FirebaseAuth.instance отвечает за создание и предоставление единственного экземпляра (singleton instance) класса FirebaseAuth

  User? get currentUser =>
      _firebaseAuth.currentUser; // Получение текущего пользователя

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Эта строка кода отвечает за создание потока (Stream), который будет уведомлять о любых изменениях в состоянии аутентификации пользователя.
// Поток будет возвращать объект User?, представляющий текущего аутентифицированного пользователя, или null, если пользователь вышел из системы.

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  getUserId() {
    User? user = _firebaseAuth.currentUser; // Получение текущего пользователя
    if (user != null) {
      String uid = user.uid;
      return uid;
    }
  }

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> getCurrentUserId() async {}

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}

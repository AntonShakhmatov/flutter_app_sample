import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Users extends StatefulWidget {
  // final String name;

  const Users({
    super.key,
    // required this.name,
  });

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {
  // late String name;
  String? _imagePath;
  File? _imgFile;
  String? appDocPath;

  @override
  void initState() {
    // name = widget.name;
    // Последовательное выполнение асинхронных методов
    _getAppDocPath().then((_) {
      loadImage();
    });
  }

  Widget _title() {
    return const Text('Users');
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    // Получаем все документы из коллекции 'users'
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    // Преобразуем список документов в список Map<String, dynamic>
    var users = querySnapshot.docs
        .map((doc) => doc.data()) // Получаем данные каждого документа
        .toList();

    return users;
  }

  Future<List<String>> getUsersId() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();// Получаем все документы из коллекции 'users'

    // Извлечение поля 'uid' из каждого документа(doc)
    List<String> userUIDs = querySnapshot.docs
        .map((doc) =>
            doc.data()['uid'] as String)
        .toList();

    return userUIDs;
  }

  // Пути к директории приложения
  Future<void> _getAppDocPath() async {
    final directory = await getApplicationDocumentsDirectory();
    setState(() {
      appDocPath = directory.path;
    });
  }

  // Загрузка пути изображения из SharedPreferences
  Future<void> loadImage() async {
    var uid = getUsersId();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = 'user_image_path_$uid';
    String? path = prefs.getString(key);
    setState(() {
      var _imagePath = path;
    });
  }

  // Сохранение пути изображения в SharedPreferences
  Future<void> saveImage(String path) async {
    var uid = getUsersId();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = 'user_image_path_$uid';
    await prefs.setString(key, path);
  }

  // Возвращает URL зображения на Firestore
  Future<String> getAvatarUrl(String userId) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc['avatarUrl'] ?? '';
  }

  // Выбор и сохранение изображения
  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? img = await picker.pickImage(
      source: source,
      maxWidth: 400,
    );
    if (img == null) return;

    File selectedImage = File(img.path);

    // Проверка существования директории
    final directory = Directory('${appDocPath}/images/app');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    var uid = getUsersId();
    String filePath = '${appDocPath}/images/app/_$uid.jpg';
    File localImage = await selectedImage.copy(filePath);

    setState(() {
      _imgFile = localImage;
      _imagePath = filePath;
    });

    await saveImage(filePath);
  }

  @override
  Widget build(BuildContext context) {
    var uid = getUsersId();
    ImageProvider backgroundImage;
    if (_imagePath != null && File(_imagePath!).existsSync()) {
      backgroundImage = FileImage(File(_imagePath!));
    } else if (_imgFile != null) {
      // } else {
      backgroundImage = FileImage(_imgFile!);
    } else {
      backgroundImage = AssetImage("assets/images/app/$uid.jpg");
    }

    return Scaffold(
      appBar: AppBar(
        title: _title(),
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text("No users"));
          } else {
            var users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                var userData = users[index];
                String userId = userData['uid'];
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      FutureBuilder<String>(
                        future: getAvatarUrl(userId),
                        builder: (context, avatarSnapshot) {
                          if (avatarSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircleAvatar(
                              radius: 25,
                              backgroundImage: backgroundImage,
                              backgroundColor: Colors.grey,
                            );
                          } else if (avatarSnapshot.hasError ||
                              !avatarSnapshot.hasData) {
                            return CircleAvatar(
                              radius: 25,
                              backgroundImage: backgroundImage,
                              backgroundColor: Colors.grey,
                            );
                          } else {
                            String avatarPath = avatarSnapshot.data!;

                            // Проверка, является ли путь локальным файлом или URL-адресом
                            ImageProvider imageProvider;
                            if (avatarPath.startsWith('http')) {
                              imageProvider = NetworkImage(avatarPath);
                            } else {
                              imageProvider = FileImage(File(avatarPath));
                            }

                            return CircleAvatar(
                              radius: 25,
                              backgroundImage: imageProvider,
                              backgroundColor: Colors.black,
                            );
                          }
                        },
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        // Expanded
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.blueAccent,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueAccent.withOpacity(0.6),
                                offset: Offset(4, 4),
                                blurRadius: 4,
                              ),
                              BoxShadow(
                                color: Colors.white,
                                offset: Offset(-4, -4),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Text(
                            'Name: ${userData['name'] ?? 'No Name'} ' +
                                '${userData['surname'] ?? 'No Surname'},\n' +
                                'Phone: ${userData['phone'] ?? 'No Phone'},\n' +
                                'Mail: ${userData['email'] ?? 'No Email'}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              shadows: [
                                Shadow(
                                  offset: Offset(-1.5, -1.5),
                                  color: Colors.grey[700]!,
                                  blurRadius: 2,
                                ),
                                Shadow(
                                  offset: Offset(1.5, 1.5),
                                  color: Colors.white,
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

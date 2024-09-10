import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:munacha_app/pages/profile/database/get/get_data.dart';
import 'package:munacha_app/auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class UserInfo extends StatefulWidget {
  final String name;
  final String surname;
  final String email;
  final String phone;
  final String photoUrl;

  const UserInfo({
    super.key,
    required this.name,
    required this.surname,
    required this.email,
    required this.phone,
    required this.photoUrl,
  });

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  late String name;
  late String surname;
  late String email;
  late String phone;
  late String photoUrl;
  String? _imagePath;
  File? _imgFile;
  String? appDocPath;

  @override
  void initState() {
    super.initState();
    name = widget.name;
    surname = widget.surname;
    email = widget.email;
    phone = widget.phone;
    photoUrl = widget.photoUrl;

    // Последовательное выполнение асинхронных методов
    _getAppDocPath().then((_) {
      loadImage();
    });
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

  // Получение пути к директории приложения
  Future<void> _getAppDocPath() async {
    final directory = await getApplicationDocumentsDirectory();
    setState(() {
      appDocPath = directory.path;
    });
  }

  // Загрузка пути изображения из SharedPreferences
  Future<void> loadImage() async {
    var uid = GetData().getUserId();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = 'user_image_path_$uid';
    String? path = prefs.getString(key);
    setState(() {
      _imagePath = path;
    });
  }

  Future<String> uploadImageToFirebase(String filePath) async {
    File file = File(filePath);
    try {
      // Загружаем изображение в Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('avatars/${filePath.split('/').last}');
      final uploadTask = storageRef.putFile(file);

      // Ждём завершения загрузки
      await uploadTask;

      // Получаем публичный URL для доступа к изображению
      final String downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Ошибка загрузки изображения: $e');
      return '';
    }
  }

  Future<String> getAvatarUrl(String userId) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc['avatarUrl'] ?? ''; // Возвращаем URL или пустую строку
  }

  // Сохранение пути изображения в SharedPreferences
  Future<void> saveImage(String path) async {
    var uid = GetData().getUserId();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = 'user_image_path_$uid';
    await prefs.setString(key, path);
  }

  Future<void> saveUserProfile(String imageUrl) async {
    String userId = Auth().getUserId();
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'avatarUrl': imageUrl,
    });
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

    // Убедимся, что директория существует
    final directory = Directory('${appDocPath}/images/app');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    String uid = GetData().getUserId();
    String filePath = '${appDocPath}/images/app/${widget.name}_$uid.jpg';
    File localImage = await selectedImage.copy(filePath);

    setState(() {
      _imgFile = localImage;
      _imagePath = filePath;
    });

    await saveImage(filePath);
    await uploadImageToFirebase(filePath);
    await saveUserProfile(filePath);
  }

  @override
  Widget build(BuildContext context) {
    var uid = GetData().getUserId();
    ImageProvider backgroundImage;
    if (_imagePath != null && File(_imagePath!).existsSync()) {
      backgroundImage = FileImage(File(_imagePath!));
    } else if (_imgFile != null) {
      backgroundImage = FileImage(_imgFile!);
    } else {
      backgroundImage = AssetImage("assets/images/app/$uid.jpg");
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              FutureBuilder<String>(
                future: getAvatarUrl(uid),
                builder: (context, avatarSnapshot) {
                  if (avatarSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return CircleAvatar(
                      radius: 100,
                      backgroundImage: backgroundImage,
                      backgroundColor: Colors.grey,
                      child: Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.green,
                            child: IconButton(
                              icon: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                showImagePicker(context);
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  } else if (avatarSnapshot.hasError ||
                      !avatarSnapshot.hasData) {
                    return CircleAvatar(
                      radius: 100,
                      backgroundImage: backgroundImage,
                      backgroundColor: Colors.grey,
                      child: Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.green,
                            child: IconButton(
                              icon: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                showImagePicker(context);
                              },
                            ),
                          ),
                        ),
                      ),
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
                      radius: 100,
                      backgroundImage: imageProvider,
                      backgroundColor: Colors.black,
                      child: Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.green,
                            child: IconButton(
                              icon: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                showImagePicker(context);
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Изображение сохранено')),
                      );
                    },
                    child: const Text('Save Image'),
                  ),
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Text(
                'Name: $name',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Surname: $surname',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Email: $email',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Phone: $phone',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Отображение нижнего листа для выбора источника изображения
  void showImagePicker(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.blue[100],
      context: context,
      builder: (builder) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 250,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  IconButton(
                    iconSize: 60,
                    icon: const Icon(Icons.image),
                    onPressed: () {
                      pickImage(ImageSource.gallery);
                      Navigator.pop(context);
                    },
                  ),
                  const Text(
                    "Gallery",
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  IconButton(
                    iconSize: 60,
                    icon: const Icon(Icons.camera_alt),
                    onPressed: () {
                      pickImage(ImageSource.camera);
                      Navigator.pop(context);
                    },
                  ),
                  const Text(
                    "Photo",
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:myapp/liked_images.dart';
import 'package:myapp/pages/search.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance(); // Initialize SharedPreferences

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LikedImages()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Search App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ImageSearch(),
      // routes: {
      //   '/settings': (context) => SettingsScreen(),
      // },
    );
  }
}

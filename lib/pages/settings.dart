import 'package:flutter/material.dart';
import 'package:myapp/liked_images.dart';
import 'package:myapp/settings.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  ImageSize _selectedImageSize = ImageSize.medium;
  bool _enableSafeSearch = true;
  bool _isInited = false;

  @override
  Widget build(BuildContext context) {
    if (!_isInited) {
      final likedImagesProvider =
          Provider.of<LikedImages>(context, listen: false);
      _selectedImageSize = likedImagesProvider.appSettings.selectedImageSize;
      _enableSafeSearch = likedImagesProvider.appSettings.enableSafeSearch;
      _isInited = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Image Search Settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
                title: const Text('Image Size'),
                trailing: DropdownButton<ImageSize>(
                  value: _selectedImageSize,
                  onChanged: (ImageSize? newSize) {
                    setState(() {
                      _selectedImageSize = newSize!;
                    });
                  },
                  items: ImageSize.values.map((ImageSize size) {
                    return DropdownMenuItem<ImageSize>(
                      value: size,
                      child:
                          Text(size.toString().split('.').last.toLowerCase()),
                    );
                  }).toList(),
                )),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Enable Safe Search'),
              value: _enableSafeSearch,
              onChanged: (value) {
                setState(() {
                  _enableSafeSearch = value;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final likedImagesProvider =
                    Provider.of<LikedImages>(context, listen: false);

                final settings = Settings(
                    selectedImageSize: _selectedImageSize,
                    enableSafeSearch: _enableSafeSearch);
                likedImagesProvider.updateSettings(settings);

                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                prefs.setString('settings', settings.toJson().toString());

                Navigator.pop(context);
              },
              child: const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:myapp/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LikedImages with ChangeNotifier {
  static const String _likedImagesKey = 'likedImages';
  List<String> _likedImageLinks = [];

  List<String> get likedImageLinks => _likedImageLinks;

  LikedImages() {
    _loadLikedImages();
  }

  Future<void> _loadLikedImages() async {
    //SharedPreferences.setMockInitialValues({});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _likedImageLinks = prefs.getStringList(_likedImagesKey) ?? [];
    //print(_loadLikedImages());
    Settings? loadedSettings = await SettingsManager.loadSettings();
    print('SettingsManager.loadSettings');
    print(loadedSettings);
    if (loadedSettings != null) {
      _appSettings = loadedSettings;
    } else {
      print('Loading settings failed!');
    }
    notifyListeners();
  }

  Future<void> addLikedImage(String link) async {
    _likedImageLinks.add(link);
    notifyListeners();
    await _saveLikedImages();
  }

  Future<void> removeLikedImage(String link) async {
    _likedImageLinks.remove(link);
    notifyListeners();
    await _saveLikedImages();
  }

  Future<void> _saveLikedImages() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(_likedImagesKey, _likedImageLinks);
  }

  Settings _appSettings = Settings(
    selectedImageSize: ImageSize.medium,
    enableSafeSearch: true,
  );

  Settings get appSettings => _appSettings;

  void updateSettings(Settings settings) async {
    _appSettings = settings;
    await SettingsManager.saveSettings(_appSettings);
    notifyListeners();
  }
}

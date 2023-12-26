import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  ImageSize selectedImageSize = ImageSize.medium;
  bool enableSafeSearch = true;

  Settings({
    required this.selectedImageSize,
    required this.enableSafeSearch,
  });

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      selectedImageSize: json['selectedImageSize'] ?? ImageSize.medium,
      enableSafeSearch: json['enableSafeSearch'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selectedImageSize': selectedImageSize,
      'enableSafeSearch': enableSafeSearch,
    };
  }

  String toJsonString() {
    Map<String, dynamic> jsonMap = {
      'selectedImageSize': selectedImageSize.toJson(),
      'enableSafeSearch': enableSafeSearch,
    };
    return json.encode(jsonMap);
  }

  factory Settings.fromJsonString(String jsonString) {
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    return Settings(
      selectedImageSize:
          ImageSizeExtension.fromJson(jsonMap['selectedImageSize']),
      enableSafeSearch: jsonMap['enableSafeSearch'],
    );
  }
}

enum ImageSize {
  small,
  medium,
  large,
}

extension ImageSizeExtension on ImageSize {
  String toJson() {
    return this.toString().split('.').last;
  }

  static ImageSize fromJson(String json) {
    switch (json) {
      case 'small':
        return ImageSize.small;
      case 'medium':
        return ImageSize.medium;
      case 'large':
        return ImageSize.large;
      default:
        throw ArgumentError('Invalid value: $json');
    }
  }
}

class SettingsManager {
  static const String _settingsKey = 'app_settings';

  // Save settings to SharedPreferences
  static Future<void> saveSettings(Settings settings) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = settings.toJsonString();
    print('saveSettings');
    print(jsonString);
    prefs.setString(_settingsKey, jsonString);
  }

  // Load settings from SharedPreferences
  static Future<Settings?> loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(_settingsKey);
    print('prefs.getString');
    print(jsonString);
    return Settings.fromJsonString(jsonString!);
  }
}

import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';

class StorageService {
  static const String _currentUserEmailKey = 'currentUserEmail';
  static const String _isFirstTimeKey = 'isFirstTime';
  static const String _userNamePrefix = 'userName_';
  static const String _customCategoriesPrefix = 'customCategories_';
  static const String _profileImagePrefix = 'profileImage_';

  static Future<String?> getCurrentUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserEmailKey);
  }

  static Future<void> setCurrentUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserEmailKey, email);
  }

  static Future<void> clearCurrentUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserEmailKey);
  }

  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isFirstTimeKey) ?? true;
  }

  static Future<void> setFirstTimeComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isFirstTimeKey, false);
  }

  static Future<String> getUserName(String email) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_userNamePrefix$email') ?? 'Your Name';
  }

  static Future<void> setUserName(String email, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_userNamePrefix$email', name);
  }

  static Future<List<String>> getCustomCategories(String email) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('$_customCategoriesPrefix$email') ?? [];
  }

  static Future<void> setCustomCategories(String email, List<String> categories) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('$_customCategoriesPrefix$email', categories);
  }

  static Future<void> addCustomCategory(String email, String category) async {
    final categories = await getCustomCategories(email);
    if (!categories.contains(category)) {
      categories.add(category);
      await setCustomCategories(email, categories);
    }
  }

  static Future<String?> getProfileImagePath(String email) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_profileImagePrefix$email');
  }

  static Future<void> setProfileImagePath(String email, String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_profileImagePrefix$email', path);
  }

  static Future<void> clearProfileImagePath(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_profileImagePrefix$email');
  }

  static Future<Box<TaskModel>> getTaskBox(String email) async {
    final boxName = 'tasksBox_$email';
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox<TaskModel>(boxName);
    }
    return Hive.box<TaskModel>(boxName);
  }

  static Future<void> closeTaskBox(String email) async {
    final boxName = 'tasksBox_$email';
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box<TaskModel>(boxName).close();
    }
  }

  static Future<void> clearAllUserData(String email) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.remove('$_userNamePrefix$email');
    await prefs.remove('$_customCategoriesPrefix$email');
    await prefs.remove('$_profileImagePrefix$email');
    
    await closeTaskBox(email);
    await Hive.deleteBoxFromDisk('tasksBox_$email');
  }
}

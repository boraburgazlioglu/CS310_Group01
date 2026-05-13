import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _lastTabKey = 'last_tab_index';

  // save last selected tab index
  Future<void> saveLastTab(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastTabKey, index);
  }

  // get last selected tab index, default is 0 (home)
  Future<int> getLastTab() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lastTabKey) ?? 0;
  }
}
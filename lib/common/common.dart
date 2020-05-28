import 'package:shared_preferences/shared_preferences.dart';

class Common {
  readData(readKey) async {
    final prefs = await SharedPreferences.getInstance();
    final key = readKey;
    final value = prefs.getString(key) ?? '';
    return value;
  }

  writeData(writeKey, writeValue) async {
    final prefs = await SharedPreferences.getInstance();
    final key = writeKey;
    final value = writeValue;
    prefs.setString(key, value);
    return value;
  }

  logOut() async {
    writeData('token', '');
    writeData('loggedin', '');
  }

  clearData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.clear();
  }
}

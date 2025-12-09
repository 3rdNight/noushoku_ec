import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  String? email;
  String? address;

  UserProfile({this.email, this.address});

  static const _kEmail = 'user_email';
  static const _kAddress = 'user_address';

  Map<String, String?> toMap() => {_kEmail: email, _kAddress: address};

  Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final m = toMap();
    for (final entry in m.entries) {
      if (entry.value != null) {
        await prefs.setString(entry.key, entry.value!);
      } else {
        await prefs.remove(entry.key);
      }
    }
  }

  static Future<UserProfile> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return UserProfile(
      email: prefs.getString(_kEmail),
      address: prefs.getString(_kAddress),
    );
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kEmail);
    await prefs.remove(_kAddress);

    email = null;
    address = null;
  }
}

// singleton instance
final userProfile = UserProfile();

// lib/data/user_profile.dart
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  String? email;
  String? cardNumber; // armazenar sem mascarar (por enquanto)
  String? cardHolder;
  String? cardExpiry;
  String? phone;
  String? address;

  UserProfile({
    this.email,
    this.cardNumber,
    this.cardHolder,
    this.cardExpiry,
    this.phone,
    this.address,
  });

  static const _kEmail = 'user_email';
  static const _kCardNumber = 'user_card_number';
  static const _kCardHolder = 'user_card_holder';
  static const _kCardExpiry = 'user_card_expiry';
  static const _kPhone = 'user_phone';
  static const _kAddress = 'user_address';

  Map<String, String?> toMap() => {
    _kEmail: email,
    _kCardNumber: cardNumber,
    _kCardHolder: cardHolder,
    _kCardExpiry: cardExpiry,
    _kPhone: phone,
    _kAddress: address,
  };

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
      cardNumber: prefs.getString(_kCardNumber),
      cardHolder: prefs.getString(_kCardHolder),
      cardExpiry: prefs.getString(_kCardExpiry),
      phone: prefs.getString(_kPhone),
      address: prefs.getString(_kAddress),
    );
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kEmail);
    await prefs.remove(_kCardNumber);
    await prefs.remove(_kCardHolder);
    await prefs.remove(_kCardExpiry);
    await prefs.remove(_kPhone);
    await prefs.remove(_kAddress);

    email = null;
    cardNumber = null;
    cardHolder = null;
    cardExpiry = null;
    phone = null;
    address = null;
  }
}

// singleton instance (prático para usar no app)
final userProfile = UserProfile();

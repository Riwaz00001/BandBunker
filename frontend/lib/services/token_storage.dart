import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();
  static const _musicianKey = 'musician_token';
  static const _ownerKey = 'owner_token';
  static const _musicianIdKey = 'musician_id';

  static Future<void> saveMusicianToken(String token) =>
      _storage.write(key: _musicianKey, value: token);
  static Future<void> saveOwnerToken(String token) =>
      _storage.write(key: _ownerKey, value: token);
  static Future<String?> getMusicianToken() => _storage.read(key: _musicianKey);
  static Future<String?> getOwnerToken() => _storage.read(key: _ownerKey);
  static Future<void> clearMusicianToken() => _storage.delete(key: _musicianKey);
  static Future<void> clearOwnerToken() => _storage.delete(key: _ownerKey);
  
  static Future<void> saveMusicianId(int id) =>
      _storage.write(key: _musicianIdKey, value: id.toString());
  static Future<int?> getMusicianId() async {
    final value = await _storage.read(key: _musicianIdKey);
    return value != null ? int.tryParse(value) : null;
  }
  static Future<void> clearMusicianId() => _storage.delete(key: _musicianIdKey);
}

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final String _keyPath = 'api_key';
final FlutterSecureStorage _storage = new FlutterSecureStorage();

Future storeApiKey(String key) {
  return _storage.write(key: _keyPath, value: key);
}

Future<String> readApiKey() {
  return _storage.read(key: _keyPath);
}

Future<bool> apiKeyExists() {
  return _storage.containsKey(key: _keyPath);
}

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'logging_reprository.dart';

enum _SecureStorageKeys {
  apiKey,
}

class SecureStorageRepository {
  final _log = LoggerReprository('SecureStorageRepository');
  late final FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  get storage => _secureStorage;
  
  AndroidOptions _getAndroidOptions() =>  AndroidOptions(
        encryptedSharedPreferences: true,
        // sharedPreferencesName: 'Test2',
        // preferencesKeyPrefix: 'Test'
  );
   //TODO: bypass for web
  Future<dynamic> readSecure(String key) async {
    _log.i('getting $key...');
    if(!kIsWeb) {
      return await _secureStorage.read(key: key);
    }
  }
  
  Future<void> writeSecure({required String key,required String value}) async {
    if(!kIsWeb) {
      await _secureStorage.write(key: key, value: value);
    }
  }
  
  Future<void> deleteSecure(String key) async {
    if(!kIsWeb) {
      await _secureStorage.delete(key: key);
    }
  }

  // Future<String> get apiKey async =>
  //     await _secureStorage.read(key: _SecureStorageKeys.apiKey.name) ?? '';

  // Future<bool> hasApiKey() async =>
  //     _secureStorage.containsKey(key: _SecureStorageKeys.apiKey.name);

  // Future<void> setApiKey(String value) async => await _secureStorage.write(
  //       key: _SecureStorageKeys.apiKey.name,
  //       value: value,
  //     );
}
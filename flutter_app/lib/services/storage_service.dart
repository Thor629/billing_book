import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Platform-aware storage service that works on both web and native platforms
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  FlutterSecureStorage? _secureStorage;
  final Map<String, String> _webStorage = {};

  FlutterSecureStorage get _storage {
    _secureStorage ??= const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
      webOptions: WebOptions(
        dbName: 'saas_billing_db',
        publicKey: 'saas_billing_key',
      ),
    );
    return _secureStorage!;
  }

  /// Read a value from storage
  Future<String?> read(String key) async {
    try {
      if (kIsWeb) {
        // For web, try secure storage first, fallback to in-memory
        try {
          final value = await _storage.read(key: key);
          if (value != null) return value;
        } catch (e) {
          // Fallback to in-memory storage for web
          return _webStorage[key];
        }
      }
      return await _storage.read(key: key);
    } catch (e) {
      print('StorageService read error: $e');
      // Fallback to in-memory for web
      if (kIsWeb) {
        return _webStorage[key];
      }
      return null;
    }
  }

  /// Write a value to storage
  Future<void> write(String key, String value) async {
    try {
      if (kIsWeb) {
        // Store in both for web
        _webStorage[key] = value;
        try {
          await _storage.write(key: key, value: value);
        } catch (e) {
          // In-memory storage is already set
        }
      } else {
        await _storage.write(key: key, value: value);
      }
    } catch (e) {
      print('StorageService write error: $e');
      // Fallback to in-memory for web
      if (kIsWeb) {
        _webStorage[key] = value;
      }
    }
  }

  /// Delete a value from storage
  Future<void> delete(String key) async {
    try {
      if (kIsWeb) {
        _webStorage.remove(key);
        try {
          await _storage.delete(key: key);
        } catch (e) {
          // In-memory already cleared
        }
      } else {
        await _storage.delete(key: key);
      }
    } catch (e) {
      print('StorageService delete error: $e');
      if (kIsWeb) {
        _webStorage.remove(key);
      }
    }
  }

  /// Delete all values from storage
  Future<void> deleteAll() async {
    try {
      if (kIsWeb) {
        _webStorage.clear();
        try {
          await _storage.deleteAll();
        } catch (e) {
          // In-memory already cleared
        }
      } else {
        await _storage.deleteAll();
      }
    } catch (e) {
      print('StorageService deleteAll error: $e');
      if (kIsWeb) {
        _webStorage.clear();
      }
    }
  }
}

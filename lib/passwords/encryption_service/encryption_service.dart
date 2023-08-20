import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/pointycastle.dart';

class EncryptionService {
  static final EncryptionService _encryptionService = EncryptionService._();

  EncryptionService._();

  factory EncryptionService() => _encryptionService;

  /* Fields */
  String _encryptionKey = "";
  final IV _iv = IV.fromLength(16);
  late Encrypter _encrypter;

  set encryptionKey(String val) {
    _encryptionKey = val;
    _encrypter = Encrypter(AES(Key.fromBase64(_encryptionKey)));
  }

  /// length in bytes
  List<int> generateEncryptionKey({int length = 32}) {
    // final random = Random.secure();
    // final List<int> keyBytes = List.generate(length, (_) => random.nextInt(256));
    // return keyBytes;

    // return keyBytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();

    final keyBytes = generateRandomBytes(32); // 32 bytes for AES-256

    final key = KeyParameter(keyBytes);
    final cipher = BlockCipher('AES');

    cipher.init(true, key); // true for encryption, false for decryption

    // You can convert the key to a hex string for storage or transmission
    final keyHex = keyBytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();

    print('Generated Key: ${base64UrlEncode(keyBytes)}');
    return [];
  }

  Uint8List generateRandomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(List<int>.generate(length, (_) => random.nextInt(256)));
  }

  String encryptData(String text) {
    return text.isNotEmpty ? _encrypter.encrypt(text, iv: _iv).base64 : "";
  }

  String decryptData(String encryptedBase64) {
    return encryptedBase64.isNotEmpty ? _encrypter.decrypt64(encryptedBase64, iv: _iv) : "";
  }
}

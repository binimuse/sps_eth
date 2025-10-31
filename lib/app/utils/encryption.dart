import 'package:encrypt/encrypt.dart';

class EncryptionUtil {
  static String encrypt(plainText) {
    final key = Key.fromUtf8("qwertyuiopqwerty");
    final iv = IV.fromUtf8("qwertyuiopqwerty");

    final encrypter = Encrypter(AES(key));

    return encrypter.encrypt(plainText, iv: iv).base64;
  }

  static String decrypt(encrypted) {
    final key = Key.fromUtf8("qwertyuiopqwerty");
    final iv = IV.fromUtf8("qwertyuiopqwerty");

    final encrypter = Encrypter(AES(key));

    return encrypter.decrypt(Encrypted.from64(encrypted), iv: iv);
  }
}

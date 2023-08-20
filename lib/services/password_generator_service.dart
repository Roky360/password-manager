import 'dart:math';

class PasswordGeneratorService {
  static final PasswordGeneratorService _passwordsService = PasswordGeneratorService._();

  PasswordGeneratorService._();

  factory PasswordGeneratorService() => _passwordsService;

  /* Properties */
  static const String uppercaseLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String lowercaseLetters = 'abcdefghijklmnopqrstuvwxyz';
  static const String numbers = '0123456789';
  static const String specialChars = '!@#\$%^&*()_-+=[]{}|:<>?';

  /* Methods */
  String generatePassword(
    int length, {
    bool includeLowercase = true,
    bool includeUppercase = true,
    bool includeNumbers = true,
    bool includeSpecials = true,
  }) {
    // Ensure the password length is at least 4 to accommodate the required characters
    assert(length >= 4, "Password length should be at least 4");
    // Ensure that at least one option is set to true
    assert(includeLowercase || includeUppercase || includeNumbers || includeSpecials,
        "At least one option must be set to true");

    String generateRandomString(String validChars, int length) {
      final random = Random.secure();
      return String.fromCharCodes(Iterable.generate(
          length, (_) => validChars.codeUnitAt(random.nextInt(validChars.length))));
    }

    final password = StringBuffer();
    String allChars = "";
    int charsIncluded = 0;

    // Include at least one uppercase letter
    if (includeUppercase) {
      password.write(generateRandomString(uppercaseLetters, 1));
      allChars += uppercaseLetters;
      charsIncluded++;
    }
    // Include at least one lowercase letter
    if (includeLowercase) {
      password.write(generateRandomString(lowercaseLetters, 1));
      allChars += lowercaseLetters;
      charsIncluded++;
    }
    // Include at least one number
    if (includeNumbers) {
      password.write(generateRandomString(numbers, 1));
      allChars += numbers;
      charsIncluded++;
    }
    // Include at least one special character
    if (includeSpecials) {
      password.write(generateRandomString(specialChars, 1));
      allChars += specialChars;
      charsIncluded++;
    }

    // Fill the remaining password length with random characters
    password.write(generateRandomString(allChars, length - charsIncluded));

    // Shuffle the characters at the end of the password
    final shuffledPassword = password.toString().split('');
    shuffledPassword.shuffle(Random.secure());
    return shuffledPassword.join();
  }
}

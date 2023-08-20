import 'dart:io';

import 'package:path_provider/path_provider.dart';

class LocalStorageService {
  static const _categoriesFilename = "categories_local_data.json";
  static const _servicesFilename = "services_local_data.json";

  Future<String> get _localStorageDir async => (await getApplicationDocumentsDirectory()).path;

  Future<File> get categoriesFileRef async =>
      File("${await _localStorageDir}/$_categoriesFilename");

  Future<File> get servicesFileRef async => File("${await _localStorageDir}/$_servicesFilename");

  /// Accepts [data] as json format to write to the local file storage.
  Future<void> writeData(File file, String data) async {
    await file.writeAsString(data);
  }

  Future<String> readData(File file) async {
    try {
      return await file.readAsString();
    } catch (e) {
      rethrow;
      return "";
    }
  }
}

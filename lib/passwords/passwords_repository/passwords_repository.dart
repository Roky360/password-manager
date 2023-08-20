import 'dart:convert';

import 'package:password_manager/passwords/local_storage_service/local_storage_service.dart';
import 'package:password_manager/passwords/passwords_repository/category.dart';
import 'package:password_manager/passwords/passwords_repository/service.dart';

class PasswordsRepository {
  static final PasswordsRepository _passwordsRepository = PasswordsRepository._();

  PasswordsRepository._();

  factory PasswordsRepository() => _passwordsRepository;

  /* Fields */
  Map<String, Category> _categoryMap = {};
  Map<String, Service> _serviceMap = {};
  final LocalStorageService storageService = LocalStorageService();

  Map<String, Category> get categoryMap => _categoryMap;

  set categoryMap(Map<String, Category> val) {
    _categoryMap = val;
    writeCategoriesToLocalStorage();
  }

  Map<String, Service> get serviceMap => _serviceMap;

  set serviceMap(Map<String, Service> val) {
    _serviceMap = val;
    writeServicesToLocalStorage();
  }

  List<Category> get categories => categoryMap.values.toList(growable: false);

  List<Service> get services => serviceMap.values.toList(growable: false);

  /* Methods */

  Future<void> writeCategoriesToLocalStorage() async {
    await storageService.writeData(
        await storageService.categoriesFileRef,
        jsonEncode(
            categories.map((e) => e.toEncryptedJson()..['id'] = e.id).toList(growable: false)));
  }

  Future<void> readLocalCategories() async {
    final rawData =
        jsonDecode(await storageService.readData(await storageService.categoriesFileRef)) as List;
    categoryMap.clear();
    for (final record in rawData) {
      final Category cat = Category.fromEncryptedJson(record['id'], record);
      categoryMap[cat.id] = cat;
    }
  }

  Future<void> writeServicesToLocalStorage() async {
    await storageService.writeData(
        await storageService.servicesFileRef,
        jsonEncode(
            services.map((e) => e.toEncryptedJson()..['id'] = e.id).toList(growable: false)));
  }

  Future<void> readLocalServices() async {
    final rawData =
    jsonDecode(await storageService.readData(await storageService.servicesFileRef)) as List;
    serviceMap.clear();
    for (final record in rawData) {
      final Service s = Service.fromEncryptedJson(record['id'], record);
      serviceMap[s.id] = s;
    }
  }
}

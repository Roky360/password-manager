import 'package:password_manager/passwords/db_service/db_service.dart';
import 'package:password_manager/passwords/passwords_repository/category.dart';
import 'package:password_manager/passwords/passwords_repository/passwords_repository.dart';
import 'package:password_manager/passwords/passwords_repository/service.dart';

class PasswordsService {
  static final PasswordsService _passwordsService = PasswordsService._();

  PasswordsService._();

  factory PasswordsService() => _passwordsService;

  /* properties */
  final FirestoreService _dbService = FirestoreService();
  final PasswordsRepository _passRepo = PasswordsRepository();

  /* Categories */

  Stream<List<Category>> get categoriesStream => _dbService.categoriesStream;

  List<Category> get categories => _passRepo.categories;

  Future<void> createCategory(Category category) async {
    await _dbService.createCategory(category);
  }

  Future<void> updateCategory(Category category) async {
    await _dbService.updateCategory(category);
  }

  Future<void> deleteCategory(String categoryId, bool keepChildServices) async {
    await _dbService.deleteCategory(categoryId, keepChildServices);
  }

  /* Services */

  Stream<List<Service>> get servicesStream => _dbService.servicesStream;

  List<Service> get services => _passRepo.services;

  Future<void> createService(Service service) async {
    await _dbService.createService(service);
  }

  void serviceChangeCategory(Service service, Category newCategory) {}

  Future<void> serviceSetFavorite(Service service, bool isFavorite) async =>
      await updateService(service.copyWith(isFavorite: isFavorite));

  Future<void> serviceSetSensitive(Service service, bool isSensitive) async =>
      await updateService(service.copyWith(isSensitive: isSensitive));

  Future<void> updateService(Service service) async {
    await _dbService.updateService(service);
  }

  Future<void> deleteService(String serviceId) async {
    await _dbService.deleteService(serviceId);
  }
}

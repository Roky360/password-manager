part of 'passwords_bloc.dart';

@immutable
abstract class PasswordsEvent {}

/* Categories */
class LoadCategoriesEvent extends PasswordsEvent {}

class CreateCategoryEvent extends PasswordsEvent {
  final Category category;

  CreateCategoryEvent(this.category);
}

class UpdateCategoryEvent extends PasswordsEvent {
  final Category category;

  UpdateCategoryEvent(this.category);
}

class DeleteCategoryEvent extends PasswordsEvent {
  final String categoryId;
  final bool keepChildServices;

  DeleteCategoryEvent(this.categoryId, this.keepChildServices);
}

/* Services */
class LoadServicesEvent extends PasswordsEvent {}

class CreateServiceEvent extends PasswordsEvent {
  final Service service;

  CreateServiceEvent(this.service);
}

class UpdateServiceEvent extends PasswordsEvent {
  final Service service;

  UpdateServiceEvent(this.service);
}

class DeleteServiceEvent extends PasswordsEvent {
  final String serviceId;

  DeleteServiceEvent(this.serviceId);
}

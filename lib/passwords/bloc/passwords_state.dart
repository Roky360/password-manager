part of 'passwords_bloc.dart';

@immutable
abstract class PasswordsState {}

class PasswordsInitial extends PasswordsState {}

class PasswordsErrorState extends PasswordsState {
  final String message;

  PasswordsErrorState({this.message = ""});
}

/* Categories */

class CategoriesLoadingState extends PasswordsState {}

class OnlineCategoriesLoadedState extends PasswordsState {
  final Stream<List<Category>> categoriesStream;

  OnlineCategoriesLoadedState(this.categoriesStream);
}

class CachedCategoriesLoadedState extends PasswordsState {
  final List<Category> categories;

  CachedCategoriesLoadedState(this.categories);
}

/* Services */

class ServicesLoadingState extends PasswordsState {}

class OnlineServicesLoadedState extends PasswordsState {
  final Stream<List<Service>> servicesStream;

  OnlineServicesLoadedState(this.servicesStream);
}

class CachedServicesLoadedState extends PasswordsState {
  final List<Service> services;

  CachedServicesLoadedState(this.services);
}

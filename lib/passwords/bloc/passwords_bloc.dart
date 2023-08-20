import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:password_manager/passwords/passwords_repository/category.dart';
import 'package:password_manager/passwords/passwords_repository/passwords_repository.dart';
import 'package:password_manager/passwords/passwords_repository/service.dart';
import 'package:password_manager/passwords/passwords_service.dart';
import 'package:password_manager/connectiviry/connectivity_service.dart';

import '../local_storage_service/local_storage_service.dart';

part 'passwords_event.dart';

part 'passwords_state.dart';

class PasswordsBloc extends Bloc<PasswordsEvent, PasswordsState> {
  final PasswordsService passwordsService = PasswordsService();
  final ConnectivityService connectivityService = ConnectivityService();
  final PasswordsRepository passwordsRepository = PasswordsRepository();

  PasswordsBloc() : super(PasswordsInitial()) {
    /* Categories */

    on<LoadCategoriesEvent>((event, emit) async {
      emit(CategoriesLoadingState());

      if (await connectivityService.checkConnectivity()) {
        // load online data
        emit(OnlineCategoriesLoadedState(passwordsService.categoriesStream));
      } else {
        // TODO: load cached data
        await passwordsRepository.readLocalCategories();

        emit(CachedCategoriesLoadedState(passwordsService.categories));
      }
    });

    on<CreateCategoryEvent>((event, emit) async {
      if (await connectivityService.checkConnectivity()) {
        await passwordsService.createCategory(event.category);
      } else {
        handleOfflineMode(emit);
      }
    });

    on<UpdateCategoryEvent>((event, emit) async {
      if (await connectivityService.checkConnectivity()) {
        await passwordsService.updateCategory(event.category);
      } else {
        handleOfflineMode(emit);
      }
    });

    on<DeleteCategoryEvent>((event, emit) async {
      if (await connectivityService.checkConnectivity()) {
        await passwordsService.deleteCategory(event.categoryId, event.keepChildServices);
      } else {
        handleOfflineMode(emit);
      }
    });

    /* Services */

    on<LoadServicesEvent>((event, emit) async {
      emit(ServicesLoadingState());

      if (await connectivityService.checkConnectivity()) {
        // load online data
        emit(OnlineServicesLoadedState(passwordsService.servicesStream));
      } else {
        // TODO: load cached data
        await passwordsRepository.readLocalServices();

        emit(CachedServicesLoadedState(passwordsService.services));
      }
    });

    on<CreateServiceEvent>((event, emit) async {
      if (await connectivityService.checkConnectivity()) {
        await passwordsService.createService(event.service);
      } else {
        handleOfflineMode(emit);
      }
    });

    on<UpdateServiceEvent>((event, emit) async {
      if (await connectivityService.checkConnectivity()) {
        await passwordsService.updateService(event.service);
      } else {
        handleOfflineMode(emit);
      }
    });

    on<DeleteServiceEvent>((event, emit) async {
      if (await connectivityService.checkConnectivity()) {
        await passwordsService.deleteService(event.serviceId);
      } else {
        handleOfflineMode(emit);
      }
    });
  }

  void handleOfflineMode(Emitter<PasswordsState> emit,
      {String msg = "Can't modify the data in offline mode."}) {
    final prevState = state;
    emit(PasswordsErrorState(message: "Can't modify data in offline mode."));
    emit(prevState);
  }
}

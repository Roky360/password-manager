import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:password_manager/passwords/bloc/passwords_bloc.dart';
import 'package:password_manager/passwords/passwords_repository/category.dart';
import 'package:password_manager/screens/edit_service_screen.dart';
import 'package:password_manager/screens/service_display_screen.dart';
import 'package:password_manager/services/company_icon_provider.dart';
import 'package:password_manager/utils/utils.dart';
import 'package:password_manager/widgets/animated_snackbar/animated_snackbar.dart';
import 'package:password_manager/widgets/animated_snackbar/animated_snackbar_messenger.dart';

import '../../../passwords/passwords_repository/service.dart';
import '../../device_auth/device_auth_service.dart';

class ServiceEntry extends StatelessWidget {
  final Service service;
  final bool independent;

  /// used in search results to mark some details related to the search query
  final String? markText;

  ServiceEntry(this.service, {super.key, this.independent = false, this.markText});

  final CompanyIconProvider iconProvider = CompanyIconProvider();
  final DeviceAuthService deviceAuthService = DeviceAuthService();

  void toggleFavorite(BuildContext context) {
    context
        .read<PasswordsBloc>()
        .add(UpdateServiceEvent(service.copyWith(isFavorite: !service.isFavorite)));
  }

  void copyPassword(BuildContext context) async {
    bool success = true;
    if (service.isSensitive) {
      final result = await deviceAuthService
          .requireAuthentication("Please authenticate to copy a sensitive password");
      success = result.success;
      if (!result.success) {
        if (!context.mounted) return;
        AnimatedSnackBarMessenger.showSnackBar(
            context, AnimatedSnackBar(content: Text(result.errorMsg)));
      }
    }

    if (success) {
      await Utils.copyToClipboard(service.password);
      if (!context.mounted) return;
      AnimatedSnackBarMessenger.showSnackBar(
          context, const AnimatedSnackBar(content: Text("Password copied to clipboard.")));
    }
  }

  Future<bool> authenticateIfSensitive(BuildContext context) async {
    if (service.isSensitive) {
      return (await deviceAuthService
              .requireAuthentication("Authenticate to edit a sensitive service"))
          .success;
    } else {
      return true;
    }
  }

  Widget getTextElement(String text, {TextStyle? style}) {
    if (markText != null) {
      return TextUtils.markedText(text, markText!, textStyle: style);
    } else {
      return Text(text, style: style);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      startActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: .45,
        children: [
          SlidableAction(
            onPressed: (_) async {
              if (await authenticateIfSensitive(context)) {
                if (!context.mounted) return;
                context.read<PasswordsBloc>().add(DeleteServiceEvent(service.id));
              }
            },
            label: "Delete",
            icon: Icons.delete_outline,
            spacing: 6,
            backgroundColor: Colors.lightBlueAccent.shade100.withOpacity(.15),
            foregroundColor: Colors.red,
          ),
          SlidableAction(
            onPressed: (_) async {
              if (await authenticateIfSensitive(context)) {
                if (!context.mounted) return;
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => EditServiceScreen(service)));
              }
            },
            label: "Edit",
            icon: Icons.edit_outlined,
            spacing: 6,
            borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
            backgroundColor: Colors.lightBlueAccent.shade100.withOpacity(.15),
            foregroundColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
      child: ListTile(
        title: Wrap(
          runSpacing: 4,
          children: [
            getTextElement(service.name),
            // Text(service.name),
            const SizedBox(width: 8),
            service.isSensitive
                ? const Icon(Icons.lock, color: Colors.red, size: 16)
                : const SizedBox(),
            const SizedBox(width: 8),
            independent && service.category != null && service.category != Category.noneCategory
                ? Badge(
                    backgroundColor: service.category!.color.toMaterialColor(),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    label: getTextElement(service.category!.name.toUpperCase(),
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(letterSpacing: .8, color: Colors.white)),
                  )
                : const SizedBox(),
          ],
        ),
        subtitle: getTextElement(service.username),
        contentPadding: const EdgeInsets.only(left: 28, right: 14),
        leading: service.getIcon(size: 20),
        trailing: ButtonBar(
          mainAxisSize: MainAxisSize.min,
          buttonPadding: const EdgeInsets.only(left: 2),
          children: [
            IconButton(
              onPressed: () => toggleFavorite(context),
              icon: Icon(
                service.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: Colors.redAccent.shade200,
              ),
              tooltip: "Toggle favorite",
            ),
            IconButton(
              onPressed: () => copyPassword(context),
              icon: const Icon(Icons.copy_rounded),
              tooltip: "Copy password",
            ),
          ],
        ),
        onTap: () async {
          if (await authenticateIfSensitive(context)) {
            if (!context.mounted) return;
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => ServiceDisplayScreen(service)));
          }
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marquee/marquee.dart';
import 'package:password_manager/config/constants.dart';
import 'package:password_manager/passwords/bloc/passwords_bloc.dart';
import 'package:password_manager/passwords/passwords_repository/category.dart';
import 'package:password_manager/screens/edit_service_screen.dart';
import 'package:password_manager/widgets/password_strength_slider.dart';
import 'package:password_manager/utils/utils.dart';
import 'package:sizer/sizer.dart';
import 'package:zxcvbn/zxcvbn.dart';

import '../passwords/passwords_repository/service.dart';
import '../services/password_strength_checker_service.dart';
import '../widgets/dialogs.dart';

class ServiceDisplayScreen extends StatelessWidget {
  final Service service;

  ServiceDisplayScreen(this.service, {super.key}) {
    result = PasswordStrengthCheckerService()
        .checkPassword(service.password, userInputs: [service.name, service.username]);
  }

  late final Result result;
  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth <
                TextUtils.calculateTextWidth(
                    service.name, Theme.of(context).appBarTheme.titleTextStyle!)) {
              return SizedBox(
                height: AppBar().preferredSize.height,
                child: Marquee(
                  text: service.name,
                  style: Theme.of(context).appBarTheme.titleTextStyle,
                  blankSpace: 20,
                  startPadding: 5,
                  velocity: 30,
                  pauseAfterRound: const Duration(seconds: 2),
                  startAfter: const Duration(seconds: 2),
                  fadingEdgeStartFraction: 0.1,
                  fadingEdgeEndFraction: 0.1,
                  numberOfRounds: null,
                  accelerationDuration: const Duration(milliseconds: 700),
                  accelerationCurve: Curves.easeIn,
                  decelerationDuration: const Duration(milliseconds: 700),
                  decelerationCurve: Curves.easeOut,
                ),
              );
            } else {
              return Text(service.name);
            }
          },
        ),
        leading: Container(
          margin: const EdgeInsets.symmetric(horizontal: 15),
          child: service.getIcon(),
        ),
        actions: [const CloseButton()],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: pageMargin, vertical: 10),
          child: Center(
            child: Column(
              children: [
                // domain
                service.domain.isNotEmpty
                    ? GestureDetector(
                        onTap: () => Utils.openUrl(service.domain),
                        child: Text(
                          service.domain,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.blue, decoration: TextDecoration.underline),
                        ),
                      )
                    : const SizedBox(),
                const SizedBox(height: 10),
                service.category != null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.circle_outlined,
                            size: 16,
                            color: service.category!.color.toMaterialColor(),
                          ),
                          const SizedBox(width: 10),
                          RichText(
                            text: TextSpan(
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: service.category!.color.toMaterialColor()),
                              children: [
                                const TextSpan(text: "In "),
                                TextSpan(
                                  text: service.category!.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const TextSpan(text: " category"),
                              ],
                            ),
                          ),
                        ],
                      )
                    : const SizedBox(),
                const SizedBox(height: 16),
                Visibility(
                  visible: service.isSensitive,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lock,
                        color: Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Sensitive",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.red),
                      )
                    ],
                  ),
                ),

                /* Details */
                const SizedBox(height: 25),
                // username
                Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Username",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 100.w,
                      child: TextField(
                        controller: TextEditingController()..text = service.username,
                        readOnly: true,
                        decoration: InputDecoration(
                          isDense: true,
                          focusedBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
                          suffixIcon: IconButton(
                            onPressed: () async => await Utils.copyToClipboard(service.username),
                            icon: const Icon(
                              Icons.copy_rounded,
                              size: 18,
                            ),
                            visualDensity: VisualDensity.compact,
                            tooltip: "Copy username",
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // password
                Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Password",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 100.w,
                      child: StatefulBuilder(
                        builder: (context, setState) => TextField(
                          controller: TextEditingController()..text = service.password,
                          readOnly: true,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(letterSpacing: 1),
                          obscureText: !showPassword,
                          decoration: InputDecoration(
                            isDense: true,
                            focusedBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => setState(() => showPassword = !showPassword),
                                  icon: Icon(
                                    showPassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 18,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                ),
                                IconButton(
                                  onPressed: () async =>
                                      await Utils.copyToClipboard(service.password),
                                  icon: const Icon(
                                    Icons.copy_rounded,
                                    size: 18,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  tooltip: "Copy password",
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                PasswordStrengthSlider(value: result.score!),
                const SizedBox(height: 20),
                // info
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Additional info",
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () async =>
                              await Utils.copyToClipboard(service.additionalInfo),
                          icon: const Icon(
                            Icons.copy_rounded,
                            size: 18,
                          ),
                          visualDensity: VisualDensity.compact,
                          tooltip: "Copy info",
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 100.w,
                      child: TextField(
                        controller: TextEditingController()
                          ..text =
                              service.additionalInfo == "" ? "(no info)" : service.additionalInfo,
                        readOnly: true,
                        maxLines: 5,
                        decoration: InputDecoration(
                            isDense: true,
                            focusedBorder: Theme.of(context).inputDecorationTheme.enabledBorder),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          OutlinedButtonTheme(
            data: OutlinedButtonThemeData(
                style: Theme.of(context).outlinedButtonTheme.style?.copyWith(
                      foregroundColor: const MaterialStatePropertyAll(Colors.white),
                      backgroundColor: const MaterialStatePropertyAll(Colors.teal),
                    )),
            child: OutlinedButton(
              onPressed: () async {
                final newService = await Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => EditServiceScreen(service)));
                if (newService != null) {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ServiceDisplayScreen(newService),
                  ));
                }
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text("Edit"),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButtonTheme(
            data: OutlinedButtonThemeData(
                style: Theme.of(context).outlinedButtonTheme.style?.copyWith(
                      foregroundColor: const MaterialStatePropertyAll(Colors.red),
                      side: const MaterialStatePropertyAll(BorderSide(color: Colors.red)),
                      surfaceTintColor: const MaterialStatePropertyAll(Colors.yellow),
                    )),
            child: OutlinedButton(
              onPressed: () async {
                if (await Dialogs.showDeleteServiceConfirmationDialog(context)) {
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                  context.read<PasswordsBloc>().add(DeleteServiceEvent(service.id));
                }
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete_outline, size: 20),
                  SizedBox(width: 8),
                  Text("Delete"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

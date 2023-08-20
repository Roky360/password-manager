import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:password_manager/config/constants.dart';
import 'package:password_manager/services/company_icon_provider.dart';
import 'package:password_manager/services/password_generator_service.dart';
import 'package:password_manager/services/password_strength_checker_service.dart';
import 'package:password_manager/utils/utils.dart';
import 'package:password_manager/widgets/dialogs.dart';
import 'package:password_manager/widgets/password_strength_slider.dart';
import 'package:sizer/sizer.dart';

import '../passwords/bloc/passwords_bloc.dart';
import '../passwords/passwords_repository/category.dart';
import '../passwords/passwords_repository/service.dart';
import '../connectiviry/connectivity_service.dart';
import 'settings_screen/global_settings_service.dart';

class EditServiceScreen extends StatefulWidget {
  final Service service;

  /// if this is true, confirming the form will create a new service.
  /// otherwise, this screen operates as editing an existing service
  final bool createNew;
  final bool? hidePassword;

  const EditServiceScreen(this.service, {Key? key, this.createNew = false, this.hidePassword})
      : super(key: key);

  @override
  State<EditServiceScreen> createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  late final Service service;
  final PasswordGeneratorService passwordsService = PasswordGeneratorService();
  final PasswordStrengthCheckerService passwordStrengthService = PasswordStrengthCheckerService();
  final CompanyIconProvider iconProvider = CompanyIconProvider();
  late final PasswordsBloc passwordsBloc;

  final FocusNode nameFocusNode = FocusNode();
  final FocusNode usernameFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode infoFocusNode = FocusNode();
  final ScrollController scrollController = ScrollController();

  /* Password strength */
  late double passStrength;
  late void Function(void Function()) setPassStrengthMeterState;

  /* Temp fields */
  TextEditingController nameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController infoController = TextEditingController();
  late Category category;
  late String iconUrl;
  late String domain;

  bool get isSensitive => optionsSelections[0];

  set isSensitive(bool val) => optionsSelections[0] = val;

  bool get isFavorite => optionsSelections[1];

  set isFavorite(bool val) => optionsSelections[1] = val;

  final _formKey = GlobalKey<FormState>();

  late bool showPassword;
  late List<bool> optionsSelections;

  Map? suggestedCompany;
  final Icon _defaultIcon = const Icon(Icons.tag);

  Widget get requiredAsterisk =>
      Text(" *", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red));

  Future<void> formSubmitted() async {
    if (_formKey.currentState!.validate()) {
      final Service newService = Service(
        service.id,
        nameController.text.trim(),
        passwordController.text,
        username: usernameController.text.trim(),
        additionalInfo: infoController.text.trim(),
        isSensitive: optionsSelections[0],
        isFavorite: optionsSelections[1],
        categoryId: category.id,
        iconUrl: iconUrl,
        domain: domain,
      );

      // alert for too weak password
      if (passStrength < 7 && !(await Dialogs.showWeakPasswordDialog(context))) return;

      if (widget.createNew) {
        passwordsBloc.add(CreateServiceEvent(newService));
      } else {
        passwordsBloc.add(UpdateServiceEvent(newService));
      }

      if (GlobalSettingsService().getSetting(GlobalSettingsService.copyPasswordOnServiceCreation)
          as bool) {
        Utils.copyToClipboard(newService.password);
      }

      if (!context.mounted) return;
      Navigator.of(context).pop<Service>(newService);
    }
  }

  Widget iconImage(String url) => Padding(
      padding: const EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: Image.network(
          iconUrl,
          width: 10,
          height: 10,
          errorBuilder: (_, __, ___) => _defaultIcon,
        ),
      ));
  late Widget _serviceIcon;

  void getCompanyIcon() async {
    if (await ConnectivityService().checkConnectivity()) {
      suggestedCompany = await iconProvider.getDomainByName(nameController.text.trim());
    }

    // automatically apply the suggested icon, if there is
    if (suggestedCompany != null && iconUrl.isEmpty) {
      applySuggestedCompany();
    } else {
      setState(() {});
    }
  }

  void applySuggestedCompany() {
    setState(() {
      iconUrl = suggestedCompany!['logo'] ?? "";
      domain = suggestedCompany!['domain'] ?? "";

      if (iconUrl.isNotEmpty) {
        _serviceIcon = iconImage(iconUrl);
      }
      suggestedCompany = null;
    });
  }

  void removeCompanyIcon() {
    setState(() {
      iconUrl = "";
      domain = "";

      _serviceIcon = _defaultIcon;
    });
  }

  void updatePasswordStrength(String value) {
    if (value.isNotEmpty) {
      final res = passwordStrengthService.checkPassword(value, userInputs: [
        nameController.text,
        usernameController.text,
      ]);
      passStrength = res.score!;
    } else {
      passStrength = 1;
    }
    setPassStrengthMeterState(() {});
  }

  void infoFieldStartEditing(void Function(void Function()) setState) {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {});
  }

  void infoFieldDoneEditing(void Function(void Function()) setState) {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
    setState(() => infoFocusNode.unfocus());
  }

  @override
  void initState() {
    super.initState();

    service = widget.service;
    passwordsBloc = context.read<PasswordsBloc>();
    optionsSelections = [
      service.isSensitive,
      service.isFavorite,
    ];
    showPassword = widget.hidePassword != null ? !widget.hidePassword! : !isSensitive;
    category = service.category ?? Category.noneCategory;
    iconUrl = service.iconUrl;
    domain = service.domain;
    _serviceIcon = iconUrl.isNotEmpty ? iconImage(iconUrl) : _defaultIcon;

    nameController.text = service.name;
    usernameController.text = service.username;
    passwordController.text = service.password;
    infoController.text = service.additionalInfo;

    if (passwordController.text.isNotEmpty) {
      final res = passwordStrengthService.checkPassword(passwordController.text, userInputs: [
        nameController.text,
        usernameController.text,
      ]);
      passStrength = res.score!;
    } else {
      passStrength = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.createNew ? "New Service" : "Edit Service"),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: formSubmitted,
            child: const Text("Save"),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: pageMargin),
        child: Form(
          key: _formKey,
          child: ListView(
            controller: scrollController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              SizedBox(height: pageMargin),
              // name
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Service name",
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    requiredAsterisk,
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // service name
              SizedBox(
                width: 100.w,
                child: TextFormField(
                  controller: nameController,
                  focusNode: nameFocusNode,
                  validator: (value) {
                    if (value != null && value.isNotEmpty && !RegExp(r"^\s*$").hasMatch(value)) {
                      return null;
                    }
                    return "Service name is required";
                  },
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(prefixIcon: _serviceIcon),
                  onEditingComplete: () {
                    getCompanyIcon();
                    if (usernameController.text.isEmpty) {
                      usernameFocusNode.requestFocus();
                    } else {
                      nameFocusNode.unfocus();
                    }
                  },
                ),
              ),
              Row(
                children: [
                  suggestedCompany != null
                      ? TextButton(
                          onPressed: applySuggestedCompany,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome, size: 18),
                              SizedBox(width: 8),
                              Text("Suggested icon")
                            ],
                          ),
                        )
                      : const SizedBox(),
                  const Spacer(),
                  iconUrl.isNotEmpty
                      ? TextButton(
                          style: Theme.of(context).textButtonTheme.style?.copyWith(
                              foregroundColor: MaterialStateProperty.all(Colors.red),
                              overlayColor:
                                  MaterialStateProperty.all(Colors.red.shade100.withOpacity(.2))),
                          onPressed: removeCompanyIcon,
                          child: const Text("Remove icon"),
                        )
                      : const SizedBox(),
                ],
              ),
              SizedBox(height: (suggestedCompany != null || iconUrl.isNotEmpty) ? 1.5.h : 3.5.h),

              // username / email
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Username / email",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              const SizedBox(height: 8),
              // username
              SizedBox(
                width: 100.w,
                child: TextFormField(
                  controller: usernameController,
                  focusNode: usernameFocusNode,
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.alternate_email)),
                  keyboardType: TextInputType.emailAddress,
                  onEditingComplete: () {
                    if (passwordController.text.isEmpty) {
                      passwordFocusNode.requestFocus();
                    } else {
                      usernameFocusNode.unfocus();
                    }
                  },
                ),
              ),
              SizedBox(height: 3.5.h),

              // password
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Password",
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    requiredAsterisk,
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // password
              SizedBox(
                width: 100.w,
                child: StatefulBuilder(
                  builder: (context, setState) => TextFormField(
                    controller: passwordController,
                    focusNode: passwordFocusNode,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Password is required";
                      } else if (RegExp(r"\s").hasMatch(value)) {
                        return "Password should not contain spaces";
                      }
                      return null;
                    },
                    onChanged: updatePasswordStrength,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.password),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => setState(() => showPassword = !showPassword),
                              icon: Icon(showPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined),
                            ),
                            IconButton(
                              onPressed: () async {
                                bool erase = true;
                                if (passwordController.text.isNotEmpty) {
                                  erase = await Dialogs.showOverridePasswordDialog(context);
                                }
                                if (erase) {
                                  final newPass = passwordsService.generatePassword(16);
                                  setState(() => passwordController.text = newPass);
                                  updatePasswordStrength(newPass);
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) => passwordFocusNode.unfocus());
                                }
                              },
                              icon: const Icon(Icons.sync_lock_rounded),
                              tooltip: "Generate password",
                            ),
                          ],
                        )),
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: !showPassword,
                  ),
                ),
              ),
              // length meter
              StatefulBuilder(builder: (context, setState) {
                setPassStrengthMeterState = setState;
                return PasswordStrengthSlider.compact(value: passStrength);
              }),
              SizedBox(height: 2.h),

              // description
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Additional information",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 100.w,
                child: StatefulBuilder(
                  builder: (context, setState) => TextFormField(
                    controller: infoController,
                    focusNode: infoFocusNode,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.description_outlined),
                        suffixIcon: infoFocusNode.hasFocus
                            ? IconButton(
                                onPressed: () => infoFieldDoneEditing(setState),
                                icon: const Icon(Icons.done))
                            : null),
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 5,
                    onTap: () => infoFieldStartEditing(setState),
                    onTapOutside: (_) => infoFieldDoneEditing(setState),
                  ),
                ),
              ),
              SizedBox(height: 3.h),

              // categories
              Row(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Category:", style: Theme.of(context).textTheme.titleMedium
                        // ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () async {
                      final newCat = await Dialogs.showChooseCategoryDialog(context,
                          initialCategory: category);
                      setState(() => category = newCat);
                    },
                    style: Theme.of(context).textButtonTheme.style?.copyWith(
                          overlayColor: MaterialStateProperty.all(
                              category.color.toMaterialColor()?.withOpacity(.1)),
                        ),
                    child: Text(
                      category.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: category.color.toMaterialColor()),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 2.h),

              Center(
                child: ToggleButtons(
                  isSelected: optionsSelections,
                  onPressed: (index) =>
                      setState(() => optionsSelections[index] = !optionsSelections[index]),
                  borderRadius: BorderRadius.circular(16),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(isSensitive ? Icons.lock : Icons.lock_outline_rounded,
                              color: Colors.red),
                          const SizedBox(width: 8),
                          const Text("Top secret!")
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: Colors.red),
                          const SizedBox(width: 8),
                          const Text("Favorite")
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
}

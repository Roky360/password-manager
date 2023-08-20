import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:password_manager/config/constants.dart';
import 'package:password_manager/screens/edit_service_screen.dart';
import 'package:password_manager/screens/passwords_factory/widgets/password_length_meter.dart';
import 'package:password_manager/screens/settings_screen/global_settings_service.dart';
import 'package:password_manager/services/password_generator_service.dart';
import 'package:password_manager/services/password_strength_checker_service.dart';
import 'package:password_manager/utils/utils.dart';
import 'package:password_manager/widgets/animated_snackbar/animated_snackbar.dart';
import 'package:password_manager/widgets/animated_snackbar/animated_snackbar_messenger.dart';
import 'package:password_manager/widgets/manual_animated_list/manual_list_controller.dart';
import 'package:password_manager/widgets/password_strength_slider.dart';
import 'package:quiver/strings.dart';
import 'package:sizer/sizer.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:zxcvbn/zxcvbn.dart';

import '../../passwords/passwords_repository/service.dart';
import '../../widgets/manual_animated_list/manual_animated_list.dart';
import '../../widgets/striped_container.dart';

class CenteredText {
  final String text;
  final int length;
  final String fill;

  CenteredText(this.text, this.length, {this.fill = " "});

  @override
  String toString() {
    return center(text, length, fill);
  }
}

class PasswordsFactoryScreen extends StatefulWidget {
  const PasswordsFactoryScreen({super.key});

  @override
  State<PasswordsFactoryScreen> createState() => _PasswordsFactoryScreenState();
}

class _PasswordsFactoryScreenState extends State<PasswordsFactoryScreen>
    with TickerProviderStateMixin {
  final int minPassLength = 4;
  final int maxPassLength = 32;
  final Color textColor = const Color(0xffdcdbff);
  final double fontSize = 16.0;
  late final TextStyle passwordStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(
        color: Colors.white,
        fontSize: fontSize.sp,
      );
  final double passContainerHeight = 150;
  final Duration passwordSwapAnimationDuration = 150.milliseconds;
  int i = 0;

  final ScrollController scrollController = ScrollController();
  late final ManualListController listController;
  final TextEditingController editController = TextEditingController();
  late final AnimationController copyButtonAniController;
  final PasswordStrengthCheckerService checkerService = PasswordStrengthCheckerService();
  Result? checkResult;
  late void Function(void Function()) setStrengthMeterState;

  bool isEditMode = false;
  late final bool animationsActive;

  late CenteredText currPasswordObj;
  late CenteredText nextPasswordObj;

  String get currentPassword =>
      listController.isAnimating() ? nextPasswordObj.text : currPasswordObj.text;

  /* Password Preferences */
  late int passLength = 16;
  bool includeLowercase = true;
  bool includeUppercase = true;
  bool includeNumbers = true;
  bool includeSpecials = true;

  late bool isOneOptionSet;

  // Widget getPassAnimationTextWidget(String c) {
  Widget getPassAnimationTextWidget(CenteredText c, int i) {
    final String text = c.toString();
    return SizedBox(
      width: fontSize,
      child: Text(
        text[i],
        textAlign: TextAlign.center,
        style: passwordStyle,
      ),
    );
  }

  void generatePassword() {
    String pass = PasswordGeneratorService().generatePassword(
      passLength,
      includeLowercase: includeLowercase,
      includeNumbers: includeNumbers,
      includeSpecials: includeSpecials,
      includeUppercase: includeUppercase,
    );
    checkResult = checkerService.checkPassword(pass);

    swapPasswords(pass);
  }

  void copyPasswordToClipboard() async {
    if (animationsActive) {
      copyButtonAniController.forward(from: 0);
    }
    await Utils.copyToClipboard(currentPassword);
    AnimatedSnackBarMessenger.showSnackBar(
        context,
        AnimatedSnackBar(
          content: const Text("Password copied to clipboard!"),
          alignment: Alignment.bottomCenter,
          padding: EdgeInsets.symmetric(vertical: 17.h),
        ));
  }

  void setEditMode(bool isEdit) {
    setState(() {
      isEditMode = isEdit;
      // if exiting edit mode, update the password
      if (!isEdit) {
        final newPass =
            editController.text.isNotEmpty ? editController.text.trim() : currentPassword;
        currPasswordObj = CenteredText(newPass, maxPassLength);
        checkResult = checkerService.checkPassword(newPass);
        WidgetsBinding.instance.addPostFrameCallback((_) => centerPasswordScroll());
      }
    });
  }

  void swapPasswords(String newPassword) async {
    void onAnimationDone() {
      currPasswordObj = nextPasswordObj;
      i = 0;
    }

    nextPasswordObj = CenteredText(newPassword, maxPassLength);

    centerPasswordScroll();
    if (animationsActive) {
      (await listController.forward(from: 0)).then((_) {
        setState(onAnimationDone);
      });
    } else {
      onAnimationDone();
    }
    setState(() {});
  }

  void centerPasswordScroll() {
    final double target = scrollController.position.maxScrollExtent / 2;
    if (animationsActive) {
      scrollController.animateTo(target, duration: 200.milliseconds, curve: Curves.easeOutExpo);
    } else {
      scrollController.jumpTo(target);
    }
  }

  bool checkIfOneOptionIsSet() {
    return isOneOptionSet = ((includeLowercase ? 1 : 0) +
            (includeUppercase ? 1 : 0) +
            (includeNumbers ? 1 : 0) +
            (includeSpecials ? 1 : 0)) <=
        1;
  }

  @override
  void initState() {
    super.initState();

    Animate.restartOnHotReload = true;
    listController = ManualListController(
        controllers: List.generate(maxPassLength, (_) => AnimationController(vsync: this)));
    copyButtonAniController = AnimationController(vsync: this);
    currPasswordObj = CenteredText(r" ", maxPassLength);
    nextPasswordObj = CenteredText(r" ", maxPassLength);

    animationsActive =
        GlobalSettingsService().getSetting(GlobalSettingsService.useAnimations) as bool;

    checkIfOneOptionIsSet();
    WidgetsBinding.instance.addPostFrameCallback((_) => generatePassword());
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
    listController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xff455a64),
      appBar: AppBar(
        title: Text(
          "Passwords Factory",
          style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(color: textColor),
        ),
        backgroundColor: const Color(0xff455a64),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              AnimatedSnackBarMessenger.showSnackBar(
                  context,
                  AnimatedSnackBar.bounce(
                    heightFactor: .7,
                    padding: EdgeInsets.zero,
                    delay: 1.seconds,
                    alignment: Alignment.bottomCenter,
                    content: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.info_outline, color: Colors.pinkAccent),
                        const SizedBox(width: 8),
                        Text(
                          "Connection lost. Data may be outdated.\n"
                          "Editing is not available while offline.",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.pinkAccent),
                        ),
                      ],
                    ),
                  ));
            },
            child: const Text(""),
          ),
        ],
      ),
      body: ListView(
        children: [
          StripedContainer(
            width: 100.w,
            height: passContainerHeight,
            spacing: 5,
            lineWidth: 6,
            lineColor: Colors.blueGrey.shade700,
            bgColor: Colors.blueGrey.shade900,
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                isEditMode
                    ? SizedBox(
                        width: 95.w,
                        height: passContainerHeight,
                        child: Center(
                          child: TextField(
                            controller: editController..text = currentPassword,
                            autofocus: true,
                            decoration: InputDecoration(
                                suffixIconColor: Colors.white,
                                suffixIcon: IconButton(
                                  onPressed: () => setEditMode(false),
                                  icon: const Icon(Icons.done),
                                ),
                                fillColor: Colors.transparent,
                                enabledBorder: InputBorder.none,
                                border: InputBorder.none,
                                counterText: "",
                                contentPadding: const EdgeInsets.only(left: 56, top: 16)),
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                checkResult = checkerService.checkPassword(value);
                              } else {
                                checkResult = Result()..score = 1;
                              }
                              setStrengthMeterState(() {});
                            },
                            onTapOutside: (_) => setEditMode(false),
                            onSubmitted: (_) => setEditMode(false),
                            style: passwordStyle.copyWith(letterSpacing: 5),
                            textAlign: TextAlign.center,
                            maxLength: maxPassLength,
                            keyboardType: TextInputType.visiblePassword,
                            cursorColor: textColor,
                          ),
                        ),
                      )
                    : SizedBox(
                        width: 80.w,
                        child: GestureDetector(
                          onTap: () => setEditMode(true),
                          child: FadingEdgeScrollView.fromScrollView(
                            child: ListView(
                              controller: scrollController,
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              padding: EdgeInsets.only(top: passContainerHeight / 2 - fontSize / 2),
                              children: ManualAnimatedList(
                                listController: listController,
                                interval: (0.5 / maxPassLength).seconds,
                                onPlay: (controller) => controller.stop(),
                                effects: [
                                  SlideEffect(
                                      end: const Offset(0, -.2),
                                      curve: Curves.easeIn,
                                      duration: passwordSwapAnimationDuration),
                                  FadeEffect(
                                      begin: 1, end: 0, duration: passwordSwapAnimationDuration),
                                  SwapEffect(
                                      delay: passwordSwapAnimationDuration,
                                      builder: (_, __) {
                                        return getPassAnimationTextWidget(
                                                nextPasswordObj, i++ % nextPasswordObj.length)
                                            .animate()
                                            .fadeIn(duration: passwordSwapAnimationDuration)
                                            .slideY(
                                                begin: .2,
                                                curve: Curves.easeOutExpo,
                                                duration: passwordSwapAnimationDuration);
                                      })
                                ],
                                children: List.generate(currPasswordObj.length,
                                    (i) => getPassAnimationTextWidget(currPasswordObj, i)),
                              ),
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // password score
          StatefulBuilder(
            builder: (context, setState) {
              setStrengthMeterState = setState;
              return PasswordStrengthSlider(value: checkResult != null ? checkResult!.score! : 1);
            },
          ),
          const Divider(height: 25),

          // length meter
          Padding(
            padding: EdgeInsets.symmetric(horizontal: pageMargin),
            child: Text(
              "Password length",
              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: textColor),
            ),
          ),
          PasswordLengthMeter(
            minValue: minPassLength,
            maxValue: maxPassLength,
            value: passLength,
            onChanged: (val) => passLength = val,
          ),

          // options
          CheckboxListTile(
            enabled: !(includeLowercase && isOneOptionSet),
            value: includeLowercase,
            onChanged: (val) => setState(() {
              if (val == null || val) {
                includeLowercase = val ?? includeLowercase;
                checkIfOneOptionIsSet();
              } else if (!isOneOptionSet) {
                includeLowercase = false;
                checkIfOneOptionIsSet();
              }
            }),
            controlAffinity: ListTileControlAffinity.leading,
            title: Text("lowercase",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(color: textColor)),
          ),
          CheckboxListTile(
            enabled: !(includeUppercase && isOneOptionSet),
            value: includeUppercase,
            onChanged: (val) => setState(() {
              if (val == null || val) {
                includeUppercase = val ?? includeUppercase;
                checkIfOneOptionIsSet();
              } else if (!isOneOptionSet) {
                includeUppercase = false;
                checkIfOneOptionIsSet();
              }
            }),
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
              "UPPERCASE",
              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: textColor),
            ),
          ),
          CheckboxListTile(
            enabled: !(includeNumbers && isOneOptionSet),
            value: includeNumbers,
            onChanged: (val) => setState(() {
              if (val == null || val) {
                includeNumbers = val ?? includeNumbers;
                checkIfOneOptionIsSet();
              } else if (!isOneOptionSet) {
                includeNumbers = false;
                checkIfOneOptionIsSet();
              }
            }),
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
              "NUMB3R5",
              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: textColor),
            ),
          ),
          CheckboxListTile(
            enabled: !(includeSpecials && isOneOptionSet),
            value: includeSpecials,
            onChanged: (val) => setState(() {
              if (val == null || val) {
                includeSpecials = val ?? includeSpecials;
                checkIfOneOptionIsSet();
              } else if (!isOneOptionSet) {
                includeSpecials = false;
                checkIfOneOptionIsSet();
              }
            }),
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
              r"$ymb()LS",
              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: textColor),
            ),
          ),

          const SizedBox(height: 70),
        ],
      ),
      floatingActionButton: Visibility(
        visible: !isEditMode,
        child: Padding(
          padding: EdgeInsets.only(bottom: pageMargin / 2),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 60),
                child: Animate(
                  controller: copyButtonAniController,
                  autoPlay: false,
                  effects: [
                    SlideEffect(
                      begin: Offset.zero,
                      end: const Offset(-.13, 0),
                      curve: Curves.easeOut,
                      duration: 260.milliseconds,
                    ),
                    ThenEffect(delay: 100.milliseconds),
                    SlideEffect(
                      begin: const Offset(-.13, 0),
                      end: Offset.zero,
                      curve: Curves.elasticOut,
                      duration: 600.milliseconds,
                    ),
                  ],
                  child: SizedBox(
                    height: 40,
                    child: FittedBox(
                      child: FloatingActionButton.extended(
                        onPressed: copyPasswordToClipboard,
                        backgroundColor: Colors.blueGrey,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: BorderSide(color: textColor, width: 3)),
                        icon: Icon(Icons.copy_rounded, color: textColor),
                        label: Padding(
                          padding: const EdgeInsets.only(right: 45),
                          child: Text(
                            "Copy",
                            style: Theme.of(context)
                                .floatingActionButtonTheme
                                .extendedTextStyle
                                ?.copyWith(color: textColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 100),
                child: SizedBox(
                  height: 40,
                  child: FittedBox(
                    child: FloatingActionButton.extended(
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => EditServiceScreen(
                                Service("", "", currentPassword),
                                createNew: true,
                                hidePassword: true,
                              ))),
                      backgroundColor: Colors.blueGrey,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(color: textColor, width: 3)),
                      label: Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: Row(
                          children: [
                            Text(
                              "Use",
                              style: Theme.of(context)
                                  .floatingActionButtonTheme
                                  .extendedTextStyle
                                  ?.copyWith(color: textColor),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.call_made, color: textColor),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 60,
                width: 60,
                child: FloatingActionButton(
                  onPressed: generatePassword,
                  backgroundColor: Colors.blueGrey,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: textColor, width: 3)),
                  tooltip: "Generate password",
                  child: Icon(Icons.autorenew_rounded, color: textColor),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

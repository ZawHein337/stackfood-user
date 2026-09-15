import 'dart:async';

import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/onboard/controllers/onboard_controller.dart';
import 'package:stackfood_multivendor/features/onboard/domain/models/onboarding_model.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();

  static const Duration _autoRouteDelay = Duration(seconds: 1);
  Timer? _autoRouteTimer;
  bool _autoRouting = false;

  @override
  void initState() {
    super.initState();
    Get.find<OnBoardingController>().getOnBoardingList();
  }

  @override
  void dispose() {
    _autoRouteTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _handleAutoRoute(bool isLastPage) {
    if (isLastPage) {
      if (_autoRouting) return;
      _autoRouting = true;
      _autoRouteTimer?.cancel();
      _autoRouteTimer = Timer(_autoRouteDelay, () {
        if (mounted) _configureToRouteInitialPage();
      });
    } else {
      _autoRouting = false;
      _autoRouteTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: GetBuilder<OnBoardingController>(builder: (onBoardingController) {
          if (onBoardingController.onBoardingList == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final List<OnBoardingModel> onBoardingList = onBoardingController.onBoardingList!;
          bool isLastPage = onBoardingController.selectedIndex >= onBoardingList.length - 1;
          WidgetsBinding.instance.addPostFrameCallback((_) => _handleAutoRoute(isLastPage));
          return Center(child: SizedBox(width: Dimensions.webMaxWidth,
            child: Column(children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(Dimensions.radiusExtraLarge), bottomRight: Radius.circular(Dimensions.radiusExtraLarge)),
                  ),
                  child: Stack(children: [
                    PageView.builder(
                      itemCount: onBoardingList.length,
                      controller: _pageController,
                      itemBuilder: (context, index) {
                        return _OnBoardingImage(image: onBoardingList[index].imageUrl);
                      },
                      onPageChanged: (index) {
                        onBoardingController.changeSelectIndex(index);
                      },
                    ),

                    if (!isLastPage)
                      Positioned(
                        top: Dimensions.paddingLarge,
                        right: Dimensions.paddingSizeExtraOverLarge,
                        child: _SkipButton(onTap: () {
                          _pageController.animateToPage(
                            onBoardingList.length - 1,
                            duration: const Duration(milliseconds: 450),
                            curve: Curves.easeInOut,
                          );
                        }),
                      ),
                  ]),
                ),
              ),

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.surfaceContainer,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 42, 24, 28),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(
                    onBoardingList[onBoardingController.selectedIndex].title.tr,
                    style: context.heading.extraOverLarge.strong,
                    textAlign: TextAlign.center, maxLines: 2,
                  ),
                  const SizedBox(height: Dimensions.paddingSmall),

                  Text(onBoardingList[onBoardingController.selectedIndex].description.tr,
                    style: context.body.defaultSize.overrideWith(color: context.textBaseMedium),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Dimensions.paddingOverLarge*2),

                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    if (!isLastPage) ...[
                      _CircleArrowButton(
                        icon: Icons.arrow_back,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        iconColor: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.6),
                        onTap: () {
                          if (onBoardingController.selectedIndex == 0) {
                            Get.back();
                          } else {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 450),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                      ),
                      const SizedBox(width: 22),
                    ],
                    _NextArrowButton(
                      icon: isLastPage ? Icons.check : Icons.arrow_forward,
                      progress: (onBoardingController.selectedIndex + 1) / onBoardingList.length,
                      onTap: isLastPage ? null : () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 450),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ]),
                ]),
              ),
            ]),
          ));
        }),
      ),
    );
  }

  void _configureToRouteInitialPage() async {
    Get.find<SplashController>().disableIntro();
    await Get.find<AuthController>().guestLogin();
    if (AddressHelper.getAddressFromSharedPref() != null) {
      Get.offNamed(RouteHelper.getInitialRoute(fromSplash: true));
    } else {
      Get.find<SplashController>().navigateToLocationScreen('splash', offNamed: true);
    }
  }
}

class _OnBoardingImage extends StatelessWidget {
  final String image;

  const _OnBoardingImage({required this.image});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, 0.24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: CustomAssetImageWidget(image, height: context.height * 0.26, fit: BoxFit.contain),
      ),
    );
  }
}

class _SkipButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SkipButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      child: InkWell(onTap: onTap,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        child: Container(
          height: 30,
          decoration: BoxDecoration(
            color: context.surfaceContainer,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          ),
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingMedium , vertical: Dimensions.paddingOverSmall),
          child: Center(
            child: Text(
              'skip'.tr,
              style: context.heading.defaultSize.strong,
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleArrowButton extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback? onTap;

  const _CircleArrowButton({required this.icon, required this.backgroundColor, required this.iconColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      shape: const CircleBorder(),
      child: InkWell(onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(width: Dimensions.paddingSizeExtraOverLarge, height: Dimensions.paddingSizeExtraOverLarge,
          child: Icon(icon, color: iconColor, size: Dimensions.fontSizeOverLarge),
        ),
      ),
    );
  }
}

class _NextArrowButton extends StatelessWidget {
  final double progress;
  final VoidCallback? onTap;
  final IconData icon;

  const _NextArrowButton({required this.progress, required this.onTap, this.icon = Icons.arrow_forward});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = context.primary;

    return SizedBox(width: 56, height: 48,
      child: Stack(alignment: Alignment.center, children: [
        SizedBox(width: 42, height: 42,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeInOut,
            builder: (context, value, child) => CircularProgressIndicator(
              value: value,
              strokeWidth: 2,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          ),
        ),
        _CircleArrowButton(
          icon: icon,
          backgroundColor: primaryColor,
          iconColor: context.surfaceContainer,
          onTap: onTap,
        ),
      ]),
    );
  }
}

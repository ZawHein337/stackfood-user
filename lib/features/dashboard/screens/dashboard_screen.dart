import 'dart:async';
import 'dart:io';

import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_dialog_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/cart/screens/cart_bundle_list_screen.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/congratulation_dialogue.dart';
import 'package:stackfood_multivendor/features/dashboard/controllers/dashboard_controller.dart';
import 'package:stackfood_multivendor/features/dashboard/widgets/address_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/dashboard/widgets/bottom_nav_item.dart';
import 'package:stackfood_multivendor/features/notification/controllers/notification_controller.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/search/screens/search_screen.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/features/verification/widgets/login_suggestion_bottomsheet.dart';
import 'package:stackfood_multivendor/features/dashboard/widgets/registration_success_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/dashboard/widgets/running_order_view_widget.dart';
import 'package:stackfood_multivendor/features/home/controllers/home_controller.dart';
import 'package:stackfood_multivendor/features/home/screens/home_screen.dart';
import 'package:stackfood_multivendor/features/loyalty/controllers/loyalty_controller.dart';
import 'package:stackfood_multivendor/features/menu/screens/menu_screen.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/order/domain/models/my_order_model.dart';
import 'package:stackfood_multivendor/features/order/screens/order_screen.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class DashboardScreen extends StatefulWidget {
  final int pageIndex;
  final bool fromSplash;
  const DashboardScreen({super.key, required this.pageIndex, this.fromSplash = false});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  PageController? _pageController;
  int _pageIndex = 0;
  late List<Widget> _screens;
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey();
  bool _canExit = GetPlatform.isWeb ? true : false;
  late bool _isLogin;
  bool active = false;

  @override
  void initState() {
    super.initState();

    _isLogin = Get.find<AuthController>().isLoggedIn();

    Get.find<DashboardController>().registerPageSelector(_setPage);

    _showRegistrationSuccessBottomSheet();
    if(!_isLogin && Get.find<SplashController>().showLoginSuggestion() && (GetPlatform.isAndroid || GetPlatform.isIOS)) {
      Future.delayed(const Duration(milliseconds: 3000), () {
        if(Get.currentRoute == '/?from-splash=false') {
          Get.bottomSheet(LoginSuggestionBottomSheet(), isScrollControlled: true).then((v) {
            Get.find<SplashController>().disableLoginSuggestion();
          });
        }
      });
    }

    if(_isLogin){
      if(Get.find<SplashController>().configModel!.loyaltyPointStatus! && Get.find<LoyaltyController>().getEarningPint().isNotEmpty && !ResponsiveHelper.isDesktop(Get.context)){
        Future.delayed(const Duration(seconds: 1), () => showAnimatedDialog(Get.context!, const CongratulationDialogue()));
      }
      _suggestAddressBottomSheet();
      Get.find<OrderController>().getMyOrders(MyOrderTabType.running, 1, notify: false);
    }

    _pageIndex = widget.pageIndex;

    _pageController = PageController(initialPage: widget.pageIndex);

    _screens = [
      const HomeScreen(),
      const OrderScreen(),
      const CartBundleListScreen(fromNav: true),
      const SearchScreen(fromNav: true),
      const MenuScreen(),
    ];

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {});
    });

  }

  @override
  void dispose() {
    Get.find<DashboardController>().removePageSelector(_setPage);
    _pageController?.dispose();
    super.dispose();
  }

  void _showRegistrationSuccessBottomSheet() {
    bool canShowBottomSheet = Get.find<DashboardController>().getRegistrationSuccessfulSharedPref();
    if(canShowBottomSheet) {
      Future.delayed(const Duration(seconds: 1), () {
        ResponsiveHelper.isDesktop(Get.context) ? Get.dialog(const Dialog(child: RegistrationSuccessBottomSheet())).then((value) {
          Get.find<DashboardController>().saveRegistrationSuccessfulSharedPref(false);
          Get.find<DashboardController>().saveIsRestaurantRegistrationSharedPref(false);
          setState(() {});
        }) : showModalBottomSheet(
          context: Get.context!, isScrollControlled: true, backgroundColor: Colors.transparent,
          builder: (con) => const RegistrationSuccessBottomSheet(),
        ).then((value) {
          Get.find<DashboardController>().saveRegistrationSuccessfulSharedPref(false);
          Get.find<DashboardController>().saveIsRestaurantRegistrationSharedPref(false);
          setState(() {});
        });
      });
    }
  }

  Future<void> _suggestAddressBottomSheet() async {
    active = await Get.find<DashboardController>().checkLocationActive();
    if(widget.fromSplash && Get.find<DashboardController>().showLocationSuggestion && active){
      Future.delayed(const Duration(seconds: 1), () {
        showModalBottomSheet(
          context: Get.context!, isScrollControlled: true, backgroundColor: Colors.transparent,
          builder: (con) => const AddressBottomSheet(),
        ).then((value) {
          Get.find<DashboardController>().hideSuggestedLocation();
          setState(() {});
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) async{
        debugPrint('$_canExit');
        if (_pageIndex != 0) {
          _setPage(0);
        } else {
          if(_canExit) {
            if (GetPlatform.isAndroid) {
              SystemNavigator.pop();
            } else if (GetPlatform.isIOS) {
              exit(0);
            }
          }
          if(!ResponsiveHelper.isDesktop(context)) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('back_press_again_to_exit'.tr, style: const TextStyle(color: Colors.white)),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              margin: const EdgeInsets.all(Dimensions.paddingSmall),
            ));
          }
          _canExit = true;

          Timer(const Duration(seconds: 2), () {
            _canExit = false;
          });
        }
      },
      child: Scaffold(
        key: _scaffoldKey,

        bottomNavigationBar: ResponsiveHelper.isDesktop(context) ? const SizedBox() : GetBuilder<OrderController>(builder: (orderController) {
          final bool hidden = orderController.runningSheetVisible;
          return hidden ? const SizedBox() : Container(
            decoration: BoxDecoration(
              color: context.surfaceContainer,
              border: Border(top: BorderSide(color: context.outline, width: 1)),
            ),
            child: SafeArea(top: false,
              child: LayoutBuilder(builder: (context, constraints) {
                const int itemCount = 5;
                const double spacing = Dimensions.paddingDefault;
                const double horizontalPadding = Dimensions.padding2xSmall;
                const double indicatorWidth = 28;
                final double itemWidth = (constraints.maxWidth - (horizontalPadding * 2) - (spacing * (itemCount - 1))) / itemCount;
                final double indicatorStart = horizontalPadding + (_pageIndex * (itemWidth + spacing)) + ((itemWidth - indicatorWidth) / 2);

                return ClipRect(child: Stack(children: [

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Row( spacing: spacing, children: [
                      BottomNavItem(title: 'home'.tr, isSelected: _pageIndex == 0, onTap: () => _setPage(0),
                        icon: _navImage(Images.navHome, Images.navHomeSelected, _pageIndex == 0)),

                      BottomNavItem(title: 'orders'.tr, isSelected: _pageIndex == 1, onTap: () => _setPage(1),
                        icon: _navImage(Images.navOrder, Images.navOrderSelected, _pageIndex == 1)),

                      BottomNavItem(title: 'cart'.tr, isSelected: _pageIndex == 2, onTap: () => _setPage(2),
                        icon: _cartIcon(_pageIndex == 2), isCart: true,),

                      BottomNavItem(title: 'search'.tr, isSelected: _pageIndex == 3, onTap: () => _setPage(3),
                        icon: _navImage(Images.search, Images.searchIconSelected, _pageIndex == 3)),

                      BottomNavItem(title: 'profile'.tr, isSelected: _pageIndex == 4, onTap: () => _setPage(4),
                        icon: _profileIcon(_pageIndex == 4)),
                    ]),
                  ),

                  AnimatedPositionedDirectional(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    top: 0, start: indicatorStart,
                    child: Container(
                      height: 3, width: indicatorWidth,
                      decoration: BoxDecoration(
                        color: context.primary,
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
                      ),
                    ),
                  ),

                ]));
              }),
            ),
          );
        }),
        body: GetBuilder<OrderController>(
        builder: (orderController) {
          List<MyOrderModel> runningOrder = orderController.runningOrders ?? [];

          List<MyOrderModel> reversOrder =  List.from(runningOrder.reversed);
          return ExpandableBottomSheet(
            background: PageView.builder(
              controller: _pageController,
              itemCount: _screens.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return _screens[index];
              },
            ),
            persistentContentHeight: 100,

            onIsContractedCallback: () {
              if(!orderController.showOneOrder) {
                orderController.showOrders();
              }
            },
            onIsExtendedCallback: () {
              if(orderController.showOneOrder) {
                orderController.showOrders();
              }
            },

            enableToggle: true,

            expandableContent: !orderController.runningSheetVisible ? const SizedBox()
              : Dismissible(
                key: UniqueKey(),
                onDismissed: (direction) {
                  if(orderController.showBottomSheet){
                    orderController.showRunningOrders();
                  }
                },
                child: RunningOrderViewWidget(reversOrder: reversOrder, onMoreClick: () {
                  if(orderController.showBottomSheet){
                    orderController.showRunningOrders();
                  }
                  _setPage(1);
                }),
              ),
          );
        }
                ),
      ),
    );
  }

  void _setPage(int pageIndex) {
    setState(() {
      _pageController!.jumpToPage(pageIndex);
      _pageIndex = pageIndex;
    });

    if (pageIndex == 0) {
      Get.find<HomeController>().startSearchHintTimer();
    } else {
      Get.find<HomeController>().stopSearchHintTimer();
    }
  }

  Widget _navImage(String image, String selectedImage, bool selected) {
    return CustomAssetImageWidget(
      selected ? selectedImage : image,
      height: 20, width: 20,
      color: selected ? context.primary : context.iconBaseMedium,
    );
  }

  Widget _cartIcon(bool selected) {
    final Color color = selected ? context.primary : context.iconBaseMedium;
    return Stack(clipBehavior: Clip.none, children: [
      Icon(selected ? Icons.shopping_cart : Icons.shopping_cart_outlined, size: 24, color: color),

      GetBuilder<CartController>(builder: (cartController) {
        return cartController.itemCountOfGlobalCart() > 0 ? Positioned(
          top: -4, right: -6,
          child: Container(
            height: 14, width: 14, alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle, color: context.primary,
              border: Border.all(width: 1, color: context.surfaceContainer),
            ),
            child: Text(
              cartController.itemCountOfGlobalCart().toString(),
              style: context.body.extraSmall.regular.overrideWith(color: context.surfaceContainer).copyWith(fontSize: 8),
            ),
          ),
        ) : const SizedBox();
      }),
    ]);
  }

  Widget _profileIcon(bool selected) {
    final bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
    return GetBuilder<NotificationController>(builder: (notificationController) {
      return GetBuilder<ProfileController>(builder: (profileController) {
        return Center(
          child: Stack(clipBehavior: Clip.none, children: [
            Container(
              height: 21,
              width: 21,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: selected ? Border.all(color: selected ? context.primary : Colors.transparent, width: 1) : null,
              ),
              child: ClipOval(
                child: CustomImageWidget(
                  placeholder: isLoggedIn ? Images.profilePlaceholder : Images.guestIcon,
                  image: '${(profileController.userInfoModel != null && isLoggedIn) ? profileController.userInfoModel!.imageFullUrl : ''}',
                  height: 21, width: 21, fit: BoxFit.cover,
                ),
              ),
            ),

            if(isLoggedIn && notificationController.hasNotification) Positioned(
              top: -1, right: -1,
              child: Container(
                height: 9, width: 9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, color: context.primary,
                  border: Border.all(color: context.surfaceContainer, width: 1),
                ),
              ),
            ),
          ]),
        );
      });
    });
  }
}

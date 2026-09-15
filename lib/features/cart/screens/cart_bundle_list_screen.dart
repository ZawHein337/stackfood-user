import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/confirmation_dialog_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/cart/screens/cart_bundle_widget.dart';
import 'package:stackfood_multivendor/features/dashboard/controllers/dashboard_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/adaptive_dialog_widget.dart';

class CartBundleListScreen extends StatefulWidget {
  final bool fromNav;
  const CartBundleListScreen({super.key, this.fromNav = false});

  @override
  State<CartBundleListScreen> createState() => _CartBundleListScreenState();
}

class _CartBundleListScreenState extends State<CartBundleListScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      Get.find<CartController>().getCartBundleList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBarWidget(
        title: 'cart_list'.tr,
        isBackButtonExist: true,
        centerTitle: false,
        onBackPressed: widget.fromNav ? () => Get.find<DashboardController>().selectTab(0) : null,
        actions: [
          GetBuilder<CartController>(builder: (cartController) {
            if (cartController.cartBundleList.isEmpty) {
              return const SizedBox();
            }
            return TextButton(
              onPressed: cartController.isClearingAll ? null : () => _confirmClearAll(),
              child: cartController.isClearingAll
                ? SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: context.primary))
                : Text('clear_all'.tr, style: context.body.defaultSize.medium.overrideWith(color: context.primary)),
            );
          }),
          const SizedBox(width: Dimensions.paddingSmall),
        ],
      ),
      body: GetBuilder<CartController>(builder: (cartController) {

        if (cartController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final list = cartController.cartBundleList;
        if (list.isEmpty) {
          return const _EmptyCartBundleWidget();
        }

        final bool isDesktop = ResponsiveHelper.isDesktop(context);
        return RefreshIndicator(
          onRefresh: () => cartController.getCartBundleList(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              child: Column(children: [

                Center(
                  child: SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: isDesktop
                      ? GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: list.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisExtent: 230,
                          ),
                          itemBuilder: (context, index) {
                            return CartBundleWidget(cartBundleWidget: list[index]);
                          },
                        )
                      : ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            return CartBundleWidget(cartBundleWidget: list[index]);
                          },
                        ),
                  ),
                ),

              ]),
            ),
          ),
        );
      }),
    );
  }

  void _confirmClearAll() {
    showCustomDialog(
      child: ConfirmationDialogWidget(
      icon: Images.warning,
      title: 'are_you_sure_to_delete'.tr,
      description: 'all_items_will_be_removed_from_your_cart'.tr,
      isLogOut: true,
      isDelete: true,
      onYesPressed: () {
        Get.back();
        Get.find<CartController>().clearAllCartBundles();
      },
    ),
      isDismissible: false,
    );
  }
}

class _EmptyCartBundleWidget extends StatelessWidget {
  const _EmptyCartBundleWidget();

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveHelper.isDesktop(context);
    final double imageSize = isDesktop ? 130 : 100;

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(Dimensions.paddingLarge),
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          CustomAssetImageWidget(Images.emptyCart, width: imageSize, height: imageSize, fit: BoxFit.contain),
          const SizedBox(height: Dimensions.paddingLarge),

          Text(
            'cart_is_empty'.tr,
            style: context.heading.large.strong,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Dimensions.paddingExtraSmall),

          Text(
            'you_have_not_add_to_cart_yet'.tr,
            style: context.body.defaultSize.regular,
            textAlign: TextAlign.center,
          ),

        ]),
      ),
    );
  }
}

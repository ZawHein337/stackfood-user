import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/payment_failed_dialog.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/pro_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/adaptive_dialog_widget.dart';


class OrderSuccessfulScreen extends StatefulWidget {
  final String? orderID;
  final int status;
  final double? totalAmount;
  final String? contactPersonNumber;
  final bool isDeliveryOrder;
  final double? proDiscount;
  const OrderSuccessfulScreen({super.key, required this.orderID, required this.status, required this.totalAmount, this.contactPersonNumber, this.isDeliveryOrder = false, this.proDiscount});

  @override
  State<OrderSuccessfulScreen> createState() => _OrderSuccessfulScreenState();
}

class _OrderSuccessfulScreenState extends State<OrderSuccessfulScreen> {
  String? orderId;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    orderId = widget.orderID!;
    if(widget.orderID != null) {
      if(widget.orderID!.contains('?')){
        var parts = widget.orderID!.split('?');
        String id = parts[0].trim();
        orderId = id;
      }
    }
    Get.find<OrderController>().trackOrder(orderId.toString(), null, false, contactNumber: widget.contactPersonNumber);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaceContainer,
      body: GetBuilder<OrderController>(builder: (orderController) {
        double total = 0;
        bool success = true;
        double? maximumCodOrderAmount;
        if(orderController.trackModel != null) {
          final address = AddressHelper.getAddressFromSharedPref();

          if(address?.zoneData != null && address!.zoneId != null) {
            final matchingZones = address.zoneData!.where((data) => data.id == address.zoneId).toList();
            if(matchingZones.isNotEmpty) {
              maximumCodOrderAmount = matchingZones.first.maxCodOrderAmount;
            }
          }

          total = ((orderController.trackModel!.orderAmount! / 100) * Get.find<SplashController>().configModel!.loyaltyPointItemPurchasePoint!);
          success = orderController.trackModel!.paymentStatus == 'paid' || orderController.trackModel!.paymentMethod == 'cash_on_delivery' || orderController.trackModel!.paymentMethod == 'partial_payment';

          if (!success && !Get.isDialogOpen! && orderController.trackModel!.orderStatus != 'canceled' && Get.currentRoute.startsWith(RouteHelper.orderSuccess)) {
            Future.delayed(const Duration(seconds: 1), () {
              showCustomDialog(
                child: PaymentFailedDialog(orderID: orderId, orderAmount: widget.totalAmount, maxCodOrderAmount: maximumCodOrderAmount, contactPersonNumber: widget.contactPersonNumber),
                isDismissible: false,
              );
            });
          }
        }

        return orderController.trackModel != null ? Center(child: SingleChildScrollView(
          controller: scrollController,
          child: SizedBox(
            child: SizedBox(width: Dimensions.webMaxWidth, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

              CustomAssetImageWidget(success ? Images.checked : Images.warning, width: 100, height: 100),
              const SizedBox(height: Dimensions.paddingLarge),

              Text(
                success ? 'you_placed_the_order_successfully'.tr : 'your_order_is_failed_to_place'.tr,
                style: context.heading.large.medium,
              ),
              const SizedBox(height: Dimensions.paddingSmall),

              Text.rich(
                TextSpan(
                  text: '${'order_id'.tr}: ',
                  style: context.heading.large.strong.overrideWith(color: context.textBaseDefault),
                  children: [
                    TextSpan(text: '$orderId', style: context.heading.large.strong.overrideWith(color: context.primary)),
                  ],
                ),
              ),

              if(ProHelper.userProStatus && (widget.proDiscount ?? 0) > 0.0) ...[
                const SizedBox(height: Dimensions.paddingSmall,),
                Text(
                  '${'you_saved'.tr} ${PriceConverter.convertPrice(widget.proDiscount)} ${'with_pro'.tr}',
                  style: context.subHeading.defaultSize.medium.overrideWith(color: Colors.deepPurpleAccent),
                ),
                const SizedBox(height: Dimensions.paddingSmall,)
              ],

              SizedBox(height: Dimensions.paddingLarge,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.paddingSmall),
                child: Text(
                  success ? widget.isDeliveryOrder ? 'your_order_is_placed_successfully'.tr : 'your_order_is_placed_successfully_dine_in_and_takeaway'.tr : 'your_order_is_failed_to_place_because'.tr,
                  style: context.subHeading.small.medium.overrideWith(color: context.textBaseMedium),
                  textAlign: TextAlign.center,
                ),
              ),

              Get.find<AuthController>().isLoggedIn() && ResponsiveHelper.isDesktop(context) && (success && Get.find<SplashController>().configModel!.loyaltyPointStatus! && total.floor() > 0 )  ? Column(children: [

                CustomAssetImageWidget(Get.find<ThemeController>().darkTheme ? Images.giftBox1 : Images.giftBox, width: 150, height: 150),

                Text('congratulations'.tr , style: context.heading.large.medium),
                const SizedBox(height: Dimensions.paddingSmall),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                  child: Text(
                    '${'you_have_earned'.tr} ${total.floor().toString()} ${'points_it_will_add_to'.tr}',
                    style: context.body.large.regular.overrideWith(color: context.textBaseMedium),
                    textAlign: TextAlign.center,
                  ),
                ),

              ]) : const SizedBox.shrink() ,
              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingLarge),
                child: CustomButtonWidget(
                  width: ResponsiveHelper.isDesktop(context) ? 300 : double.infinity,
                  buttonText: 'back_to_home'.tr,
                  onPressed: () => Get.offAllNamed(RouteHelper.getInitialRoute()),
                ),
              ),

            ])),
          ),
        )) : const Center(child: CircularProgressIndicator());
      }),
    );
  }
}

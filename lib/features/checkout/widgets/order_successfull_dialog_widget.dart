import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/payment_failed_dialog.dart';
import 'package:stackfood_multivendor/features/location/domain/models/zone_response_model.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/pro_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/adaptive_dialog_widget.dart';

class OrderSuccessfulDialogWidget extends StatefulWidget {
  final String? orderID;
  final String? contactNumber;
  final bool isDeliveryOrder;
  final double? proDiscount;
  const OrderSuccessfulDialogWidget({super.key, required this.orderID, this.contactNumber, this.isDeliveryOrder = false, this.proDiscount});

  @override
  State<OrderSuccessfulDialogWidget> createState() => _OrderSuccessfulDialogWidgetState();
}

class _OrderSuccessfulDialogWidgetState extends State<OrderSuccessfulDialogWidget> {

  @override
  void initState() {
    super.initState();
    Get.find<OrderController>().trackOrder(widget.orderID.toString(), null, false, contactNumber: widget.contactNumber);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) async{
        await Get.offAllNamed(RouteHelper.getInitialRoute());
      },
      child: GetBuilder<OrderController>(builder: (orderController){
          double total = 0;
          bool success = true;
          double? maximumCodOrderAmount;
          if(orderController.trackModel != null) {
            ZoneData zoneData = AddressHelper.getAddressFromSharedPref()!.zoneData!.firstWhere((data) => data.id == AddressHelper.getAddressFromSharedPref()!.zoneId);
            maximumCodOrderAmount = zoneData.maxCodOrderAmount;
            total = ((orderController.trackModel!.orderAmount! / 100) * Get.find<SplashController>().configModel!.loyaltyPointItemPurchasePoint!);
            success = orderController.trackModel!.paymentStatus == 'paid' || orderController.trackModel!.paymentMethod == 'cash_on_delivery' || orderController.trackModel!.paymentMethod == 'partial_payment';

            if (!success && !Get.isDialogOpen! && orderController.trackModel!.orderStatus != 'canceled' && Get.currentRoute.startsWith(RouteHelper.orderSuccess)) {
              Future.delayed(const Duration(seconds: 1), () {
                showCustomDialog(
                  child: PaymentFailedDialog(orderID: widget.orderID, orderAmount: total, maxCodOrderAmount: maximumCodOrderAmount),
                  isDismissible: false,
                );
              });
            }
          }

          return orderController.trackModel != null ? Center(
            child: Container(
              width: 500,  height: 390,
              decoration: BoxDecoration(
                color: context.surfaceContainer,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault)
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                ResponsiveHelper.isDesktop(context) ? Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.clear),
                  ),
                ) : const SizedBox(),

                const SizedBox(height: Dimensions.paddingExtraLarge),
                CustomAssetImageWidget(success ? Images.checked : Images.warning, width: 55, height: 55 ),
                const SizedBox(height: Dimensions.paddingLarge),

                Text(
                  success ? 'you_placed_the_order_successfully'.tr : 'your_order_is_failed_to_place'.tr,
                  style: context.heading.large.medium,
                ),
                const SizedBox(height: Dimensions.paddingDefault),
                Text(
                  '${'order_id'.tr}: ${widget.orderID}',
                  style: context.heading.large.medium.overrideWith(color: context.primary),
                ),
                const SizedBox(height: Dimensions.paddingDefault),

                if(ProHelper.userProStatus && (widget.proDiscount ?? 0) > 0.0) ...[
                  const SizedBox(height: Dimensions.paddingSmall,),
                  Text(
                    '${'you_saved'.tr} ${PriceConverter.convertPrice(widget.proDiscount)} ${'with_pro'.tr}',
                    style: context.subHeading.defaultSize.medium.overrideWith(color: Colors.deepPurpleAccent),
                  ),
                  const SizedBox(height: Dimensions.paddingSmall,)
                ],

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.paddingSmall),
                  child: Text(
                    success ? widget.isDeliveryOrder ? 'your_order_is_placed_successfully'.tr : 'your_order_is_placed_successfully_dine_in_and_takeaway'.tr : 'your_order_is_failed_to_place_because'.tr,
                    style: context.body.small.medium.overrideWith(color: context.textBaseMedium),
                    textAlign: TextAlign.center,
                  ),
                ),

            ])),
          ) : const Center(child: CircularProgressIndicator());
        })
    );
  }
}
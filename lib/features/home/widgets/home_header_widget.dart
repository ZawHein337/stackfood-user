import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/features/dashboard/controllers/dashboard_controller.dart';
import 'package:stackfood_multivendor/features/dashboard/widgets/address_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class HomeHeaderWidget extends StatefulWidget {
  const HomeHeaderWidget({super.key});

  @override
  State<HomeHeaderWidget> createState() => _HomeHeaderWidgetState();
}

class _HomeHeaderWidgetState extends State<HomeHeaderWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: Dimensions.webMaxWidth,
        color: context.surface,
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.paddingSmall),
        child: Row(spacing: Dimensions.paddingSmall, children: [

          CustomAssetImageWidget(Images.logo, height: 36, width: 36),

          Expanded(child: InkWell(
            onTap: () async{
             await Future.delayed(const Duration(seconds: 1), () {
                showModalBottomSheet(
                  context: Get.context!, isScrollControlled: true, backgroundColor: Colors.transparent,
                  builder: (con) => const AddressBottomSheet(),
                ).then((value) {
                  Get.find<DashboardController>().hideSuggestedLocation();
                  setState(() {});
                });
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall),
              child: GetBuilder<LocationController>(builder: (locationController) {
                return Column(mainAxisSize: MainAxisSize.min, children: [

                  Text(
                    'deliver_to'.tr,
                    style: context.subHeading.small.regular.overrideWith(color: context.textBaseDefault),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraOverLarge),
                    child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.location_on_outlined, size: 14, color: context.textBaseDefault),
                      const SizedBox(width: Dimensions.padding2xSmall),

                      Flexible(child: Text(
                        AddressHelper.getAddressFromSharedPref()?.address ?? 'not_set_yet'.tr,
                        style: context.heading.small.overrideWith(color: context.textBaseDefault),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      )),

                      Icon(Icons.keyboard_arrow_down, size: 18, color: context.textBaseDefault),
                    ]),
                  ),

                ]);
              }),
            ),
          )),

          InkWell(
            onTap: () => Get.toNamed(RouteHelper.getFavouriteScreen()),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.padding2xSmall),
              child: CustomAssetImageWidget(
                Images.navFavourite, height: 20, width: 20, fit: BoxFit.contain,
                color: context.textBaseDefault,
              ),
            ),
          ),

     ]),

    );
  }
}

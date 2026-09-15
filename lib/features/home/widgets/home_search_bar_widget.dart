import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/features/home/controllers/home_controller.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class HomeSearchBarWidget extends StatelessWidget {
  final double progress;
  const HomeSearchBarWidget({super.key, this.progress = 0});

  @override
  Widget build(BuildContext context) {
    final double t = progress.clamp(0.0, 1.0);
    final Color shadowColor = context.shadow;
    final double shadowOpacity = (1 - t).clamp(0.0, 1.0);
    const double searchbarHeight = 40;

    return Container(
      height: double.infinity,
      width: Dimensions.webMaxWidth,
      decoration: BoxDecoration(
        color: Color.lerp(context.surface, context.surfaceContainer, t),
      ),
      child: Center(
        child: InkWell(
          onTap: () => Get.toNamed(RouteHelper.getSearchRoute()),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          child: Container(
            height: searchbarHeight,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
            margin: const EdgeInsets.fromLTRB(
              Dimensions.paddingLarge,
              Dimensions.paddingLarge,
              Dimensions.paddingLarge,
              Dimensions.paddingMedium,
            ),
            decoration: BoxDecoration(
              color: Color.lerp(context.surfaceContainer, Theme.of(context).colorScheme.surface, t),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              boxShadow: shadowOpacity == 0 ? null : [
                BoxShadow(color: shadowColor.withValues(alpha: shadowColor.a * shadowOpacity), spreadRadius: 1, blurRadius: 12, offset: const Offset(0, 0)),
                BoxShadow(color: shadowColor.withValues(alpha: shadowColor.a * shadowOpacity), spreadRadius: 0, blurRadius: 2, offset: const Offset(0, 0)),
              ],
            ),
            child: Row(children: [

              CustomAssetImageWidget(Images.search, height: 16, width: 16, color: context.iconBaseDefault),
              const SizedBox(width: Dimensions.paddingSmall),

              Text(
                "${'search_for'.tr} ",
                style: context.body.defaultSize.overrideWith(color: context.textBaseLight),
              ),

              Expanded(child: GetBuilder<HomeController>(id: 'search_hint', builder: (homeController) {
                return Text(
                  "'${homeController.currentSearchHint}'",
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: context.subHeading.defaultSize.strong.overrideWith(color: context.textBaseMedium),
                );
              })),

            ]),
          ),
        ),
      ),
    );
  }
}

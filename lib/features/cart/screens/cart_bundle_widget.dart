import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/bogo_item_group_widget.dart';
import 'package:stackfood_multivendor/common/widgets/confirmation_dialog_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_bundle_model.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/restaurant_verified_icon_widget.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

import '../../../common/models/restaurant_model.dart' as restaurant_common;
import 'package:stackfood_multivendor/common/widgets/adaptive_dialog_widget.dart';

class CartBundleWidget extends StatelessWidget {
  final CartBundleModel cartBundleWidget;
  const CartBundleWidget({super.key, required this.cartBundleWidget});

  @override
  Widget build(BuildContext context) {
    final Restaurant? restaurant = cartBundleWidget.restaurant;
    if (restaurant == null) {
      return const SizedBox();
    }

    final carts = cartBundleWidget.carts ?? [];
    final bool hasBogoBundle = carts.any((cart) => cart.isBogoBundle);

    final visibleCarts = hasBogoBundle ? carts.where((cart) => cart.isBogoBundle).toList() : carts;
    final int collapsedItemCount = carts.length - visibleCarts.length;

    return GetBuilder<CartController>(builder: (cartController) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault, vertical: Dimensions.paddingSmall),
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Padding(
          padding: const EdgeInsets.all(Dimensions.paddingDefault),
          child: Row(
            children: [
              Expanded(
                child: Row(children: [

                  ClipOval(
                    child: CustomImageWidget(
                      image: restaurant.logoFullUrl ?? '',
                      height: 32, width: 32, isRestaurant: true,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSmall),

                  Flexible(
                    child: Row(
                      children: [
                        Flexible(
                          child: InkWell(
                            onTap: () => _openRestaurant(restaurant),
                            child: Text(
                              restaurant.name ?? '',
                              style: context.subHeading.defaultSize.medium,
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),

                        if(restaurant.verifiedSeller == true) ...[
                          const SizedBox(width: Dimensions.padding2xSmall),
                          const RestaurantVerifiedIconWidget(),
                        ],

                      ],
                    ),
                  ),
                  const SizedBox(width: Dimensions.padding2xSmall),

                  Text(
                    '(${restaurant.itemCount ?? 0})',
                    style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
                  ),


                ]),
              ),

              PopupMenuButton<String>(
                tooltip: '',
                padding: EdgeInsets.zero,
                color: context.surfaceContainer,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall)),
                enabled: !(cartController.isDeleting && cartController.deletingRestaurantId == restaurant.id),
                icon: cartController.isDeleting && cartController.deletingRestaurantId == restaurant.id
                    ? Icon(Icons.more_vert, size: 22, color: context.iconBaseMedium)
                    : Icon(Icons.more_vert, size: 22, color: context.iconBaseMedium),
                onSelected: (value) {
                  if (value == 'delete') {
                    _confirmDelete(context, restaurant.id!);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'delete',
                    height: 30,
                    child: Row(children: [
                      Icon(Icons.delete_outline, size: 18, color: Theme.of(context).colorScheme.error),
                      const SizedBox(width: Dimensions.paddingSmall),
                      Text(
                        'delete'.tr,
                        style: context.body.small.medium.overrideWith(color: context.error),
                      ),
                    ]),
                  ),
                ],
              ),
            ],
          ),
        ),

        if (visibleCarts.isNotEmpty) SizedBox(
          height: hasBogoBundle ? 100 : 70,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
            itemCount: visibleCarts.length,
            separatorBuilder: (context, index) => const SizedBox(width: Dimensions.paddingSmall),
            itemBuilder: (context, index) {
              final cart = visibleCarts[index];

              if(cart.isBogoBundle) {
                return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  Text(
                    cart.bogoDetails!.offerTitle ?? 'bogo_offer'.tr,
                    style: context.heading.defaultSize.medium,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: Dimensions.paddingMedium),
                
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    BogoItemGroupWidget(label: 'buying_item'.tr, thumbnails: cart.bogoDetails!.buyItemThumbnails),
                    const SizedBox(width: Dimensions.paddingDefault),
                    BogoItemGroupWidget(label: 'free_item'.tr, thumbnails: cart.bogoDetails!.freeItemThumbnails),

                    if(collapsedItemCount > 0 && index == visibleCarts.length - 1) ...[
                      const SizedBox(width: Dimensions.paddingDefault),
                      _MoreItemsBadge(count: collapsedItemCount),
                    ],
                  ]),
                ]);
              }

              return ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                child: CustomImageWidget(
                  image: cart.product?.imageFullUrl ?? '',
                  height: 70, width: 70, isFood: true,
                  placeholder: Images.foodPlaceholder,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: Dimensions.paddingDefault),

        Divider(height: 1, color: context.outlineVariant),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault, vertical: Dimensions.paddingSmall),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

            CustomInkWellWidget(
              onTap: () => _openRestaurant(restaurant),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.add_circle_outline, color: context.primary, size: 20),
                const SizedBox(width: Dimensions.padding2xSmall),
                Text(
                  'add_more_items'.tr,
                  style: context.body.small.medium.overrideWith(color: context.primary),
                ),
              ]),
            ),

            CustomButtonWidget(
              width: 100,
              height: 40,
              onPressed: () {
                Get.toNamed(
                  RouteHelper.getRestaurantRoute(restaurant.id, slug: restaurant.name ?? ''),
                  arguments: RestaurantScreen(
                    restaurant: restaurant_common.Restaurant(id: restaurant.id, name: restaurant.name),
                    viewCartAutoNavigate: true,
                  ),
                );
              },
              radius: Dimensions.radiusExtraSmall,
              buttonText: 'view_cart'.tr,
              fontSize: Dimensions.fontSizeSmall,
            ),

          ]),
        ),

      ]),
    );
    });
  }

  void _openRestaurant(Restaurant restaurant){
    Get.toNamed(
      RouteHelper.getRestaurantRoute(restaurant.id,),
    );
  }

  void _confirmDelete(BuildContext context, int restaurantId) {
    showCustomDialog(
      child: ConfirmationDialogWidget(
      icon: Images.warning,
      title: 'are_you_sure_to_delete'.tr,
      description: 'all_items_from_this_restaurant_will_be_removed_from_your_cart'.tr,
      isLogOut: true,
      isDelete: true,
      onYesPressed: () {
        Get.back();
        Get.find<CartController>().removeCartBundle(restaurantId);
      },
    ),
      isDismissible: false,
    );
  }
}

class _MoreItemsBadge extends StatelessWidget {
  final int count;
  const _MoreItemsBadge({required this.count});

  static const double _size = 44;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Text('', style: context.body.small.overrideWith(color: context.textBaseMedium)),
      const SizedBox(height: Dimensions.paddingSmall),

      Container(
        height: _size, width: _size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.surfaceContainer,
          borderRadius: BorderRadius.circular(Dimensions.radiusOverLarge),
          border: Border.all(color: context.primary),
        ),
        child: Text('+$count', style: context.body.small.strong),
      ),
    ]);
  }
}

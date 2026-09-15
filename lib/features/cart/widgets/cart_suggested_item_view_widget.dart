import 'package:stackfood_multivendor/common/widgets/vertical_food_card_widget.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_model.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class CartSuggestedItemViewWidget extends StatelessWidget {
  final List<CartModel> cartList;
  const CartSuggestedItemViewWidget({super.key, required this.cartList});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceContainer.withValues(alpha: Get.find<ThemeController>().darkTheme ? 0 : 1),
        borderRadius: BorderRadius.circular(isDesktop ? Dimensions.radiusDefault : 0),
        boxShadow: isDesktop ? [BoxShadow(color: context.shadow, blurRadius: 5, spreadRadius: 1)] : [],
      ),
      width: double.infinity,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        GetBuilder<RestaurantController>(builder: (restaurantController) {
          List<Product>? suggestedItems;
          if(restaurantController.suggestedItems != null){
            suggestedItems = [];
            List<int> cartIds = [];
            for (CartModel cartItem in cartList) {
              if(!cartItem.isBogoBundle && cartItem.product?.id != null) {
                cartIds.add(cartItem.product!.id!);
              }
            }
            for (Product item in restaurantController.suggestedItems!) {
              if(!cartIds.contains(item.id)){
                suggestedItems.add(item);
              }
            }
          }
          return restaurantController.suggestedItems != null && suggestedItems!.isNotEmpty ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: Dimensions.paddingSmall),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.paddingDefault),
                child: Text('you_may_also_brought'.tr, style: context.heading.large),
              ),

              SizedBox(
                height: ResponsiveHelper.isMobile(context) ? 250 : 330,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: suggestedItems.length,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: Dimensions.paddingMedium),
                      child: VerticalFoodCardWidget(
                        product: suggestedItems![index],
                        width: ResponsiveHelper.isMobile(context) ? 130 : 200,
                        showStoreInfo: false,
                      ),
                    );
                  },
                ),
              ),
            ],
          ) : const SizedBox();
        }),
      ]),
    );
  }
}

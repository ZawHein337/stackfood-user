import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';


class ExploreCircleCardWidget extends StatelessWidget {
  final String image;
  final String name;
  final VoidCallback onTap;
  const ExploreCircleCardWidget({
    super.key,
    required this.image,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
      ),
      child: CustomInkWellWidget(
        onTap: onTap,
        radius: Dimensions.radiusExtraSmall,
        child: Column(children: [

          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.bgNeutralLight,
            ),
            child: ClipOval(
              child: CustomImageWidget(
                image: image,
                height: 52, width: 52, fit: BoxFit.cover,
                placeholder: Images.placeholder,
                placeholderBgColor: context.bgNeutralLight,
              ),
            ),
          ),

          SizedBox(height: Dimensions.paddingExtraSmall,),
          Expanded(child: Text(
            name.trim(),
            style: context.heading.small.medium,
            maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
          )),

        ]),
      ),
    );
  }
}

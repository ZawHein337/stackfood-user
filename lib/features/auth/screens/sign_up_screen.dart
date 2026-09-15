import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/auth/widgets/sign_up_widget.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class SignUpScreen extends StatefulWidget {
  final bool exitFromApp;
  const SignUpScreen({super.key, this.exitFromApp = false});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showTitle = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      bool show = _scrollController.offset > 50;
      if (show != _showTitle) {
        setState(() => _showTitle = show);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ResponsiveHelper.isDesktop(context) ? Colors.transparent : Theme.of(context).colorScheme.surface,
      appBar: ResponsiveHelper.isDesktop(context) ? null : !widget.exitFromApp ? AppBar(
        leading: IconButton(
          onPressed: () => Get.back(result: false),
          icon: Icon(Icons.arrow_back, color: Theme.of(context).textTheme.bodyLarge!.color, size: 16),
        ),
        title: _showTitle ? Text('sign_up'.tr, style: context.heading.extraLarge.strong) : null,
        centerTitle: false,
        elevation: 0,
        backgroundColor: _showTitle ? context.surfaceContainer : ResponsiveHelper.isDesktop(context) ? Colors.transparent : Theme.of(context).colorScheme.surface,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(Icons.clear, color: Theme.of(context).textTheme.bodyLarge!.color, size: 16),
          )
        ],
      ) : null,
      body: SafeArea(
        child: SignUpWidget(scrollController: _scrollController),
      ),
    );
  }
}

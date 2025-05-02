import 'package:flutter/material.dart';

class BaseScaffold extends StatelessWidget {
  final Widget body;
  final AppBar? appBar;

  const BaseScaffold({
    super.key,
    this.appBar,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // decoration: cubit.bgImagePath != null
        //     ? BoxDecoration(
        //         image: DecorationImage(
        //           image: AssetImage(cubit.bgImagePath!),
        //           fit: BoxFit.cover,
        //         ),
        //       )
        //     : null,
        child: SafeArea(bottom: false, child: body),
      ),
    );
  }
}

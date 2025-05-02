import 'package:flutter/material.dart';

class HseAssistLogoBase extends AnimatedWidget {
  const HseAssistLogoBase({super.key, required Animation<double> animation})
    : super(listenable: animation);

  // Make the Tweens static because they don't change.
  static final _opacityTween = Tween<double>(begin: 0.5, end: 1);
  static final _sizeTween = Tween<double>(begin: 190, end: 200);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    return Center(
      child: Opacity(
        opacity: _opacityTween.evaluate(animation),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          height: _sizeTween.evaluate(animation),
          width: _sizeTween.evaluate(animation),
          child: Image.asset(
                    'assets/images/logo.png',
                    height: 150,
                    width: 150,
                  ),
        ),
      ),
    );
  }
}

class HseAssistLogo extends StatefulWidget {
  const HseAssistLogo({super.key});

  @override
  State<HseAssistLogo> createState() => _HseAssistLogoState();
}

class _HseAssistLogoState extends State<HseAssistLogo> with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    animation = CurvedAnimation(parent: controller, curve: Curves.easeIn)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) => HseAssistLogoBase(animation: animation);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
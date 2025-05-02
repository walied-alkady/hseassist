
import 'package:flutter/material.dart';
import 'package:hsequize/widgets/label_header.dart';

class DialogFrame extends StatelessWidget {
  final String title;
  final Widget body;
  const DialogFrame({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Center(
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  // decoration: BoxDecoration(
                  //   gradient: cubit.gradient,
                  //   borderRadius: const BorderRadius.all(Radius.circular(30)),
                  //   border: Border.all(
                  //       color: cubit.primaryColor,
                  //       width: 8),
                  // ),
                  child: body,
                ),
                const SizedBox(height: 80),
              ],
            ),
            Positioned(
              left: 75,
              right: 75,
              child: LabelHeader(title: title),
            ),
            Positioned(
              right: 10,
              top: 20,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

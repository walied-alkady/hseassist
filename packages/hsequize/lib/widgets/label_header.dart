
import 'package:flutter/material.dart';

class LabelHeader extends StatelessWidget {
  final String title;
  const LabelHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 75,
      width: MediaQuery.of(context).size.width * 0.5,
      decoration: BoxDecoration(
        //color: theme.primaryColorDark.withOpacity(0.1), //Consider removing or adjusting
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), //Shadow color
            spreadRadius: 2, //Spread radius
            blurRadius: 4, //Blur radius
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: FittedBox(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
            child: Text(
              title,
              style: theme.textTheme.headlineMedium!.copyWith(
                  color: theme.primaryColor, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

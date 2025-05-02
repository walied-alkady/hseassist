
import 'package:flutter/material.dart';

import 'image_widget.dart';

class CategoryContainer extends StatelessWidget {
  const CategoryContainer({super.key, this.img,required  this.title , this.isSelected = false});

  final String title;
  final String? img;
  final bool isSelected;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.fromLTRB(8, 13, 8, 8),
      decoration: BoxDecoration(
        color: theme.primaryColorDark.withOpacity(0.1),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: isSelected ? Border.all(color: theme.primaryColor, width: 1):null,
      ),
      child: Column(
        children: [
            FittedBox(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            if (img != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              decoration: BoxDecoration(
                // gradient: LinearGradient(
                //   stops: const [0, 1],
                //   begin: const Alignment(1, 1),
                //   end: const Alignment(1, -1),
                //   colors: //cubit.gradient.colors,
                // ),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                border:Border.all(color: theme.colorScheme.inversePrimary, width: 1),
              ),
              child: ImageWidget(
                imgPath: img!,
                width: 100,
                height: 100,
              ),
          ),
        ],
      ),
    );
  }
}

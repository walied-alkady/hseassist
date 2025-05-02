
import 'package:flutter/material.dart';

import '../models/quiz_category.dart';
import 'category_container.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    this.onTap,
    required this.category,
  });

  final VoidCallback? onTap;
  final QuizCategory category;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.3,
        child: CategoryContainer(
          title: category.name.toUpperCase(),
          //img: category.iconImage,
        ),
      ),
    );
  }
}

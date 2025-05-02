
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class StorageComponent extends PositionComponent {
  final double siloWidth;
  final double siloHeight;

  late RectangleComponent siloBody;

  StorageComponent({
    super.position,
    required this.siloWidth,
    required this.siloHeight,
  }) : super(size: Vector2(siloWidth, siloHeight)) {
    // Silo Body (Rectangle)
    siloBody = RectangleComponent(
      position: Vector2.zero(),
      size: Vector2(siloWidth, siloHeight),
      paint: Paint()..color = Colors.grey, // Adjust color
    );

    add(siloBody);
  }

  void processItem(PositionComponent item) {
    // Implement silo storage logic here. For example, add the item to a list.
    print('Item stored in silo!');
    item.removeFromParent(); // Example: Destroy the item
  }
}


import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class MillComponent extends PositionComponent {
  final double cylinderWidth;
  final double cylinderHeight;
  final double rotationSpeed;

  late RectangleComponent cylinderBody;

  MillComponent({
    super.position,
    required this.cylinderWidth,
    required this.cylinderHeight,
    this.rotationSpeed = 1.0, // Adjust rotation speed
  }) : super(size: Vector2(cylinderWidth, cylinderHeight)) {
    // Cylinder Body (Rectangle)
    cylinderBody = RectangleComponent(
      position: Vector2.zero(),
      size: Vector2(cylinderWidth, cylinderHeight),
      paint: Paint()..color = Colors.brown, // Adjust color
    );


    add(cylinderBody);
  }

  double rotationAngle = 0;

  @override
  void update(double dt) {
    super.update(dt);
    rotationAngle += rotationSpeed * dt;
    angle = rotationAngle;
  }

  void processItem(PositionComponent item) {
    // Implement mill processing logic here. For example, change the item's sprite.
    print('Item processed by mill!');
    item.removeFromParent(); // Example: Destroy the item
  }
}

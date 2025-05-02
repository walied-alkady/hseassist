import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:hseassist/games/hunter/hazard_hunter_game.dart';

class CircleComponentPlayer extends CircleComponent with HasGameRef<HazardHunterGame> {
  CircleComponentPlayer(
    this.joystick,
    {
    required super.position,
    required double radius,
    Color color = Colors.white
  })
      : super( anchor: Anchor.center,radius: radius, paint: Paint()..color = color ..style = PaintingStyle.fill);
  final JoystickComponent joystick;
  double maxSpeed = 300.0;

  @override
  void update(double dt) {
    super.update(dt);
    double newY = position.y + (dt * 400);
    
    if (newY > gameRef.size.y / 2 - (size.y/2)) {
      newY = gameRef.size.y / 2 - (size.y/2); 
    }
    position.y = newY;

    if (joystick.direction != JoystickDirection.idle) {
      position.add(joystick.relativeDelta  * maxSpeed * dt);
      angle = joystick.delta.screenAngle();
    }
  }
  
  void move (double deltaX){

    double newX = position.x + deltaX;

    double minX = 0;//size.x/2;
    double maxX = (gameRef.size.x) - (size.x/2);
    newX = newX.clamp(minX, maxX);
    position.x = newX;
  }
}

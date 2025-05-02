import 'package:flame/components.dart';
import 'package:flame/events.dart' show DragUpdateInfo, HorizontalDragDetector;
import 'package:flame/input.dart' show JoystickComponent, KeyboardEvents;
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:hseassist/games/hunter/game_constgants.dart';
import 'package:hseassist/games/hunter/hazard_hunter_world.dart';
import 'package:flame/game.dart';
import 'package:hseassist/repository/logging_reprository.dart';

class HazardHunterGame extends FlameGame<HazardHunterWorld> with HorizontalDragDetector,KeyboardEvents{
  
  HazardHunterGame() : super(
      world: HazardHunterWorld(),
      camera: CameraComponent.withFixedResolution(width: GameConstants.gameWidth, height: GameConstants.gameHeight)
  );
  final log = LoggerReprository('HazardHunterGame');
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await initGame();
  }
  @override
  Color backgroundColor() => const Color.fromARGB(255, 240, 240, 240); 

  @override
  void onHorizontalDragUpdate(DragUpdateInfo info){
    super.onHorizontalDragUpdate(info);
    world.player1.move(info.delta.global.x);
  }
  
  Future<void> initGame() async {
    await images.loadAll([
      'beltConveyor.png',
      'fire.png',
      'safetyMan.png',
      'joystick.jpeg'
    ]);

    final sheet = SpriteSheet.fromColumnsAndRows(
        image: images.fromCache('joystick.jpeg'),
        columns: 6,
        rows: 1,
      );
    
    final joystick = JoystickComponent(
        knob: SpriteComponent(
          sprite: sheet.getSpriteById(1),
          size: Vector2.all(100),
        ),
        background: SpriteComponent(
          sprite: sheet.getSpriteById(0),
          size: Vector2.all(150),
        ),
        margin: const EdgeInsets.only(left: 40, bottom: 40),
      );
    
    camera.viewport.add(joystick);
  }
  
}

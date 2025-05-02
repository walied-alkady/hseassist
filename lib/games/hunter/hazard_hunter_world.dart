import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:hseassist/games/hunter/belt_component.dart';
import 'package:hseassist/games/hunter/circle_component.dart';
import 'package:hseassist/games/hunter/game_constgants.dart';
import 'package:hseassist/games/hunter/mill_component.dart';
import 'package:hseassist/games/hunter/safety_player.dart';
import 'package:hseassist/games/hunter/storage_component.dart';
import 'package:hseassist/repository/logging_reprository.dart';

import 'hazard_hunter_game.dart';

class HazardHunterWorld extends World with HasGameRef<HazardHunterGame> {
  
  final log = LoggerReprository('HazardHunterWorld');
  late CircleComponentPlayer player1;
  late SafetyPlayer safetyMan;

  HazardHunterWorld() : super(){

    player1=  CircleComponentPlayer(
        JoystickComponent(
          
        )
        ,
        position: Vector2(0, 0),
        radius: 50,
        color: Colors.red,
      );

    safetyMan = SafetyPlayer(
        position: Vector2(128, GameConstants.gameHeight - 130), //Adjust the y so the player is on the ground
      );
  }

  @override
  Future<void> onLoad() async {

    final belt0 = BeltComponent(
      position: Vector2(100, 500),
      beltWidth:  300 ,
      beltHeight: 100
    );
    // Belt 1
    final belt1 = BeltComponent(position: Vector2(100, 100), beltWidth:  300 , beltHeight: 50);

    // Mill
    final mill = MillComponent(position: Vector2(450, 80), cylinderWidth:  300 , cylinderHeight:  100 );

    // Belt 2
    final belt2 = BeltComponent(position: Vector2(550, 100), beltWidth:  300 , beltHeight: 50);

    // Storage
    final storage = StorageComponent(position: Vector2(800, 80), siloWidth:  300 , siloHeight:  100);


    add(belt0); 
    //add(belt1);
    // add(roller1a);
    // add(roller1b);
    // add(mill);
    // add(belt2);
    // add(roller2a);
    // add(roller2b);
    // add(storage);
    // add(item);

    // 

    add(safetyMan); 

  }
  
}

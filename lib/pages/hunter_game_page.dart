import 'package:easy_localization/easy_localization.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:hseassist/games/hunter/game_constgants.dart';
import 'package:hseassist/games/hunter/hazard_hunter_game.dart';
import 'package:hseassist/repository/logging_reprository.dart';


class HazardHunterGameMain extends StatelessWidget {
  const HazardHunterGameMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('hunterGame'.tr()),
      ),
      body: SafeArea(
        child: FittedBox(
          child: SizedBox(
            height: GameConstants.gameHeight,
            width: GameConstants.gameWidth,
            child: const GameWidget<HazardHunterGame>.controlled(
              gameFactory: HazardHunterGame.new,
            ),
          ),
        ),
      ),
    );
  }
}








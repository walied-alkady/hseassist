import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:hseassist/games/hunter/hazard_hunter_game.dart';


class BeltComponent extends SpriteAnimationComponent with HasGameReference<HazardHunterGame>{
  final double beltWidth;
  final double beltHeight;

  BeltComponent({
    super.position,
    required this.beltWidth,
    required this.beltHeight,
  }) : super(size: Vector2(beltWidth, beltHeight));

  @override
  Future<void>? onLoad() async {
    animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('beltConveyor.png'),
        SpriteAnimationData.sequenced(
          amount: 24,
          textureSize: Vector2.all(5640/24),
          stepTime: 0.05,
          loop: true,
        ));
    add(RectangleHitbox(collisionType: CollisionType.passive));
    // add(
    //   SizeEffect.by(
    //     Vector2(-24, -24),
    //     EffectController(
    //       duration: .75,
    //       reverseDuration: .5,
    //       infinite: true,
    //       curve: Curves.easeOut,
    //     ),
    //   ),
    // );
  }
}

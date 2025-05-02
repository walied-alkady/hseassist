

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:hseassist/repository/logging_reprository.dart';

import 'hazard_hunter_game.dart';

class SafetyPlayer extends SpriteAnimationComponent with KeyboardHandler ,  CollisionCallbacks , HasGameRef<HazardHunterGame> {
  SafetyPlayer({
    required super.position,
  }) : super(size: Vector2.all(64), anchor: Anchor.center);
  final log = LoggerReprository('SafetyPlayer');

  Vector2 velocity = Vector2.zero();
  final Vector2 fromAbove = Vector2(0, -1);
  final double gravity = 15;
  final double jumpSpeed = 600;
  final double moveSpeed = 200;
  final double terminalVelocity = 150;
  int horizontalDirection = 0;

  bool hasJumped = false;
  bool isOnGround = false;
  bool hitByEnemy = false;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runAnimation;
  bool isFacingRight = true; // Keep track of facing direction

  @override
  Future<void> onLoad() async {
    final spriteSheet = Sprite(game.images.fromCache('safetyMan.png'));
    size = Vector2(505/4, 218); // assuming each frame is 16x16

    idleAnimation = SpriteAnimation.fromFrameData(
      spriteSheet.image,
      SpriteAnimationData.sequenced(
        amount: 1, 
        textureSize: size,
        stepTime: 0.12,
        texturePosition: Vector2(0,0),
      ),
    );
    runAnimation = SpriteAnimation.fromFrameData(
        spriteSheet.image,
        SpriteAnimationData.sequenced(
        amount: 4,
        textureSize: size,
        stepTime: 0.12,
      ),
    );
    animation = idleAnimation; // Start with idle animation
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Apply gravity
    if (!isOnGround) {
      velocity.y += gravity;
    }
    velocity.y = velocity.y.clamp(-jumpSpeed, terminalVelocity);

    // Apply horizontal movement
    velocity.x = horizontalDirection * moveSpeed;

    // Update position based on velocity
    position += velocity * dt;
    isOnGround = false; // Reset the flag

     // Animation logic
    if (horizontalDirection != 0) {
      animation = runAnimation;
      isFacingRight = horizontalDirection > 0; // Update facing direction
    } else {
      animation = idleAnimation;
    }

     // Flip the sprite if moving left
    if (!isFacingRight) {
      flipHorizontallyAroundCenter();
    }
      if (isFacingRight && isFlippedHorizontally) {
      flipHorizontallyAroundCenter();
    }
  }
  
}

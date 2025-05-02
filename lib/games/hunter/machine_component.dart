import 'package:flame/components.dart';

abstract class MachineComponent extends PositionComponent {
  MachineComponent({super.position, super.size});

  void processItem(PositionComponent item); // Abstract method for processing items
}
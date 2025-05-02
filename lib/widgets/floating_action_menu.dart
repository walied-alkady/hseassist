// floating_action_menu.dart
import 'package:flutter/material.dart';

class FloatingActionMenu extends StatefulWidget {
  final List<FloatingActionButton> buttons;
  final GlobalKey?  mainButtonKey;
  final VoidCallback? onMainButtonPressed;
  const FloatingActionMenu({
    super.key,
    this.mainButtonKey ,
    this.onMainButtonPressed,
    required this.buttons});

  @override
  _FloatingActionMenuState createState() => _FloatingActionMenuState();
}

class _FloatingActionMenuState extends State<FloatingActionMenu> with SingleTickerProviderStateMixin {
  bool isMenuOpen = false;
  late AnimationController _controller;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _buttonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    
    if (isMenuOpen) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() {
      isMenuOpen = !isMenuOpen;
    });
    if (widget.onMainButtonPressed != null) {
        widget.onMainButtonPressed!();
    }
  }

  void _onMainButtonPressed(){
      _toggleMenu(); 
      if (widget.onMainButtonPressed != null) {
        widget.onMainButtonPressed!(); 
      }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ...widget.buttons.asMap().entries.map((entry) {
          int index = entry.key;
          FloatingActionButton button = entry.value;

          return Positioned(
            bottom: 16.0 + (index + 1) * 60.0,
            right: 16.0,
            child: ScaleTransition(
              scale: _buttonAnimation,
              child: button,
            ),
          );
        }),
        Positioned(
          bottom: 16.0,
          right: 16.0,
          child: FloatingActionButton(
            key: widget.mainButtonKey,
            onPressed: _toggleMenu,
            foregroundColor: Theme.of(context).colorScheme.onSecondary,
            backgroundColor: Theme.of(context).colorScheme.secondary,
            child: Icon(isMenuOpen ? Icons.close : Icons.add), //Icons.menu
          ),
        ),
      ],
    );
  }
}

class LabeledFloatingActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final String heroTag;

  const LabeledFloatingActionButton({super.key, 
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.backgroundColor,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: heroTag,
          onPressed: onPressed,
          backgroundColor: backgroundColor,
          child: Icon(icon),
        ),
        SizedBox(height: 8.0),
        Text(label),
      ],
    );
  }
}

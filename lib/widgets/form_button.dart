import 'package:flutter/material.dart';

class FormButton extends StatelessWidget {
  final String buttonText;
  final Function()? onPressed;
  const FormButton({super.key,
  required this.buttonText,
  required this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
                width: double.infinity,
                height: 48.0,
                child: ElevatedButton(
                  onPressed: onPressed,
                  child: Text(buttonText),
                ),
              );
  }
}
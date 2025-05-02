import 'package:flutter/material.dart';

class OkDialogue extends StatelessWidget {
  final String title;
  final String contentMain;
  final String contentSecondary;

  const OkDialogue({super.key,
    required this.title,
    required this.contentMain,
    this.contentSecondary='',
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(contentMain),
                Text(contentSecondary),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
  }
}
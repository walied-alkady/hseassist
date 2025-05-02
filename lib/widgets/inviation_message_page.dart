import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class InvitationMessagePage extends StatelessWidget {
  const InvitationMessagePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info,
            color: Colors.green[100],
            size: 50.0,
          ),
          const SizedBox(height: 10.0),
          Text(context.tr('WELCOME'),
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10.0),
          const Text(
            'You need to be invited to be able to continue',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.0),
          ),
        ],
      ),
    );
  }
}

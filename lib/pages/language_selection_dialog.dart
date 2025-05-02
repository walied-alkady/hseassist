import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LanguageSelectionDialog extends StatelessWidget {
  const LanguageSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale;
    return AlertDialog(
                title: Text('languageLabel'.tr()),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (currentLocale != const Locale('en', 'US'))
                    ListTile(
                      title: Text('languageSelection.en'.tr()),
                      onTap: () async {
                        // Update language to English
                        //TODO; implement
                      //await prefs.setlanguage(AppSetts.language);
                        
                        // context.read<SettingsBloc>().add(
                        //   const ChangedSettingsEvent(AppSetts.language, Locale('en', 'US')),
                        // );
                        if (context.mounted) {
                          context.setLocale(const Locale('en', 'US'));
                          Navigator.of(context).pop(); 
                        }
// Close the dialog
                      },
                    ),
                    if (currentLocale != const Locale('ar', 'EG'))
                    ListTile(
                      title: Text('languageSelection.ar'.tr()),
                      onTap: () async {
                        // Update language to Arabic
                        // context.read<SettingsBloc>().add(
                        //   const ChangedSettingsEvent(AppSetts.language, Locale('ar', 'EG')),
                        // );
                         //TODO; implement
                        //await prefs.setlanguage(AppSetts.language);
                        if(context.mounted){
                          context.setLocale(const Locale('ar', 'EG'));
                          Navigator.of(context).pop(); // Close the dialog
                        }
                      },
                    ),
                  ],
                ),
              );

  }
}


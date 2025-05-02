import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hseassist/theme.dart';

import '../blocs/app_bloc.dart';
import '../blocs/manager.dart';

class ThemeSelectionDialog extends StatefulWidget {
  const ThemeSelectionDialog({Key? key}) : super(key: key);

  @override
  State<ThemeSelectionDialog> createState() => _ThemeSelectionDialogState();
}

class _ThemeSelectionDialogState extends State<ThemeSelectionDialog> with Manager<ThemeSelectionDialog>{
  ThemeData? _selectedTheme;

  @override
  void initState() {
    super.initState();
    _selectedTheme = context.read<AppCubit>().prefs.isDarkTheme ? safetyThemeDarkOrange : safetyThemeClassic;
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
                title: Text('themeLabel'.tr()),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<ThemeData>(
                      title: const Text('Classic Light'),
                      value: safetyThemeClassic,
                      groupValue: _selectedTheme,
                      onChanged: (ThemeData? value) {
                          _handleThemeChange(context, value);
                      },
                    ),
                    RadioListTile<ThemeData>(
                      title: const Text('Modern Light'),
                      value: safetyThemeModern,
                      groupValue: _selectedTheme,
                      onChanged: (ThemeData? value) {
                          _handleThemeChange(context, value);
                      },
                    ),
                    RadioListTile<ThemeData>(
                      title: const Text('High Visibility Light'),
                      value: safetyThemeHighVisibility,
                      groupValue: _selectedTheme,
                      onChanged: (ThemeData? value) {
                          _handleThemeChange(context, value);
                      },
                    ),
                    RadioListTile<ThemeData>(
                      title: const Text('Dark Orange'),
                      value: safetyThemeDarkOrange,
                      groupValue: _selectedTheme,
                      onChanged: (ThemeData? value) {
                          _handleThemeChange(context, value);
                      },
                    ),
                    RadioListTile<ThemeData>(
                      title: const Text('Dark Green'),
                      value: safetyThemeDarkGreen,
                      groupValue: _selectedTheme,
                      onChanged: (ThemeData? value) {
                        _handleThemeChange(context, value);
                      },
                    ),
                    RadioListTile<ThemeData>(
                      title: const Text('Dark High Visibility'),
                      value: safetyThemeDarkHighVisibility,
                      groupValue: _selectedTheme,
                      onChanged: (ThemeData? value) {
                          _handleThemeChange(context, value);
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () { 
                      if(_selectedTheme !=null) 
                      { 
                        context.read<AppCubit>().updateTheme(_selectedTheme!); // Add ThemeChangedEvent
                        // Store the selected theme. Example using shared_preferences:
                        if (_selectedTheme == safetyThemeDarkOrange || _selectedTheme == safetyThemeDarkGreen || _selectedTheme == safetyThemeDarkHighVisibility) {
                          context.read<AppCubit>().prefs.setTheme(true); // Assuming true represents dark mode
                        } else{
                          context.read<AppCubit>().prefs.setTheme(false); // Assuming false represents light mode
                        }
                      }
                      Navigator.of(context).pop();
                    },
                    child: Text("ok".tr()),
                  ),
                ],
              );
  }

  void _handleThemeChange(BuildContext context, ThemeData? value) {
      setState(() {
        _selectedTheme = value!;
      });

  }
}


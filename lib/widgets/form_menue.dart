import 'package:flutter/material.dart';

class FormMenue<T> extends StatelessWidget {
  final T? initialValue;
  final Function(dynamic)? onSaved;
  final Function(dynamic)? onSelectedCallback;
  final FormFieldValidator<dynamic>? validator;
  final bool enabled;
  final Widget? label;
  final Widget? leadingIcon;
  final List<DropdownMenuEntry<T>> dropdownMenuEntries;
  final int Function(List<DropdownMenuEntry<T>>, String)? searchCallback;


  const FormMenue({super.key, 
    this.initialValue, 
    this.onSaved, 
    this.onSelectedCallback, 
    this.validator,
    this.enabled =true, 
    this.label, 
    this.leadingIcon, 
    required this.dropdownMenuEntries,
    this.searchCallback
  });

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
                        initialValue: initialValue,
                        onSaved: (newValue) => onSaved,
                        validator:validator,
                        builder: (FormFieldState<T> fieldState) {
                          return DropdownMenu<T>(
                                    initialSelection: initialValue,
                                    enabled: enabled,
                                    expandedInsets: EdgeInsets.zero,
                                    label: label,
                                    leadingIcon: leadingIcon,
                                    selectedTrailingIcon: const Icon(
                                      Icons.keyboard_arrow_up_sharp,
                                      size: 20
                                    ),
                                    errorText: fieldState.hasError ? fieldState.errorText : null,
                                    onSelected: (value) {
                                      // This is called when the user selects an item.
                                      fieldState.didChange(value); 
                                      if(value!=null && onSelectedCallback != null){
                                        onSelectedCallback!(value);
                                      } 
                                    },
                                    searchCallback: searchCallback,
                                    dropdownMenuEntries: dropdownMenuEntries,
                              );
                        }
                      );
  }
}
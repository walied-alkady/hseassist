import 'package:flutter/material.dart';

class FormDateTime extends StatefulWidget {
  final String fieldLabelText;
  final DateTime? initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final Function(DateTime date)? onDateSubmitted;
  final bool Function(DateTime)? selectableDayPredicate;

  const FormDateTime({
    super.key,
    required this.fieldLabelText,
    this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.onDateSubmitted,
    this.selectableDayPredicate,
  });

  @override
  State<FormDateTime> createState() => _FormDateTimeState();
}

class _FormDateTimeState extends State<FormDateTime> {
  late final ValueNotifier<DateTime?> _selectedDateNotifier;

  @override
  void initState() {
    super.initState();
    _selectedDateNotifier = ValueNotifier<DateTime?>(widget.initialDate);
  }

  @override
  void dispose() {
    _selectedDateNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDateNotifier.value ?? DateTime.now(),
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
        );
        if (picked != null) {
          _selectedDateNotifier.value = picked;
          widget.onDateSubmitted?.call(picked);
        }
      },
      child: IgnorePointer(
        child: ValueListenableBuilder<DateTime?>(
          valueListenable: _selectedDateNotifier,
          builder: (context, selectedDate, child) {
            return InputDatePickerFormField(
              firstDate: widget.firstDate,
              lastDate: widget.lastDate,
              initialDate: selectedDate,
              fieldLabelText: widget.fieldLabelText,
              onDateSubmitted: (date) => widget.onDateSubmitted?.call(date),
              selectableDayPredicate: widget.selectableDayPredicate,
            );
          },
        ),
      ),
    );
  }
}

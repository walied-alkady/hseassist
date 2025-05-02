import 'package:flutter/material.dart';

class FormTextField extends StatefulWidget {
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final String? labelText;
  final String? hintText;
  final int? maxHintLines;
  final Widget? prefix;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final TextEditingController? controller;
  final Function()? onTap;
  final String? initialValue;

  const FormTextField({
    super.key,
    required this.labelText,
    required this.hintText,
    this.maxHintLines,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.controller,
    this.onTap,
    this.initialValue,
  });

  @override
  State<FormTextField> createState() => _FormTextFieldState();
}

class _FormTextFieldState extends State<FormTextField> {
  late final TextEditingController _controller;
  late int _currentMaxHintLines;
  late FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);
    _currentMaxHintLines = widget.maxHintLines ?? 1; // Default to 1 if not provided
    _focusNode = FocusNode();

    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    if (widget.controller == null) {
      // Only dispose if the controller was created internally
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    // Update maxHintLines based on text field content and focus
    _updateHintLines();
    // Call the onChanged callback if provided
    if (widget.onChanged != null) {
      widget.onChanged!(_controller.text);
    }
  }

  void _onFocusChanged() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
      _updateHintLines();
    });
  }

  void _updateHintLines() {
    setState(() {
      if (_controller.text.isEmpty && _hasFocus && !widget.obscureText) {
        _currentMaxHintLines = widget.maxHintLines ?? 10; // Increase when empty and focused
      } else {
        _currentMaxHintLines = widget.maxHintLines ?? 1; // Default to 1 otherwise
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      //initialValue: widget.initialValue,
      validator: widget.validator,
      onChanged: (value) {
        // this line was removed because the ontext changed do it automatically
        //if (widget.onChanged != null) {
        //widget.onChanged!(value);
        //}
        // this listener is moved to controller listener in initstate
        //_onTextChanged(); // Update maxHintLines
      },
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      controller: _controller,
      onTap: widget.onTap,
      maxLines: widget.obscureText? 1:null, // Allow multiple lines, maxLines is not the same as hintmaxlines !obscureText || maxLines == 1
      focusNode: _focusNode,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        hintMaxLines: _currentMaxHintLines, // Use the updated value
        prefixIcon: widget.prefix,
        suffixIcon: widget.suffix,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'src/ckeditor_platform.dart';

class CkEditorField extends StatefulWidget {
  const CkEditorField({
    required this.initialValue,
    required this.onChanged,
    this.height = 320,
    super.key,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final double height;

  @override
  State<CkEditorField> createState() => _CkEditorFieldState();
}

class _CkEditorFieldState extends State<CkEditorField> {
  late String _value = widget.initialValue;

  @override
  void didUpdateWidget(covariant CkEditorField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _value = widget.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final platformWidget = CkEditorPlatform.instance.build(
      initialValue: _value,
      height: widget.height,
      onChanged: (value) {
        setState(() {
          _value = value;
        });
        widget.onChanged(value);
      },
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Material(
        elevation: 1,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: widget.height,
          child: platformWidget,
        ),
      ),
    );
  }
}

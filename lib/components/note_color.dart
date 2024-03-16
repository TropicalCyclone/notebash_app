import 'package:flutter/material.dart';

class NoteColor extends StatefulWidget {
  final int? selectedColor;
  final void Function(int color) onColorChanged;
  const NoteColor({
    super.key,
    this.selectedColor,
    required this.onColorChanged,
  });

  @override
  State<NoteColor> createState() => _NoteColorState();
}

class _NoteColorState extends State<NoteColor> {
  final List<int> _colors = [
    0XFFDFE2EB,
    0XFFBFE5FF,
    0XFFBFFFE7,
    0XFFFEF2BE,
    0XFFFFBFD0,
  ];

  int _selectedColor = 0XFFDFE2EB;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.selectedColor ?? _colors[0];
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _colors
          .map((color) => Material(
                color: Color(color),
                borderRadius: BorderRadius.circular(15),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                      widget.onColorChanged(color);
                    });
                  },
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              width: _selectedColor == color ? 2 : 0,
                              color: _selectedColor == color
                                  ? Theme.of(context).primaryColor
                                  : Colors.transparent),
                          color: Colors.transparent),
                      child: _selectedColor == color
                          ? Icon(
                              Icons.check,
                              color: Theme.of(context).primaryColor,
                              size: 20,
                            )
                          : null),
                ),
              ))
          .toList(),
    );
  }
}

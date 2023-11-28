import 'dart:async';

import 'package:flutter/material.dart';

class NumberPad extends StatefulWidget {
  final Function(String) onTap;

  NumberPad({required this.onTap});

  @override
  _NumberPadState createState() => _NumberPadState();
}

class _NumberPadState extends State<NumberPad> {
  String? _selectedNumber;

  Widget build(BuildContext context) {
    return Container(
      height: 230,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildNumberRow(1, 3),
          buildNumberRow(4, 6),
          buildNumberRow(7, 9),
          buildLastRow(),
        ],
      ),
    );
  }

  Widget buildNumberRow(int start, int end) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (int i = start; i <= end; i++) 
            buildNumberButton('$i'),
        ],
      ),
    );
  }

  Widget buildLastRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(150,6,0,0),
      child: Row(
        children: [
          buildNumberButton('0', width: 60),
          buildBackspaceButton(),
        ],
      ),
    );
  }

  Widget buildNumberButton(String label, {double width = 90}) {
    bool isSelected = _selectedNumber == label;

    return GestureDetector(
      onTap: () => onTapButton(label),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: width,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: isSelected ? Colors.blue : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget buildBackspaceButton() {
    return GestureDetector(
      onTap: () => widget.onTap('backspace'),
      child: Padding(
        padding: const EdgeInsets.only(left: 55),
        child: Container(
          child: Icon(
            Icons.backspace,
            color: Colors.red,
            size: 30,
          ),
        ),
      ),
    );
  }

  void onTapButton(String label) {
    widget.onTap(label);
    setState(() {
      _selectedNumber = label;
    });

    Timer(Duration(milliseconds: 200), () {
      setState(() {
        _selectedNumber = null;
      });
    });
  }
}

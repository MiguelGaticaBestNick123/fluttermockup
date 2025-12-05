import 'package:flutter/material.dart';

class NumericKeypad extends StatelessWidget {
  final Function(String) onKeyPressed;
  final VoidCallback onEnter;
  final VoidCallback onBackspace;

  const NumericKeypad({
    super.key,
    required this.onKeyPressed,
    required this.onEnter,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow(['1', '2', '3']),
          _buildRow(['4', '5', '6']),
          _buildRow(['7', '8', '9']),
          _buildRow(['C', '0', 'ENTER']),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> keys) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: keys.map((key) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  backgroundColor: key == 'ENTER' ? Colors.indigo : Colors.white,
                  foregroundColor: key == 'ENTER' ? Colors.white : Colors.black,
                  textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  if (key == 'C') {
                    onBackspace();
                  } else if (key == 'ENTER') {
                    onEnter();
                  } else {
                    onKeyPressed(key);
                  }
                },
                child: key == 'C'
                    ? const Icon(Icons.backspace_outlined)
                    : key == 'ENTER'
                        ? const Icon(Icons.check)
                        : Text(key),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

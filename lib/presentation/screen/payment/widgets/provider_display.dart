import 'package:flutter/material.dart';

class ProviderDisplay extends StatelessWidget {
  final String title;
  final IconData iconData;

  const ProviderDisplay({
    Key? key,
    required this.title,
    required this.iconData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.indigo[900],
        borderRadius: BorderRadius.zero,
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const Spacer(),
          Icon(iconData, color: Colors.white, size: 30),
        ],
      ),
    );
  }
}
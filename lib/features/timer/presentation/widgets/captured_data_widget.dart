import 'dart:typed_data';

import 'package:flutter/material.dart';

class CapturedDataWidget extends StatelessWidget {
  const CapturedDataWidget({
    super.key,
    required this.dataTitle,
    required this.data,
  });

  final String dataTitle;
  final Uint8List? data;
  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return const SizedBox.shrink();
    }
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 10,
        ),
      ),
      child: Column(
        children: [
          Text(dataTitle),
          Expanded(child: Image.memory(data!)),
        ],
      ),
    );
  }
}

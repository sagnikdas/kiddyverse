// widgets/narration_recorder.dart
import 'package:flutter/material.dart';

class NarrationRecorder extends StatelessWidget {
  const NarrationRecorder({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Record your narration"),
          ElevatedButton(
            onPressed: () {
              // Add recording logic here
            },
            child: const Text("Start Recording"),
          ),
        ],
      ),
    );
  }
}
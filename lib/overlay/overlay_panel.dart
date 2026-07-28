import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

class OverlayPanel extends StatelessWidget {
  const OverlayPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF262A38),
      child: SafeArea(
        child: Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D9C0),
              foregroundColor: const Color(0xFF1A1A2E),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            ),
            onPressed: () {
              FloatyOverlay.shareData({'type': 'overlay_closed'});
              FloatyOverlay.closeOverlay();
            },
            child: const Text(
              'CLOSE',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ),
    );
  }
}

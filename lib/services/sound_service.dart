import 'package:flutter/services.dart';

class SoundService {
  bool _enabled = true;

  bool get isEnabled => _enabled;

  void toggle() {
    _enabled = !_enabled;
  }

  void playTap() {
    if (!_enabled) return;
    SystemSound.play(SystemSoundType.click);
  }
}

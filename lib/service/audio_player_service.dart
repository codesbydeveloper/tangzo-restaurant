import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class AudioPlayerService with WidgetsBindingObserver {
  static const MethodChannel _ringtoneChannel = MethodChannel('tangzo/order_ringtone');
  static bool _isPlaying = false;
  static bool _initialized = false;

  static Future<void> initAudio() async {
    if (!_initialized) {
      WidgetsBinding.instance.addObserver(AudioPlayerService());
      _initialized = true;
    }
  }

  static Future<void> playSound(bool isPlay) async {
    try {
      await initAudio();
      if (isPlay) {
        _isPlaying = true;
        log("PlaySound :: START native ringtone (bundled 20s)");
        // Do not pass admin remote URL — it is often ~5s and was cutting the ring short.
        await _ringtoneChannel.invokeMethod('start', {
          'minSeconds': 20,
        });
      } else {
        _isPlaying = false;
        log("PlaySound :: STOP native ringtone");
        await _ringtoneChannel.invokeMethod('stop');
      }
    } catch (e) {
      log("Error in playSound: $e");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    log("AppLifecycleState :: $state");
    // Native iOS player continues in background when UIBackgroundModes includes audio.
    // Re-assert playback if iOS interrupted the session while we still expect ringing.
    if (!Platform.isAndroid && state == AppLifecycleState.resumed && _isPlaying) {
      await playSound(true);
    }
  }
}

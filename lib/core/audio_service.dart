import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});

class AudioService {
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _ambientPlayer = AudioPlayer();

  AudioService() {
    _ambientPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> playCompletionDing() async {
    await _sfxPlayer.play(AssetSource('audio/ding.wav'));
  }

  Future<void> playAmbient(String type) async {
    // We will expand this when we add real ambient files. 
    // For now, it's just a placeholder method.
    // await _ambientPlayer.play(AssetSource('audio/$type.mp3'));
  }

  Future<void> stopAmbient() async {
    await _ambientPlayer.stop();
  }

  void dispose() {
    _sfxPlayer.dispose();
    _ambientPlayer.dispose();
  }
}

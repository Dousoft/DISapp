import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';

class SoundController extends ChangeNotifier {
  final player = AssetsAudioPlayer();

  void insoundPlay() {
    player.open(
      Audio("assets/insound.mp3"),
    );
  }

  void outsoundPlay() {
    player.open(
      Audio("assets/outsound.mp3"),
    );
  }
}

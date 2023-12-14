import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gesturecontrollers/screens/player/media_player_event.dart';
import 'package:gesturecontrollers/screens/player/media_player_stats.dart';
import 'package:video_player/video_player.dart';

class MediaPLayerBloc extends Bloc<MediaPlayerEvents, MediaPlayerState> {
  GlobalKey<ScaffoldState> keyScaffold = GlobalKey<ScaffoldState>();
  late VideoPlayerController playerController;
  bool isInitialized = false;
  bool isHorizontal = false;
  bool isControlsLocked = false;
  bool isControlsVisible = false;

  MediaPLayerBloc({required this.keyScaffold})
      : super(StateMediaPlayerInitial()) {
    on((event, emit) async {
      if (event is EventMediaPlayerInit) {
        emit(StateMediaPLayerLoading());
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft,
        ]);
        if (!event.isFile) {
          playerController =
              VideoPlayerController.contentUri(Uri.parse(event.path));
        } else {
          playerController = VideoPlayerController.file(File(event.path));
        }
        await playerController.initialize().then((value) {
          isInitialized = true;
          emit(StateMediaPLayerLoaded());
        });
      } else if (event is EventMediaPlayerPlay) {
        if (playerController.value.isInitialized) {
          await playerController.play();
        }
        emit(StateMediaPLayerLoaded());
      } else if (event is EventMediaPlayerPause) {
        if (playerController.value.isInitialized) {
          await playerController.pause();
        }
        emit(StateMediaPLayerLoaded());
      } else if (event is EventMediaPlayerSkipToNext) {
        emit(StateMediaPLayerLoaded());
      } else if (event is EventMediaPlayerSkipToPrevious) {
        emit(StateMediaPLayerLoaded());
      } else if (event is EventMediaPlayerSeekbarDrag) {
        await playerController
            .seekTo(Duration(milliseconds: event.value.toInt()));
        emit(StateMediaPLayerLoaded());
        await playerController.play();
        emit(StateMediaPLayerLoaded());
      } else if (event is EventMediaPlayerSkipForward10SecOnDoubleTap) {
        emit(StateMediaPLayerLoaded());
      } else if (event is EventMediaPlayerSkipBackWord10SecOnDoubleTap) {
        emit(StateMediaPLayerLoaded());
      } else if (event is EventMediaPlayerMoveToPIPMode) {
        emit(StateMediaPLayerLoaded());
      } else if (event is EventMediaPlayerLockSettings) {
        emit(StateMediaPLayerLoaded());
      } else if (event is EventMediaPlayerChangeAudio) {
        emit(StateMediaPLayerLoaded());
      } else if (event is EventMediaPlayerScreenModeChange) {
        emit(StateMediaPLayerLoaded());
      }else if (event is EventMediaChangeOrientation) {
        if (isHorizontal) {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
          ]);
          isHorizontal = false;
        } else {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeRight,
            DeviceOrientation.landscapeLeft,
          ]);
          isHorizontal = true;
        }
        emit(StateMediaPLayerLoaded());
      }
    });
  }
}
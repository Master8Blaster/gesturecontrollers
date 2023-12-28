import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gesturecontrollers/screens/player/media_player_event.dart';
import 'package:gesturecontrollers/screens/player/media_player_stats.dart';
import 'package:video_player/video_player.dart';

import '../../unitlity/GloableMethods.dart';

class MediaPLayerBloc extends Bloc<MediaPlayerEvents, MediaPlayerState> {
  GlobalKey<ScaffoldState> keyScaffold = GlobalKey<ScaffoldState>();
  late VideoPlayerController playerController;
  bool isInitialized = false;
  bool isHorizontal = true;
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
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
            overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
        if (!event.isFile) {
          playerController =
              VideoPlayerController.contentUri(Uri.parse(event.path));
        } else {
          playerController = VideoPlayerController.file(File(event.path));
        }
        if (!event.isFile
            ? await isInterConnected()
            : await File(event.path).exists()) {
          await playerController.initialize().then((value) {
            isInitialized = true;
            if (playerController.value.size.width >
                playerController.value.size.height) {
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.landscapeRight,
                DeviceOrientation.landscapeLeft,
              ]);
            } else {
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
              ]);
            }
            isControlsVisible = true;
            playerController.play();
            playerController.addListener(() {
              if (playerController.value.isBuffering) {
                emit(StateMediaPLayerLoaded());
              }
            });
            emit(StateMediaPLayerLoaded());
          });
        } else {
          if (!event.isFile) {
            print("else");
            showSnackBarWithText(keyScaffold.currentState, "No Internet!");
            Timer.periodic(const Duration(seconds: 1), (timer) async {
              if (await isInterConnected()) {
                timer.cancel();
                showSnackBarWithText(
                    keyScaffold.currentState, "Welcome Back To Online.");
                await playerController.initialize().then((value) async {
                  isInitialized = true;
                  isControlsVisible = true;
                  if (playerController.value.size.width >
                      playerController.value.size.height) {
                    SystemChrome.setPreferredOrientations([
                      DeviceOrientation.landscapeRight,
                      DeviceOrientation.landscapeLeft,
                    ]);
                  } else {
                    SystemChrome.setPreferredOrientations([
                      DeviceOrientation.portraitUp,
                    ]);
                  }
                  onEvent(EventMediaPlayerPlay());
                  playerController.addListener(() {
                    if (playerController.value.isBuffering) {
                      emit(StateMediaPLayerLoaded());
                    }
                  });

                  emit(StateMediaPLayerLoaded());
                });
              }
            });
          }
        }
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
      } else if (event is EventMediaControlsToggle) {
        isControlsVisible = !isControlsVisible;
        if (isControlsVisible) {
          makeVisibleControllers();
        } else {
          makeInVisibleControllers();
        }
        emit(StateMediaPLayerLoaded());
      } else if (event is EventMediaPlayerSkipForward10SecOnDoubleTap) {
        if ((playerController.value.position.inMilliseconds +
                const Duration(seconds: 10).inMilliseconds) <
            playerController.value.duration.inMilliseconds) {
          playerController.seekTo(Duration(
              milliseconds: playerController.value.position.inMilliseconds +
                  const Duration(seconds: 10).inMilliseconds));
        } else {
          playerController.seekTo(Duration(
              milliseconds: playerController.value.duration.inMilliseconds));
        }
        emit(StateMediaPLayerLoaded());
      } else if (event is EventMediaPlayerSkipBackWord10SecOnDoubleTap) {
        if ((playerController.value.position.inMilliseconds -
                const Duration(seconds: 10).inMilliseconds) >
            0) {
          await playerController.seekTo(Duration(
              milliseconds: playerController.value.position.inMilliseconds -
                  const Duration(seconds: 10).inMilliseconds));
        } else {
          await playerController.seekTo(const Duration(milliseconds: 0));
        }
        // emit(StateMediaPLayerLoaded());
        emit(StateMediaPLayerLoaded());
      } else if (event is EventMediaPlayerMoveToPIPMode) {
        emit(StateMediaPLayerLoaded());
      } else if (event is EventMediaPlayerLockSettings) {
        isControlsLocked = !isControlsLocked;
        emit(StateMediaPLayerLoaded());
      } else if (event is EventMediaPlayerChangeAudio) {
        emit(StateMediaPLayerLoaded());
      } else if (event is EventMediaPlayerScreenModeChange) {
        emit(StateMediaPLayerLoaded());
      } else if (event is EventMediaChangeOrientation) {
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

  makeVisibleControllers() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
  }

  makeInVisibleControllers() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: []);
  }
}

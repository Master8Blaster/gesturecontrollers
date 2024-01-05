import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:gesturecontrollers/screens/player/media_player_event.dart';
import 'package:gesturecontrollers/screens/player/media_player_stats.dart';

import '../../unitlity/GloableMethods.dart';

class MediaPLayerBloc extends Bloc<MediaPlayerEvents, MediaPlayerState> {
  GlobalKey<ScaffoldState> keyScaffold = GlobalKey<ScaffoldState>();
  VlcPlayerController? playerController;
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
        SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(
              systemNavigationBarColor: Color(0x66000000),
              statusBarColor: Color(0x88000000),
              statusBarBrightness: Brightness.dark),
        );
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
            overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
        if (!event.isFile) {
          playerController = VlcPlayerController.network(
            event.path,
            hwAcc: HwAcc.full,
            autoInitialize: false,
            options: VlcPlayerOptions(),
          );
        } else {
          print("Loading PATH:${event.path}");
          playerController = VlcPlayerController.file(
            File("/sdcard/DCIM/Screenshots/Record_2023-07-20-11-41-16_b3817964360fd149e258f790e50790e3.mp4"),
            hwAcc: HwAcc.full,
            autoInitialize: true,
            autoPlay: true,
            options: VlcPlayerOptions(),
            onInit: () {
              print("onInit");
              if (playerController != null) {
                isInitialized = true;
                if (playerController!.value.size.width >
                    playerController!.value.size.height) {
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
                playerController!.play();
                playerController!.addListener(() {
                  if (playerController!.value.isBuffering) {
                    emit(StateMediaPLayerLoaded());
                  }
                });
                emit(StateMediaPLayerLoaded());
              }
            },
          );
          playerController!.addOnInitListener(() {
            print("onInit");
            if (playerController != null) {
              isInitialized = true;
              if (playerController!.value.size.width >
                  playerController!.value.size.height) {
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
              playerController!.play();
              playerController!.addListener(() {
                if (playerController!.value.isBuffering) {
                  emit(StateMediaPLayerLoaded());
                }
              });
              emit(StateMediaPLayerLoaded());
            }
          });
          playerController!.addListener(() {
            print("Listener");
          });
        }
        if (!event.isFile
            ? await isInterConnected()
            : await File(event.path).exists()) {
          // await playerController.initialize().then((value) {
        }
        else {
          if (!event.isFile) {
            print("else");
            showSnackBarWithText(keyScaffold.currentState, "No Internet!");
            Timer.periodic(const Duration(seconds: 1), (timer) async {
              if (await isInterConnected()) {
                timer.cancel();
                showSnackBarWithText(
                    keyScaffold.currentState, "Welcome Back To Online.");
                await playerController!.initialize().then((value) async {
                  isInitialized = true;
                  isControlsVisible = true;
                  if (playerController!.value.size.width >
                      playerController!.value.size.height) {
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
                  playerController!.addListener(() {
                    if (playerController!.value.isBuffering) {
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
        if (playerController!.value.isInitialized) {
          await playerController!.play();
        }
        emit(StateMediaPLayerLoaded());
      } else if (event is EventMediaPlayerPause) {
        if (playerController!.value.isInitialized) {
          await playerController!.pause();
        }
        emit(StateMediaPLayerLoaded());
      } else if (event is EventMediaPlayerSkipToNext) {
        emit(StateMediaPLayerLoaded());
      } else if (event is EventMediaPlayerSkipToPrevious) {
        emit(StateMediaPLayerLoaded());
      } else if (event is EventMediaPlayerSeekbarDrag) {
        await playerController!
            .seekTo(Duration(milliseconds: event.value.toInt()));
        emit(StateMediaPLayerLoaded());
        await playerController!.play();
        emit(StateMediaPLayerLoaded());
      } else if (event is EventMediaControlsToggle) {
        if (!isControlsVisible) {
          makeVisibleControllers();
          await Future.delayed(const Duration(milliseconds: 200));
          isControlsVisible = true;
        } else {
          isControlsVisible = false;
          await Future.delayed(const Duration(milliseconds: 300));
          makeInVisibleControllers();
        }
        emit(StateMediaPLayerLoaded());
      } else if (event is EventMediaPlayerSkipForward10SecOnDoubleTap) {
        if ((playerController!.value.position.inMilliseconds +
                const Duration(seconds: 10).inMilliseconds) <
            playerController!.value.duration.inMilliseconds) {
          playerController!.seekTo(Duration(
              milliseconds: playerController!.value.position.inMilliseconds +
                  const Duration(seconds: 10).inMilliseconds));
        } else {
          playerController!.seekTo(Duration(
              milliseconds: playerController!.value.duration.inMilliseconds));
        }
        emit(StateMediaPLayerLoaded());
      } else if (event is EventMediaPlayerSkipBackWord10SecOnDoubleTap) {
        if ((playerController!.value.position.inMilliseconds -
                const Duration(seconds: 10).inMilliseconds) >
            0) {
          await playerController!.seekTo(Duration(
              milliseconds: playerController!.value.position.inMilliseconds -
                  const Duration(seconds: 10).inMilliseconds));
        } else {
          await playerController!.seekTo(const Duration(milliseconds: 0));
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

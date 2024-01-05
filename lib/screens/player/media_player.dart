import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:gesturecontrollers/screens/player/media_player_bloc.dart';
import 'package:gesturecontrollers/screens/player/media_player_event.dart';
import 'package:gesturecontrollers/screens/player/media_player_stats.dart';
import 'package:screen_brightness/screen_brightness.dart';

// import 'package:video_player/video_player.dart';
import 'package:volume_controller/volume_controller.dart';

class MediaPlayer extends StatefulWidget {
  bool isFile = false;
  String path = "";

  MediaPlayer({super.key, this.isFile = false, required this.path});

  @override
  State<MediaPlayer> createState() => _MediaPLayerState();
}

class _MediaPLayerState extends State<MediaPlayer> {
  final GlobalKey<ScaffoldState> _keyScaffold = GlobalKey<ScaffoldState>();
  late MediaPLayerBloc bloc;

  // bool isControlsAreVisible = true;
  bool stretchMode = false;
  int fadeOutAnimationDuration = 300;

  Timer? timer;

  @override
  void initState() {
    bloc = MediaPLayerBloc(keyScaffold: _keyScaffold);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
        setState(() {});
      });
      bloc.add(
        EventMediaPlayerInit(
          isFile: widget.isFile,
          path: widget.path,
        ),
      );
    });
  }

  @override
  Future<void> dispose() async {
    if (timer != null) {
      timer!.cancel();
    }
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    bloc.add(EventMediaPlayerPause());
    bloc.playerController!.dispose();
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _keyScaffold,
      backgroundColor: Colors.black,
      body: BlocBuilder(
        bloc: bloc,
        builder: (context, state) {
          if (state is StateMediaPLayerLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is StateMediaPLayerLoaded) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              extendBodyBehindAppBar: true,
              extendBody: true,
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x88000000),
                        Color(0x66000000),
                        Color(0x00000000),
                      ],
                    ),
                  ),
                  child: AppBar(
                    backgroundColor: Colors.transparent,
                    title: AnimatedOpacity(
                      opacity: bloc.isControlsVisible ? 1.0 : 0.0,
                      duration:
                          Duration(milliseconds: fadeOutAnimationDuration),
                      curve: Curves.easeInOutSine,
                      child: const Text(
                        "Master_hdbc_choose.mp4",
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
                    leading: !bloc.isControlsLocked
                        ? AnimatedOpacity(
                            opacity: bloc.isControlsVisible ? 1.0 : 0.0,
                            duration: Duration(
                                milliseconds: fadeOutAnimationDuration),
                            curve: Curves.easeInOutSine,
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          )
                        : IconButton(
                            icon: const Icon(
                              Icons.lock_rounded,
                              color: Colors.white,
                            ),
                            onPressed: () async {
                              bloc.isControlsVisible = true;
                              await makeVisibleControllers();
                              bloc.add(EventMediaPlayerLockSettings());
                            },
                          ),
                    titleSpacing: 0,
                  ),
                ),
              ),
              body: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  fit: StackFit.expand,
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: FittedBox(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        fit: stretchMode ? BoxFit.cover : BoxFit.contain,
                        child: SizedBox(
                          width: bloc.playerController!.value.size.width,
                          height: bloc.playerController!.value.size.height,
                          child: VlcPlayer(
                            controller: bloc.playerController!,
                            aspectRatio: 16 / 9,
                            placeholder: const Center(
                                child: CircularProgressIndicator()),
                          ),
                        ),
                      ),
                    ),
                    if (!bloc.isControlsLocked)
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: CustomGestureDetector(
                          bloc: bloc,
                          keyScaffold: _keyScaffold,
                        ),
                      ),
                    AnimatedOpacity(
                      opacity: bloc.isControlsVisible ? 1.0 : 0.0,
                      duration:
                          Duration(milliseconds: fadeOutAnimationDuration),
                      curve: Curves.easeInOutSine,
                      child: SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0x00000000),
                                    Color(0x66000000),
                                  ],
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 5),
                                  SizedBox(
                                    height: 14,
                                    child: CustomSlider(bloc: bloc),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () async {
                                          await makeInVisibleControllers();
                                          bloc.isControlsVisible = false;
                                          await Future.delayed(const Duration(
                                              milliseconds: 500));
                                          bloc.add(
                                              EventMediaPlayerLockSettings());
                                        },
                                        icon: const Icon(
                                          Icons.lock_open_rounded,
                                          color: Colors.white,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          stretchMode = !stretchMode;
                                          setState(() {});
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: RotatedBox(
                                            quarterTurns: stretchMode ? 3 : 0,
                                            child: Image.asset(
                                              "assets/pngs/expandIcons.png",
                                              color: Colors.white,
                                              height: 20,
                                              width: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        onPressed: () {
                                          bloc.add(
                                              EventMediaPlayerSkipToPrevious());
                                        },
                                        icon: Icon(
                                          Icons.skip_previous_rounded,
                                          color: Colors.white,
                                          size: bloc.isHorizontal ? 36 : 24,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          if (bloc.playerController!.value
                                              .isPlaying) {
                                            bloc.add(EventMediaPlayerPause());
                                          } else {
                                            bloc.add(EventMediaPlayerPlay());
                                          }
                                        },
                                        icon: Icon(
                                          bloc.playerController!.value.isPlaying
                                              ? Icons.pause_rounded
                                              : Icons.play_arrow_rounded,
                                          color: Colors.white,
                                          size: bloc.isHorizontal ? 48 : 36,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          bloc.add(
                                              EventMediaPlayerSkipToNext());
                                        },
                                        icon: Icon(
                                          Icons.skip_next_rounded,
                                          color: Colors.white,
                                          size: bloc.isHorizontal ? 36 : 24,
                                        ),
                                      ),
                                      if (!bloc.isHorizontal) const Spacer(),
                                      IconButton(
                                        onPressed: () {
                                          bloc.add(
                                              EventMediaChangeOrientation());
                                        },
                                        icon: const Icon(
                                          Icons.screen_rotation_alt_rounded,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (bloc.playerController!.value.isBuffering)
                      InkWell(
                        onTap: () {},
                        child: Container(
                          color: Colors.black45,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                Text(
                                  "Buffering...",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          } else {
            return Container();
          }
        },
      ),
    );
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

class CustomSlider extends StatefulWidget {
  final MediaPLayerBloc bloc;

  const CustomSlider({super.key, required this.bloc});

  @override
  State<CustomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  @override
  void initState() {
    super.initState();
  }

  String getTwoDigit(int value) {
    return value < 10 ? "0$value" : value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "${widget.bloc.playerController!.value.position.inHours > 0 ? "${getTwoDigit(widget.bloc.playerController!.value.position.inHours)}:" : ""}${getTwoDigit(widget.bloc.playerController!.value.position.inMinutes % 60)}:${getTwoDigit(widget.bloc.playerController!.value.position.inSeconds % 60)}",
          style: const TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.w400),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              inactiveTrackColor: Colors.white30,
              activeTrackColor: Theme.of(context).primaryColor,
              thumbColor: Theme.of(context).primaryColor,
              overlayColor: Theme.of(context).primaryColor.withAlpha(5),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 15),
              trackHeight: 2,
            ),
            child: Slider(
              min: 0,
              max: widget.bloc.playerController!.value.duration.inMilliseconds
                  .toDouble(),
              value: widget.bloc.playerController!.value.position.inMilliseconds
                  .toDouble(),
              onChanged: (double value) {
                widget.bloc.add(EventMediaPlayerSeekbarDrag(value));
              },
            ),
          ),
        ),
        Text(
          "${widget.bloc.playerController!.value.duration.inHours > 0 ? "${getTwoDigit(widget.bloc.playerController!.value.duration.inHours)}:" : ""}${getTwoDigit(widget.bloc.playerController!.value.duration.inMinutes % 60)}:${getTwoDigit(widget.bloc.playerController!.value.duration.inSeconds % 60)}",
          style: const TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class CustomGestureDetector extends StatefulWidget {
  final GlobalKey<ScaffoldState> keyScaffold;
  final MediaPLayerBloc bloc;

  const CustomGestureDetector(
      {super.key, required this.bloc, required this.keyScaffold});

  @override
  State<CustomGestureDetector> createState() => _CustomGestureDetectorState();
}

class _CustomGestureDetectorState extends State<CustomGestureDetector> {
  // brightness variables
  double brightness = 0.5;
  double previousBrightness = 0.5;
  double yBrightness = 0.0;
  bool isDraggingBrightness = false;

  // volume controller variables
  double volume = 0.5;
  double previousVolume = 0.5;
  double yVolume = 0.0;
  bool isDraggingVolume = false;

  //Slide Horizontal to skip variables
  double seek = 0.0;
  double previousSlideSkip = 0.5;
  double ySlideSkip = 0.0;

  bool toggleForwardAnimation = false;
  bool toggleBackWordAnimation = false;

  void onTap() {
    if (!widget.bloc.isControlsLocked &&
        widget.keyScaffold.currentState != null) {
      widget.bloc.add(EventMediaControlsToggle());
    }
  }

  void onHorizontalDragStart(data) {
    ySlideSkip = data.globalPosition.dx;
    seek =
        widget.bloc.playerController!.value.position.inMilliseconds.toDouble();
    setState(() {});
  }

  void onHorizontalDragUpdate(data) {
    double d =
        previousSlideSkip + ((data.globalPosition.dx - ySlideSkip) / 100);
    // print("D : $d");
    if (d > 0 &&
        d < widget.bloc.playerController!.value.duration.inMilliseconds) {
      seek = d;
    } else if (d < 0) {
      seek = 0;
    } else if (d >
        widget.bloc.playerController!.value.duration.inMilliseconds) {
      seek = widget.bloc.playerController!.value.duration.inMilliseconds
          .toDouble();
    }

    widget.bloc.playerController!
        .seekTo(Duration(milliseconds: (seek * 5000).toInt()));
    setState(() {});
  }

  void onHorizontalDragEnd(data) {
    previousSlideSkip = seek;
    setState(() {});
  }

  startTimerToDismissAnimation({required bool isForward}) async {
    if (isForward) {
      toggleForwardAnimation = true;
      setState(() {});
      await Future.delayed(const Duration(seconds: 1));
      toggleForwardAnimation = false;
    } else {
      toggleBackWordAnimation = true;
      setState(() {});
      await Future.delayed(const Duration(seconds: 1));
      toggleBackWordAnimation = false;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    ScreenBrightness().hasChanged.then((value) async {
      brightness = await ScreenBrightness().current;
      setState(() {});
    });
    previousVolume = await VolumeController().getVolume();
    volume = previousVolume;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              onDoubleTap: () {
                if (!widget.bloc.isControlsLocked &&
                    widget.keyScaffold.currentState != null) {
                  startTimerToDismissAnimation(isForward: false);
                  widget.bloc
                      .add(EventMediaPlayerSkipBackWord10SecOnDoubleTap());
                }
              },
              onVerticalDragStart: (data) {
                yBrightness = data.globalPosition.dy;
                setState(() {
                  isDraggingBrightness = true;
                });
              },
              onVerticalDragUpdate: (data) {
                double d = previousBrightness +
                    ((yBrightness - data.globalPosition.dy) / 100);
                if (d > 0 && d < 1) {
                  brightness = d;
                } else if (d < 0) {
                  brightness = 0;
                } else if (d > 1) {
                  brightness = 1;
                }
                print(brightness);
                setBrightness(brightness);

                setState(() {});
              },
              onVerticalDragEnd: (details) {
                previousBrightness = brightness;
                setState(() {
                  isDraggingBrightness = false;
                });
              },
              onHorizontalDragStart: onHorizontalDragStart,
              onHorizontalDragUpdate: onHorizontalDragUpdate,
              onHorizontalDragEnd: onHorizontalDragEnd,
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.only(left: 50),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedOpacity(
                        opacity: isDraggingVolume ? 1 : 0,
                        duration: const Duration(milliseconds: 500),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 36,
                                child: Text(
                                  (volume * 100).toInt().toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 100,
                                child: FAProgressBar(
                                  size: 3,
                                  direction: Axis.vertical,
                                  animatedDuration:
                                      const Duration(milliseconds: 100),
                                  currentValue: volume * 100,
                                  backgroundColor: Colors.white38,
                                  borderRadius: BorderRadius.circular(2),
                                  formatValue: (value, fixed) {
                                    return (volume * 10).toInt().toString();
                                  },
                                  formatValueFixed: 100,
                                  progressColor: Colors.lightBlueAccent,
                                  changeProgressColor: Colors.lightBlueAccent,
                                  maxValue: 100,
                                  verticalDirection: VerticalDirection.up,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Icon(
                                Icons.volume_up_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    AnimatedOpacity(
                      opacity: toggleBackWordAnimation ? 1 : 0,
                      duration: const Duration(milliseconds: 500),
                      child: const Icon(
                        Icons.replay_10_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onVerticalDragStart: (data) {
                yVolume = data.globalPosition.dy;
                setState(() {
                  isDraggingVolume = true;
                });
              },
              onVerticalDragUpdate: (data) {
                double d =
                    previousVolume + ((yVolume - data.globalPosition.dy) / 100);
                if (d > 0 && d < 1) {
                  volume = d;
                } else if (d < 0) {
                  volume = 0;
                } else if (d > 1) {
                  volume = 1;
                }
                print(volume);
                VolumeController().setVolume(volume, showSystemUI: false);

                setState(() {});
              },
              onVerticalDragEnd: (details) {
                previousVolume = volume;
                setState(() {
                  isDraggingVolume = false;
                });
              },
              onHorizontalDragStart: onHorizontalDragStart,
              onHorizontalDragUpdate: onHorizontalDragUpdate,
              onHorizontalDragEnd: onHorizontalDragEnd,
              onDoubleTap: () {
                if (!widget.bloc.isControlsLocked &&
                    widget.keyScaffold.currentState != null) {
                  startTimerToDismissAnimation(isForward: true);
                  widget.bloc
                      .add(EventMediaPlayerSkipForward10SecOnDoubleTap());
                }
              },
              onTap: onTap,
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.only(right: 50),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: AnimatedOpacity(
                        opacity: isDraggingBrightness ? 1 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 36,
                                child: Text(
                                  (brightness * 100).toInt().toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 100,
                                child: FAProgressBar(
                                  size: 3,
                                  direction: Axis.vertical,
                                  animatedDuration:
                                      const Duration(milliseconds: 100),
                                  currentValue: brightness * 100,
                                  backgroundColor: Colors.white38,
                                  borderRadius: BorderRadius.circular(2),
                                  formatValue: (value, fixed) {
                                    return (brightness * 10).toInt().toString();
                                  },
                                  formatValueFixed: 100,
                                  progressColor: Colors.lightBlueAccent,
                                  changeProgressColor: Colors.lightBlueAccent,
                                  maxValue: 100,
                                  verticalDirection: VerticalDirection.up,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Icon(
                                Icons.brightness_6_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    AnimatedOpacity(
                      opacity: toggleForwardAnimation ? 1 : 0,
                      duration: const Duration(milliseconds: 500),
                      child: const Icon(
                        Icons.forward_10_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ],
                ),
              ),
              /* child: Container(
                  child: Center(
                    child: Container(
                      height: 100,
                      // width: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                      child: FAProgressBar(
                        direction: Axis.vertical,
                        animatedDuration: const Duration(milliseconds: 100),
                        border: Border.all(color: Colors.white, width: 1),
                        currentValue: volume * 100,
                        backgroundColor: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                        formatValue: (value, fixed) {
                          return (volume * 10).toInt().toString();
                        },
                        formatValueFixed: 100,
                        progressColor: Colors.lightBlueAccent,
                        changeProgressColor: Colors.lightBlueAccent,
                        displayText: (volume * 0).toInt().toString(),
                        maxValue: 100,
                        verticalDirection: VerticalDirection.up,
                      ),
                    ),
                  ),
                ),*/
            ),
          ),
        ],
      ),
    );
  }

  Future<void> setBrightness(double brightness) async {
    try {
      await ScreenBrightness().setScreenBrightness(brightness);
    } catch (e) {
      print(e);
      throw 'Failed to set brightness';
    }
  }
}

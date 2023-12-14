import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_seekbar/flutter_seekbar.dart';
import 'package:gesturecontrollers/screens/player/media_player_bloc.dart';
import 'package:gesturecontrollers/screens/player/media_player_event.dart';
import 'package:gesturecontrollers/screens/player/media_player_stats.dart';
import 'package:video_player/video_player.dart';

class MediaPlayer extends StatefulWidget {
  const MediaPlayer({super.key});

  @override
  State<MediaPlayer> createState() => _MediaPLayerState();
}

class _MediaPLayerState extends State<MediaPlayer> {
  final GlobalKey<ScaffoldState> _keyScaffold = GlobalKey<ScaffoldState>();
  late MediaPLayerBloc bloc;
  bool isControlsAreVisible = true;
  int fadeOutAnimationDuration = 500;

  @override
  void initState() {
    bloc = MediaPLayerBloc(keyScaffold: _keyScaffold);
    super.initState();
    bloc.add(
      EventMediaPlayerInit(
        isFile: false,
        path:
            "https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_30mb.mp4",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: bloc,
      builder: (context, state) {
        if (state is StateMediaPLayerLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is StateMediaPLayerLoaded) {
          return Stack(
            fit: StackFit.expand,
            children: [
              /*if (bloc.isInitialized)
                Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Container(),
                ),*/
              // if (isControlsAreVisible)
              Scaffold(
                key: _keyScaffold,
                backgroundColor: Colors.transparent,
                extendBodyBehindAppBar: true,
                extendBody: true,
                appBar: PreferredSize(
                  preferredSize: const Size(double.infinity, kToolbarHeight),
                  child: AnimatedOpacity(
                    opacity: isControlsAreVisible ? 1.0 : 0.0,
                    duration: Duration(milliseconds: fadeOutAnimationDuration),
                    curve: Curves.easeInOutSine,
                    child: AppBar(
                      backgroundColor: Colors.transparent,
                      title: const Text(
                        "Master_hdbc_choose.mp4",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      leading: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      titleSpacing: 0,
                    ),
                  ),
                ),
                body: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    fit: StackFit.expand,
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              isControlsAreVisible = !isControlsAreVisible;
                              if (isControlsAreVisible) {
                                SystemChrome.setEnabledSystemUIMode(
                                    SystemUiMode.edgeToEdge,
                                    overlays: [SystemUiOverlay.top]);
                                SystemChrome.setEnabledSystemUIMode(
                                    SystemUiMode.edgeToEdge,
                                    overlays: [SystemUiOverlay.bottom]);
                              } else {
                                SystemChrome.setEnabledSystemUIMode(
                                    SystemUiMode.manual,
                                    overlays: []);
                              }
                            });
                          },
                          child: AspectRatio(
                            aspectRatio:
                                bloc.playerController.value.aspectRatio,
                            child: VideoPlayer(bloc.playerController),
                          ),
                        ),
                      ),
                      AnimatedOpacity(
                        opacity: isControlsAreVisible ? 1.0 : 0.0,
                        duration:
                            Duration(milliseconds: fadeOutAnimationDuration),
                        curve: Curves.easeInOutSine,
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
                                  const SizedBox(height: 10),
                                  CustomSlider(bloc: bloc),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          bloc.add(
                                              EventMediaPlayerLockSettings());
                                        },
                                        icon: const Icon(
                                          Icons.lock,
                                          color: Colors.white,
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
                                          if (bloc.playerController.value
                                              .isPlaying) {
                                            bloc.add(EventMediaPlayerPause());
                                          } else {
                                            bloc.add(EventMediaPlayerPlay());
                                          }
                                        },
                                        icon: Icon(
                                          bloc.playerController.value.isPlaying
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
                                      const Spacer(),
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
                            const SizedBox(height: 10),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        } else {
          return Container();
        }
      },
    );
  }
}

class CustomSlider extends StatefulWidget {
  final MediaPLayerBloc bloc;

  const CustomSlider({super.key, required this.bloc});

  @override
  State<CustomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  Timer? timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        setState(() {});
      });
    });
  }

  String getTwoDigit(int value) {
    return value < 10 ? "0$value" : value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "${getTwoDigit(widget.bloc.playerController.value.position.inHours)}:${getTwoDigit(widget.bloc.playerController.value.position.inMinutes % 60)}:${getTwoDigit(widget.bloc.playerController.value.position.inSeconds % 60)}",
          style: const TextStyle(color: Colors.white),
        ),
        Expanded(
          child: SizedBox(
            height: 2,
            child: Slider(
              min: 0,
              thumbColor: Theme.of(context).primaryColor,
              activeColor: Theme.of(context).primaryColor,
              secondaryActiveColor: Colors.white,
              max: widget.bloc.playerController.value.duration.inMilliseconds
                  .toDouble(),
              value: widget.bloc.playerController.value.position.inMilliseconds
                  .toDouble(),
              onChanged: (double value) {
                widget.bloc.add(EventMediaPlayerSeekbarDrag(value));
              },
            ),
          ),
        ),
        Text(
          "${getTwoDigit(widget.bloc.playerController.value.duration.inHours)}:${getTwoDigit(widget.bloc.playerController.value.duration.inMinutes % 60)}:${getTwoDigit(widget.bloc.playerController.value.duration.inSeconds % 60)}",
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
    }
    super.dispose();
  }
}

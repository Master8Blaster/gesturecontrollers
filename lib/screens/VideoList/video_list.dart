import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:gesturecontrollers/screens/VideoList/video_list_bloc.dart';
import 'package:gesturecontrollers/screens/VideoList/video_list_event.dart';
import 'package:gesturecontrollers/screens/VideoList/video_list_states.dart';
import 'package:gesturecontrollers/unitlity/colors.dart';

import '../../unitlity/GloableMethods.dart';
import '../player/media_player.dart';
import 'models/VideoDataModel.dart';

class VideoList extends StatefulWidget {
  const VideoList({super.key});

  @override
  State<VideoList> createState() => _VideoListState();
}

class _VideoListState extends State<VideoList> {
  late VideoListBloc _bloc;
  final GlobalKey<ScaffoldState> _keyScaffold = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _bloc = VideoListBloc(keyScaffold: _keyScaffold);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _bloc.add(EventLoadVideoList());
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _keyScaffold,
        appBar: AppBar(
          backgroundColor: colorBackGround,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () {
                _bloc.add(EventLoadVideoList());
              },
            )
          ],
        ),
        body: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              Expanded(
                child: BlocBuilder<VideoListBloc, VideoListStates>(
                  bloc: _bloc,
                  builder: (BuildContext context, state) {
                    if (state is StateVideoListLoading ||
                        state is StateVideoListLoaded) {
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          AnimatedOpacity(
                            duration: const Duration(seconds: 1),
                            opacity: state is StateVideoListLoading ? 1 : 0,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          AnimatedOpacity(
                            opacity: state is StateVideoListLoaded ? 1 : 0,
                            duration: const Duration(seconds: 1),
                            child: state is StateVideoListLoaded &&
                                    state.list != null
                                ? ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: state.list!.length,
                                    itemBuilder: (context, index) {
                                      VideoDataModel model = state.list![index];
                                      return InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    MediaPlayer(
                                                  path: model.path,
                                                  isFile: true,
                                                ),
                                              ));
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                            top: 7,
                                            right: 10,
                                            left: 10,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: CustomThumbnail(
                                                    model: model),
                                              ),
                                              const SizedBox(width: 7),
                                              Expanded(
                                                flex: 3,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      state.list![index].path
                                                          .split("/")
                                                          .last,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 12),
                                                    ),
                                                    Text(
                                                      model.sizeInString,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 12),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : Container(),
                          ),
                        ],
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomThumbnail extends StatefulWidget {
  VideoDataModel model;

  CustomThumbnail({super.key, required this.model});

  @override
  State<CustomThumbnail> createState() => _CustomThumbnailState();
}

class _CustomThumbnailState extends State<CustomThumbnail> {
  VlcPlayerController? controller;

  @override
  void initState() {
    print("init");

    controller = VlcPlayerController.file(
      widget.model.file,
      autoInitialize: true,
      hwAcc: HwAcc.full,
      options: VlcPlayerOptions(),
    );
    super.initState();
    // ini();
  }

  ini() async {
    if (controller != null) {
      await controller!.initialize();
      print("WIDTH : ${controller!.value.size.width}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: (MediaQuery.of(context).size.width - 27) / 3,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      decoration: BoxDecoration(
        color: colorBackGroundLite,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          controller != null && controller!.value.isInitialized
              ? FittedBox(
                  fit: BoxFit.cover,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: controller!.value.size.width,
                    height: controller!.value.size.height,
                    child: VlcPlayer(
                      controller: controller!,
                      aspectRatio: 16 / 9,
                      placeholder: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                )
              : Center(
                  child: Icon(
                    Icons.image_outlined,
                    color: Colors.grey.shade400,
                  ),
                ),
          Positioned(
            bottom: 3,
            right: 5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colorPrimary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                durationToString(controller!.value.duration),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

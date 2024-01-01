import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gesturecontrollers/screens/VideoList/video_list_bloc.dart';
import 'package:gesturecontrollers/screens/VideoList/video_list_event.dart';
import 'package:gesturecontrollers/screens/VideoList/video_list_states.dart';
import 'package:gesturecontrollers/unitlity/colors.dart';

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
                                      return Container(
                                        margin: const EdgeInsets.only(
                                          top: 7,
                                          right: 10,
                                          left: 10,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                height: 70,
                                                decoration: BoxDecoration(
                                                  color: Colors.black26,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    10,
                                                  ),
                                                ),
                                                child: Center(
                                                  child: state.list![index]
                                                              .thumbnailFile !=
                                                          null
                                                      ? Image.file(
                                                          state.list![index]
                                                              .thumbnailFile!,
                                                          height: 60,
                                                          fit: BoxFit.cover,
                                                          color: Colors
                                                              .yellowAccent,
                                                        )
                                                      : const Icon(
                                                          Icons.not_interested),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 7),
                                            Expanded(
                                              flex: 3,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    state.list![index].fileName,
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

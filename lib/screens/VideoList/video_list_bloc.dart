import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:gesturecontrollers/screens/VideoList/video_list_event.dart';
import 'package:gesturecontrollers/screens/VideoList/video_list_states.dart';
import 'package:gesturecontrollers/screens/VideoList/video_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoListBloc extends Bloc<VideoListEvents, VideoListStates> {
  GlobalKey<ScaffoldState> keyScaffold = GlobalKey<ScaffoldState>();
  List<VideoModel> videoList = [];

  VideoListBloc({required this.keyScaffold}) : super(StateVideoListInitial()) {
    on((event, emit) async {
      if (event is EventLoadVideoList) {
        videoList.clear();
        emit(StateVideoListLoading());
        await getVideoFiles();
        emit(StateVideoListLoaded(videoList));
      } else if (event is EventRefreshVideoList) {
        emit(StateVideoListLoaded(videoList));
      } else {
        emit(StateVideoListInitial());
      }
    });
  }

  getVideoFiles() async {
    List<FileSystemEntity> files = [];
    List<FileSystemEntity> mainFiles = Directory("/sdcard").listSync();

    for (FileSystemEntity file in mainFiles) {
      if (!file.path.contains("Android") && file is Directory) {
        files.addAll(Directory(file.path).listSync(recursive: true));
      } else if (file is File) {
        files.add(file);
      }
    }

    for (FileSystemEntity model in files) {
      if (model is File &&
          (model.path.contains(".mp4") ||
              model.path.contains(".mkv") ||
              model.path.contains(".mov") ||
              model.path.contains(".avi") ||
              model.path.contains(".m4v") ||
              model.path.contains(".3gp"))) {
        VideoPlayerController controller = VideoPlayerController.file(model);
        controller.initialize().then(
          (value) async {
            /* File? thumbnail;
            try {
              Uint8List? thumbnailBytes = await VideoThumbnail.thumbnailData(
                video: model.path,
                imageFormat: ImageFormat.PNG,
                maxHeight: 60,
                quality: 100,
              );
              if (thumbnailBytes != null) {
                Directory cache = await getApplicationCacheDirectory();
                thumbnail = await File(
                        "${cache.path}/${model.path.split("/").last}.png")
                    .writeAsBytes(thumbnailBytes);
                thumbnailBytes = null;
              }
              print("MODEL ${thumbnail.toString()}");
            } catch (e) {
              print("ERROR : $e");
            }*/

            videoList.add(VideoModel(
              file: model,
              hd: controller.value.duration.inHours,
              md: controller.value.duration.inMinutes % 60,
              sd: controller.value.duration.inSeconds % 60,
              sizeInKb: model.lengthSync() ~/ 1000,
            ));
            await controller.dispose();
          },
        );

        // print("MODEL ${model.toString()}");
      }
    }
  }
}

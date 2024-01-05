import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gesturecontrollers/screens/VideoList/video_list_event.dart';
import 'package:gesturecontrollers/screens/VideoList/video_list_states.dart';
import 'package:gesturecontrollers/screens/VideoList/models/video_model.dart';
import 'package:permission_handler/permission_handler.dart';

import 'models/FolderModel.dart';
import 'models/VideoDataModel.dart';

class VideoListBloc extends Bloc<VideoListEvents, VideoListStates> {
  GlobalKey<ScaffoldState> keyScaffold = GlobalKey<ScaffoldState>();

  List<String> supportVideoExtension = [
    ".mov",
    ".mp4",
    ".wmv",
    ".webm",
    ".avi",
    ".mkv",
    ".mts",
    ".avchd",
  ];
  List<VideoDataModel> listVideos = [];
  List<FolderModel> folderList = [];

  VideoListBloc({required this.keyScaffold}) : super(StateVideoListInitial()) {
    on((event, emit) async {
      if (event is EventLoadVideoList) {
        listVideos.clear();
        folderList.clear();
        emit(StateVideoListLoading());
        await checkPermission();
        emit(StateVideoListLoaded(listVideos));
      } else if (event is EventRefreshVideoList) {
        emit(StateVideoListLoaded(listVideos));
      } else {
        emit(StateVideoListInitial());
      }
    });
  }

  checkPermission() async {
    var status = await Permission.storage.status;
    var statusVideo = await Permission.videos.status;

    status = await Permission.storage.request();

    statusVideo = await Permission.videos.request();
    statusVideo = await Permission.photos.request();

    print(
        "STORAGE : ${status.isGranted} , VIDEO STATUS : ${statusVideo.isGranted}");

    if (status.isGranted || statusVideo.isGranted) {
      await getAllVideos();
    } else if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(keyScaffold.currentContext!).showSnackBar(const SnackBar(
          content: Text(
              "We need permission to fetch video from storage! PLease grant us the permission without permission we can not fetch the videos.")));
    }
  }

  getAllVideos() async {
    Directory? directory = Directory("/sdcard/");
    List<FileSystemEntity> allVideoFiles = [];
    print("directory :${directory.path}");
    List<FileSystemEntity> directories = await directory
        .list()
        .where((entity) => !entity.path.contains("/sdcard/Android"))
        .toList();
    print("directories : ${directories.length}");
    for (int i = 0; i < directories.length; i++) {
      if (directories[i] is Directory) {
        print("directories : ${directories[i].path}");
        if (!directories[i].path.contains("/sdcard/Android") &&
            !directories[i]
                .path
                .split("/")
                .any((element) => element.startsWith("."))) {
          List<FileSystemEntity> files = await Directory(directories[i].path)
              .list(recursive: true, followLinks: false)
              .where((entity) =>
                  !entity.path.contains("/storage/emulated/0/Android")
                      ? supportVideoExtension
                          .any((element) => entity.path.endsWith(element))
                      : false)
              .toList();
          print("directories : ${directories[i].path}");
          allVideoFiles.addAll(files);
        }
      } else if (directories[i] is File) {
        if (supportVideoExtension
            .any((element) => directories[i].path.endsWith(element))) {
          allVideoFiles.add(directories[i]);
        }
      }
    }
    print("_files.length : $allVideoFiles");
    setUpAllVideoFiles(allVideoFiles);
  }

  setUpAllVideoFiles(List<FileSystemEntity> dataList) {
    for (FileSystemEntity model in dataList) {
      folderList.firstWhere(
        (element) {
          if (element.path == model.parent.path) {
            element.videoList.add(
              VideoDataModel(
                file: File(model.path),
                parentPath: model.parent.path,
                path: model.path,
              ),
            );
            return true;
          } else {
            return false;
          }
        },
        orElse: () {
          folderList.add(FolderModel(
              path: model.parent.path,
              folderName: model.parent.path.split("/").last,
              videoList: []));
          return folderList.last;
        },
      );
      listVideos.add(
        VideoDataModel(
          file: File(model.path),
          parentPath: model.parent.path,
          path: model.path,
        ),
      );
    }
    folderList.sort(
      (a, b) {
        return a.folderName.compareTo(b.folderName);
      },
    );
  }

/*  getVideoFiles() async {
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
            */ /* File? thumbnail;
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
            }*/ /*

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
  }*/
}


import 'VideoDataModel.dart';

class FolderModel {
  String path;
  String folderName;
  List<VideoDataModel> videoList;

  FolderModel({
    required this.path,
    required this.folderName,
    required this.videoList,
  });
}
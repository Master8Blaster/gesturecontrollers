import 'dart:io';

import 'package:flutter/foundation.dart';

class VideoDataModel {
  File file;
  String path;
  String parentPath;
  int sizeInMb = 0;
  String sizeInString = "";

  VideoDataModel({
    required this.file,
    required this.path,
    required this.parentPath,
  }) {
    sizeInMb = 00;
    sizeInString = "";
  }
}

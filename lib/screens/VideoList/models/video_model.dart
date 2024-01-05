import 'dart:io';

import 'package:flutter/services.dart';

class VideoModel {
  String fileName = "";
  File file;
  File? thumbnailFile;

  ///* hd Hours of Duration
  ///* md Minutes of Duration
  ///* sd Seconds of Duration
  int hd = 0, md = 0, sd = 0;

  ///* File size
  int sizeInKb = 0;

  VideoModel({
    required this.file,
    this.thumbnailFile,
    this.hd = 0,
    this.md = 0,
    this.sd = 0,
    this.sizeInKb = 0,
  }) {
    fileName = file.path.split("/").last;
    print("Size $sizeInKb");
  }
}

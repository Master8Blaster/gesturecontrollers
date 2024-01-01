import 'package:gesturecontrollers/screens/VideoList/video_model.dart';

abstract class VideoListStates {}

class StateVideoListInitial extends VideoListStates {}

class StateVideoListLoading extends VideoListStates {}

class StateVideoListLoaded extends VideoListStates {
  final List<VideoModel>? list;

  StateVideoListLoaded(this.list);
}

import 'models/VideoDataModel.dart';

abstract class VideoListStates {}

class StateVideoListInitial extends VideoListStates {}

class StateVideoListLoading extends VideoListStates {}

class StateVideoListLoaded extends VideoListStates {
  final List<VideoDataModel>? list;

  StateVideoListLoaded(this.list);
}

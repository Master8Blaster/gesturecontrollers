import 'package:video_player/video_player.dart';

abstract class MediaPlayerState {}

class StateMediaPlayerInitial extends MediaPlayerState {}

class StateMediaPLayerLoading extends MediaPlayerState {}

class StateMediaPLayerLoaded extends MediaPlayerState {
}

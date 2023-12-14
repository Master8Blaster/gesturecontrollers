abstract class MediaPlayerEvents {}

class EventMediaPlayerInit extends MediaPlayerEvents {
  String path;
  bool isFile = true;

  EventMediaPlayerInit({required this.path, this.isFile = true});
}

class EventMediaPlayerPlay extends MediaPlayerEvents {}

class EventMediaPlayerPause extends MediaPlayerEvents {}

class EventMediaPlayerSkipToNext extends MediaPlayerEvents {}

class EventMediaPlayerSkipToPrevious extends MediaPlayerEvents {}

class EventMediaPlayerSkipForward10SecOnDoubleTap extends MediaPlayerEvents {}

class EventMediaPlayerSkipBackWord10SecOnDoubleTap extends MediaPlayerEvents {}

class EventMediaPlayerSeekbarDrag extends MediaPlayerEvents {
  double value;

  EventMediaPlayerSeekbarDrag(this.value);
}

class EventMediaPlayerScreenModeChange extends MediaPlayerEvents {}

class EventMediaPlayerMoveToPIPMode extends MediaPlayerEvents {}

class EventMediaPlayerChangeAudio extends MediaPlayerEvents {}

class EventMediaPlayerLockSettings extends MediaPlayerEvents {

}


class EventMediaChangeOrientation extends MediaPlayerEvents {}

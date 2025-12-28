enum PlayStatus {
  paused,
  playing,
  completed,
}

extension PlayStatusExt on PlayStatus {
  bool get isPlaying {
    return this == PlayStatus.playing;
  }

  bool get isPaused {
    return this == PlayStatus.paused;
  }

  bool get isCompleted {
    return this == PlayStatus.completed;
  }
}

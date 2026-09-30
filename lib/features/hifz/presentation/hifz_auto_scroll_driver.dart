double hifzAutoScrollPixelsPerSecond(double normalizedSpeed) {
  if (!normalizedSpeed.isFinite ||
      normalizedSpeed < 0 ||
      normalizedSpeed > 1) {
    throw ArgumentError.value(
      normalizedSpeed,
      'normalizedSpeed',
      'must be within 0.0..1.0',
    );
  }
  return 8 + (72 - 8) * normalizedSpeed;
}

double hifzAutoScrollNextOffset({
  required double currentOffset,
  required double maxScrollExtent,
  required double normalizedSpeed,
  required Duration elapsed,
}) {
  final pixelsPerSecond = hifzAutoScrollPixelsPerSecond(normalizedSpeed);
  final seconds = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
  final next = currentOffset + pixelsPerSecond * seconds;
  if (next <= 0) return 0;
  if (next >= maxScrollExtent) return maxScrollExtent;
  return next;
}

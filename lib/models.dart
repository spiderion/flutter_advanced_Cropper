class ImageAdjustmentValues {
  double exposure;
  double brightness;
  double contrast;
  double saturation;
  double warmth;
  double tint;
  double highlights;
  double shadows;
  double vibrance;
  double sharpness;
  double clarity;

  ImageAdjustmentValues({
    this.exposure = 0.0,
    this.brightness = 0.0,
    this.contrast = 0.0,
    this.saturation = 0.0,
    this.warmth = 0.0,
    this.tint = 0.0,
    this.highlights = 0.0,
    this.shadows = 0.0,
    this.vibrance = 0.0,
    this.sharpness = 0.0,
    this.clarity = 0.0,
  });

  bool get hasAnyAdjustments {
    return exposure != 0.0 ||
        brightness != 0.0 ||
        contrast != 0.0 ||
        saturation != 0.0 ||
        warmth != 0.0 ||
        tint != 0.0 ||
        highlights != 0.0 ||
        shadows != 0.0 ||
        vibrance != 0.0 ||
        sharpness != 0.0 ||
        clarity != 0.0;
  }

  void reset() {
    exposure = 0.0;
    brightness = 0.0;
    contrast = 0.0;
    saturation = 0.0;
    warmth = 0.0;
    tint = 0.0;
    highlights = 0.0;
    shadows = 0.0;
    vibrance = 0.0;
    sharpness = 0.0;
    clarity = 0.0;
  }

  ImageAdjustmentValues copy() {
    return ImageAdjustmentValues(
      exposure: exposure,
      brightness: brightness,
      contrast: contrast,
      saturation: saturation,
      warmth: warmth,
      tint: tint,
      highlights: highlights,
      shadows: shadows,
      vibrance: vibrance,
      sharpness: sharpness,
      clarity: clarity,
    );
  }
}

class AdjustmentOption {
  final String name;
  final String icon;
  final double min;
  final double max;
  final double defaultValue;

  const AdjustmentOption({
    required this.name,
    required this.icon,
    required this.min,
    required this.max,
    this.defaultValue = 0.0,
  });
}

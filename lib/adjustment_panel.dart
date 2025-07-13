import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'image_adjustment_screen.dart';
import 'models.dart';

class AdjustPanel extends StatefulWidget {
  final ImageAdjustmentValues adjustments;
  final ValueChanged<ImageAdjustmentValues> onAdjustmentsChanged;
  final VoidCallback? onReset;
  final Animation<double> animation;

  const AdjustPanel({
    super.key,
    required this.adjustments,
    required this.onAdjustmentsChanged,
    required this.animation,
    this.onReset,
  });

  @override
  State<AdjustPanel> createState() => _AdjustPanelState();
}

class _AdjustPanelState extends State<AdjustPanel> {
  String _selectedAdjustment = 'Exposure';
  late ScrollController _scrollController;
  late ImageAdjustmentValues _localAdjustments;

  @override
  void initState() {
    _localAdjustments = widget.adjustments.copy(); // Initialize local copy
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AdjustPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update local adjustments when widget updates
    if (oldWidget.adjustments != widget.adjustments) {
      _localAdjustments = widget.adjustments.copy();
      setState(() {});
    }
  }

  void _onAdjustmentChanged(double value) {
    print('Changing $_selectedAdjustment to $value');

    // Update local adjustments immediately
    ImageAdjustmentProcessor.setValueInAdjustments(
      _localAdjustments,
      _selectedAdjustment,
      value,
    );

    // Also update the main adjustments
    final newAdjustments = widget.adjustments.copy();
    ImageAdjustmentProcessor.setValueInAdjustments(
      newAdjustments,
      _selectedAdjustment,
      value,
    );

    print(
      'New value: ${ImageAdjustmentProcessor.getValueFromAdjustments(newAdjustments, _selectedAdjustment)}',
    );

    // Call parent callback
    widget.onAdjustmentsChanged(newAdjustments);
    HapticFeedback.lightImpact();

    // Force rebuild with local state
    setState(() {});
  }

  double _getCurrentValue() {
    return ImageAdjustmentProcessor.getValueFromAdjustments(
      _localAdjustments,
      _selectedAdjustment,
    );
  }

  AdjustmentOption _getCurrentOption() {
    return ImageAdjustmentProcessor.getOptionByName(_selectedAdjustment);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - widget.animation.value) * 350),
          child: Opacity(
            opacity: widget.animation.value,
            child: Container(
              height: 350,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.95),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header with current adjustment name and value
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedAdjustment.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        if (widget.adjustments.hasAnyAdjustments)
                          GestureDetector(
                            onTap: () {
                              widget.adjustments.reset();
                              widget.onAdjustmentsChanged(widget.adjustments);
                              widget.onReset?.call();
                              HapticFeedback.lightImpact();
                              setState(() {}); // Force rebuild after reset
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Reset',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Replace your current Text widget with:
                  StatefulBuilder(
                    builder: (context, setLocalState) {
                      return Text(
                        ImageAdjustmentProcessor.getDisplayValue(
                          _selectedAdjustment,
                          _getCurrentValue(),
                        ),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 32,
                          fontWeight: FontWeight.w300,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // iOS 18.5 style horizontal slider
                  Expanded(child: _buildHorizontalSlider()),

                  const SizedBox(height: 24),

                  // Adjustment options list
                  // Adjustment options list
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount:
                          ImageAdjustmentProcessor.adjustmentOptions.length,
                      itemBuilder: (context, index) {
                        final option =
                            ImageAdjustmentProcessor.adjustmentOptions[index];
                        final isSelected = option.name == _selectedAdjustment;

                        final currentValue =
                            ImageAdjustmentProcessor.getValueFromAdjustments(
                              _localAdjustments,
                              option.name,
                            );

                        final hasAdjustment =
                            !ImageAdjustmentProcessor.isAtDefault(
                              option.name,
                              currentValue,
                            );

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedAdjustment = option.name;
                            });
                            HapticFeedback.selectionClick();
                          },
                          child: Container(
                            width: 60,
                            margin: const EdgeInsets.only(right: 16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected
                                            ? Colors.blueAccent.withOpacity(0.7)
                                            : hasAdjustment
                                            ? Colors.yellow.withOpacity(0.3)
                                            : Colors.white.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                    border:
                                        hasAdjustment && !isSelected
                                            ? Border.all(
                                              color: Colors.yellow,
                                              width: 1.5,
                                            )
                                            : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      option.icon,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color:
                                            isSelected
                                                ? Colors.white.withOpacity(0.7)
                                                : Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  option.name,
                                  style: TextStyle(
                                    color:
                                        isSelected
                                            ? Colors.blueAccent.withOpacity(0.7)
                                            : hasAdjustment
                                            ? Colors.white
                                            : Colors.white.withOpacity(0.6),
                                    fontSize: 10,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHorizontalSlider() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final sliderWidth = constraints.maxWidth;
          final option = _getCurrentOption();
          final currentValue = _getCurrentValue();
          final normalizedValue =
              (currentValue - option.min) / (option.max - option.min);

          return SizedBox(
            height: 60,
            width: sliderWidth,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart:
                  (details) => _handleSliderInteraction(
                    details.localPosition,
                    sliderWidth,
                  ),
              onPanUpdate:
                  (details) => _handleSliderInteraction(
                    details.localPosition,
                    sliderWidth,
                  ),
              onTapDown:
                  (details) => _handleSliderInteraction(
                    details.localPosition,
                    sliderWidth,
                  ),
              child: CustomPaint(
                painter: HorizontalSliderPainter(
                  value: normalizedValue.clamp(0.0, 1.0),
                  option: option,
                ),
                size: Size(sliderWidth, 60),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleSliderInteraction(Offset localPosition, double sliderWidth) {
    // Calculate normalized position (0.0 to 1.0)
    final normalizedPosition = (localPosition.dx / sliderWidth).clamp(0.0, 1.0);

    // Convert to actual adjustment value
    final option = _getCurrentOption();
    final newValue =
        option.min + (normalizedPosition * (option.max - option.min));

    _onAdjustmentChanged(newValue);
    setState(() {});
  }
}

class HorizontalSliderPainter extends CustomPainter {
  final double value;
  final AdjustmentOption option;

  HorizontalSliderPainter({required this.value, required this.option});

  @override
  void paint(Canvas canvas, Size size) {
    final sliderY = size.height / 2;
    final sliderWidth = size.width;
    final sliderHeight = 3.0; // Slightly thinner track like iOS

    // Draw tick marks first (behind everything)
    _drawTickMarks(canvas, size, sliderY);

    // Draw the slider track
    _drawSliderTrack(canvas, sliderY, sliderWidth, sliderHeight);

    // Draw the active track
    _drawActiveTrack(canvas, sliderY, sliderWidth, sliderHeight);

    // Draw center indicator
    _drawCenterIndicator(canvas, sliderY, sliderWidth);

    // Draw the thumb last (on top)
    _drawThumb(canvas, sliderY, sliderWidth);
  }

  void _drawTickMarks(Canvas canvas, Size size, double y) {
    // More tick marks for finer granularity like iOS
    const majorTickCount = 41; // More major ticks
    const minorTickCount = 4; // Minor ticks between major ticks

    // Draw major ticks with iOS-style heights
    for (int i = 0; i < majorTickCount; i++) {
      final x = (size.width * i / (majorTickCount - 1));
      final isCenter = i == (majorTickCount - 1) / 2;
      final normalizedPosition = i / (majorTickCount - 1);

      // Create varying heights - taller near center, shorter at edges
      double tickHeight;
      if (isCenter) {
        tickHeight = 28.0; // Very tall center tick
      } else {
        // Calculate distance from center for gradual height variation
        final distanceFromCenter = (normalizedPosition - 0.5).abs();
        tickHeight = 20.0 - (distanceFromCenter * 8.0); // 20px down to 12px
        tickHeight = tickHeight.clamp(12.0, 20.0);
      }

      // Create paint with appropriate styling
      final paint =
          Paint()
            ..strokeWidth = isCenter ? 1.5 : 1.0
            ..strokeCap = StrokeCap.round;

      // Color based on position relative to thumb
      final thumbX = size.width * value;
      final distanceFromThumb = (x - thumbX).abs();

      if (isCenter) {
        paint.color = Colors.white.withOpacity(0.8);
      } else if (distanceFromThumb < 30) {
        // Ticks near thumb are more visible
        paint.color = Colors.white.withOpacity(0.6);
      } else {
        // Distant ticks are more subtle
        paint.color = Colors.white.withOpacity(0.25);
      }

      canvas.drawLine(
        Offset(x, y - tickHeight / 2),
        Offset(x, y + tickHeight / 2),
        paint,
      );
    }

    // Draw fine minor ticks between major ones
    final minorPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.15)
          ..strokeWidth = 0.5
          ..strokeCap = StrokeCap.round;

    for (int i = 0; i < majorTickCount - 1; i++) {
      final startX = size.width * i / (majorTickCount - 1);
      final endX = size.width * (i + 1) / (majorTickCount - 1);
      final spacing = (endX - startX) / minorTickCount;

      for (int j = 1; j < minorTickCount; j++) {
        final x = startX + (spacing * j);
        final normalizedPosition = x / size.width;
        final distanceFromCenter = (normalizedPosition - 0.5).abs();
        final minorTickHeight = 8.0 - (distanceFromCenter * 2.0);

        canvas.drawLine(
          Offset(x, y - minorTickHeight / 2),
          Offset(x, y + minorTickHeight / 2),
          minorPaint,
        );
      }
    }
  }

  void _drawSliderTrack(Canvas canvas, double y, double width, double height) {
    final trackPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.08)
          ..style = PaintingStyle.fill;

    final trackRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, y - height / 2, width, height),
      Radius.circular(height / 2),
    );

    canvas.drawRRect(trackRect, trackPaint);
  }

  void _drawActiveTrack(Canvas canvas, double y, double width, double height) {
    final centerX = width / 2;
    final thumbX = width * value;

    // Don't draw if very close to center
    if ((value - 0.5).abs() < 0.005) return;

    final activePaint =
        Paint()
          ..color = Colors.yellow
          ..style = PaintingStyle.fill;

    late Rect activeRect;

    if (value > 0.5) {
      // Right side of center
      activeRect = Rect.fromLTWH(
        centerX,
        y - height / 2,
        thumbX - centerX,
        height,
      );
    } else {
      // Left side of center
      activeRect = Rect.fromLTWH(
        thumbX,
        y - height / 2,
        centerX - thumbX,
        height,
      );
    }

    final activeTrack = RRect.fromRectAndRadius(
      activeRect,
      Radius.circular(height / 2),
    );

    canvas.drawRRect(activeTrack, activePaint);
  }

  void _drawThumb(Canvas canvas, double y, double width) {
    final thumbX = width * value;
    final thumbPosition = Offset(thumbX, y);

    // Draw shadow/outer ring with more iOS-like styling
    final shadowPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.25)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
    canvas.drawCircle(thumbPosition.translate(0, 0.5), 13, shadowPaint);

    // Main thumb with iOS-style border
    final borderPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5;
    canvas.drawCircle(thumbPosition, 12, borderPaint);

    final thumbPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
    canvas.drawCircle(thumbPosition, 12, thumbPaint);

    // Inner highlight with more subtle iOS styling
    final highlightPaint =
        Paint()
          ..color = Colors.yellow.withOpacity(0.9)
          ..style = PaintingStyle.fill;
    canvas.drawCircle(thumbPosition, 7, highlightPaint);

    // Very subtle inner shadow for depth
    final innerShadowPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.05)
          ..style = PaintingStyle.fill;
    canvas.drawCircle(thumbPosition.translate(0, -0.5), 5, innerShadowPaint);
  }

  void _drawCenterIndicator(Canvas canvas, double y, double width) {
    final centerX = width / 2;

    // More prominent center indicator like iOS
    final centerLinePaint =
        Paint()
          ..color = Colors.white.withOpacity(0.4)
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round;

    // Vertical center line extending beyond the tick marks
    canvas.drawLine(
      Offset(centerX, y - 32),
      Offset(centerX, y + 32),
      centerLinePaint,
    );

    // Center dot
    final centerDotPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.6)
          ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, y), 2.5, centerDotPaint);

    // Subtle center highlight
    final centerHighlightPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.8)
          ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, y), 1, centerHighlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is HorizontalSliderPainter) {
      return value != oldDelegate.value || option != oldDelegate.option;
    }
    return true;
  }
}

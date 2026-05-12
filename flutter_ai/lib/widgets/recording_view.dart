import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RecordingView extends StatefulWidget {
  final bool isRecording;
  final VoidCallback onStartRecording;
  final VoidCallback onFinishRecording;

  const RecordingView({
    super.key,
    required this.isRecording,
    required this.onStartRecording,
    required this.onFinishRecording,
  });

  @override
  State<RecordingView> createState() => _RecordingViewState();
}

class _RecordingViewState extends State<RecordingView>
    with TickerProviderStateMixin {
  // Ripple waves
  late AnimationController _ripple1Controller;
  late AnimationController _ripple2Controller;
  late AnimationController _ripple3Controller;

  // Button pulse
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Entrance animation
  late AnimationController _entranceController;
  late Animation<double> _entranceFade;
  late Animation<Offset> _entranceSlide;

  @override
  void initState() {
    super.initState();

    // Entrance
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _entranceFade = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _entranceSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    ));
    _entranceController.forward();

    // Ripple waves with staggered delays
    _ripple1Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _ripple2Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _ripple3Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(RecordingView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !oldWidget.isRecording) {
      _startRipples();
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _stopRipples();
    }
  }

  void _startRipples() {
    _ripple1Controller.repeat();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _ripple2Controller.repeat();
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _ripple3Controller.repeat();
    });
    _pulseController.repeat(reverse: true);
  }

  void _stopRipples() {
    _ripple1Controller.stop();
    _ripple2Controller.stop();
    _ripple3Controller.stop();
    _pulseController.stop();
    _pulseController.animateTo(0);
  }

  @override
  void dispose() {
    _ripple1Controller.dispose();
    _ripple2Controller.dispose();
    _ripple3Controller.dispose();
    _pulseController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _entranceFade,
      child: SlideTransition(
        position: _entranceSlide,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Penyu mascot illustration (SVG-style custom paint)
            _PenyuIllustration(isRecording: widget.isRecording),
            const SizedBox(height: 48),

            // Greeting text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                child: Text(
                  widget.isRecording
                      ? 'Penyu sedang mendengarkan...'
                      : 'Hei, Penyu siap mendengarkan.',
                  key: ValueKey(widget.isRecording),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.textPrimary,
                        fontStyle: FontStyle.italic,
                        fontSize: 22,
                        height: 1.4,
                      ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              widget.isRecording
                  ? 'Ceritakan apapun yang kamu rasakan hari ini'
                  : 'Tekan tombol untuk mulai merekam',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    letterSpacing: 0.3,
                  ),
            ),

            const SizedBox(height: 72),

            // Recording button with ripples
            _RecordButton(
              isRecording: widget.isRecording,
              ripple1: _ripple1Controller,
              ripple2: _ripple2Controller,
              ripple3: _ripple3Controller,
              pulse: _pulseAnimation,
              onTap: () {
                if (!widget.isRecording) {
                  widget.onStartRecording();
                }
              },
            ),

            const SizedBox(height: 40),

            // Done button - only shown when recording
            AnimatedOpacity(
              opacity: widget.isRecording ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              child: AnimatedSlide(
                offset: widget.isRecording
                    ? Offset.zero
                    : const Offset(0, 0.3),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                child: GestureDetector(
                  onTap: widget.isRecording ? widget.onFinishRecording : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 36,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: AppTheme.primaryTeal.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_rounded,
                          color: AppTheme.primaryTeal,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Selesai Merekam',
                          style: TextStyle(
                            color: AppTheme.primaryTeal,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordButton extends StatelessWidget {
  final bool isRecording;
  final AnimationController ripple1;
  final AnimationController ripple2;
  final AnimationController ripple3;
  final Animation<double> pulse;
  final VoidCallback onTap;

  const _RecordButton({
    required this.isRecording,
    required this.ripple1,
    required this.ripple2,
    required this.ripple3,
    required this.pulse,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 200,
        height: 200,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ripple waves
            _RippleWave(controller: ripple1, maxScale: 2.2),
            _RippleWave(controller: ripple2, maxScale: 1.8),
            _RippleWave(controller: ripple3, maxScale: 1.4),

            // Main button
            ScaleTransition(
              scale: pulse,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isRecording
                      ? const Color(0xFFD4564A)
                      : AppTheme.primaryTeal,
                  boxShadow: [
                    BoxShadow(
                      color: (isRecording
                              ? const Color(0xFFD4564A)
                              : AppTheme.primaryTeal)
                          .withOpacity(0.35),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Icon(
                    isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                    key: ValueKey(isRecording),
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RippleWave extends StatelessWidget {
  final AnimationController controller;
  final double maxScale;

  const _RippleWave({
    required this.controller,
    required this.maxScale,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final value = Curves.easeOut.transform(controller.value);
        return Transform.scale(
          scale: 1.0 + (maxScale - 1.0) * value,
          child: Opacity(
            opacity: (1.0 - value).clamp(0.0, 1.0),
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primaryTeal.withOpacity(0.6),
                  width: 1.5,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Custom penyu (turtle) illustration using CustomPainter
class _PenyuIllustration extends StatefulWidget {
  final bool isRecording;

  const _PenyuIllustration({required this.isRecording});

  @override
  State<_PenyuIllustration> createState() => _PenyuIllustrationState();
}

class _PenyuIllustrationState extends State<_PenyuIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: SizedBox(
            width: 120,
            height: 90,
            child: CustomPaint(
              painter: _TurtlePainter(
                color: AppTheme.primaryTeal,
                isRecording: widget.isRecording,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TurtlePainter extends CustomPainter {
  final Color color;
  final bool isRecording;

  _TurtlePainter({required this.color, required this.isRecording});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Shell
    paint.color = color;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: 70, height: 52),
      paint,
    );

    // Shell pattern
    paint.color = Colors.white.withOpacity(0.15);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - 2), width: 42, height: 30),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 16, cy + 4), width: 20, height: 16),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 16, cy + 4), width: 20, height: 16),
      paint,
    );

    // Head
    paint.color = color.withOpacity(0.85);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx + 40, cy - 4), width: 24, height: 20),
      paint,
    );

    // Eye
    paint.color = Colors.white;
    canvas.drawCircle(Offset(cx + 47, cy - 6), 3.5, paint);
    paint.color = AppTheme.textPrimary;
    canvas.drawCircle(Offset(cx + 48, cy - 6), 2, paint);

    // Flippers
    paint.color = color.withOpacity(0.7);

    // Front-left flipper
    final path1 = Path()
      ..moveTo(cx - 10, cy - 10)
      ..quadraticBezierTo(cx - 32, cy - 28, cx - 38, cy - 18)
      ..quadraticBezierTo(cx - 28, cy - 8, cx - 10, cy - 4);
    canvas.drawPath(path1, paint);

    // Front-right flipper
    final path2 = Path()
      ..moveTo(cx - 10, cy + 10)
      ..quadraticBezierTo(cx - 32, cy + 28, cx - 38, cy + 18)
      ..quadraticBezierTo(cx - 28, cy + 8, cx - 10, cy + 4);
    canvas.drawPath(path2, paint);

    // Tail
    paint.color = color.withOpacity(0.6);
    final tailPath = Path()
      ..moveTo(cx + 32, cy + 2)
      ..quadraticBezierTo(cx + 52, cy + 12, cx + 48, cy + 18)
      ..quadraticBezierTo(cx + 38, cy + 10, cx + 32, cy + 6);
    canvas.drawPath(tailPath, paint);
  }

  @override
  bool shouldRepaint(_TurtlePainter old) =>
      old.color != color || old.isRecording != isRecording;
}
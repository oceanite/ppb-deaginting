import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LoadingView extends StatefulWidget {
  const LoadingView({super.key});

  @override
  State<LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView>
    with TickerProviderStateMixin {
  // Breathing animation (main)
  late AnimationController _breathController;
  late Animation<double> _breathScale;
  late Animation<double> _breathOpacity;

  // Text fade animation
  late AnimationController _textController;
  late Animation<double> _textFade;

  // Entrance animation
  late AnimationController _entranceController;
  late Animation<double> _entranceFade;

  // Dot animation for loading text
  late AnimationController _dotController;

  final List<String> _messages = [
    'Penyu sedang merangkai ceritamu...',
    'Memetakan perasaanmu dengan sabar...',
    'Hampir selesai, tarik napas dulu...',
  ];
  int _messageIndex = 0;

  @override
  void initState() {
    super.initState();

    // Entrance
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _entranceFade = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _entranceController.forward();

    // Breathing - slow and calming (1800ms per breath)
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _breathScale = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    _breathOpacity = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    // Text cycling
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textFade = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    );
    _textController.forward();

    // Cycle messages
    Future.delayed(const Duration(milliseconds: 1200), _cycleMessage);

    // Dot animation
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  void _cycleMessage() {
    if (!mounted) return;
    _textController.reverse().then((_) {
      if (!mounted) return;
      setState(() {
        _messageIndex = (_messageIndex + 1) % _messages.length;
      });
      _textController.forward();
      Future.delayed(const Duration(milliseconds: 1100), _cycleMessage);
    });
  }

  @override
  void dispose() {
    _breathController.dispose();
    _textController.dispose();
    _entranceController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _entranceFade,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Breathing orb with turtle inside
            AnimatedBuilder(
              animation: Listenable.merge(
                  [_breathController, _breathScale, _breathOpacity]),
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer glow ring
                    Transform.scale(
                      scale: _breathScale.value * 1.3,
                      child: Opacity(
                        opacity: _breathOpacity.value * 0.15,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryTeal,
                          ),
                        ),
                      ),
                    ),
                    // Middle ring
                    Transform.scale(
                      scale: _breathScale.value * 1.15,
                      child: Opacity(
                        opacity: _breathOpacity.value * 0.25,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryTeal,
                          ),
                        ),
                      ),
                    ),
                    // Core circle
                    Transform.scale(
                      scale: _breathScale.value,
                      child: Opacity(
                        opacity: _breathOpacity.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppTheme.primaryTeal.withOpacity(0.9),
                                AppTheme.primaryTeal,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryTeal.withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: _BreathingTurtle(),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 64),

            // "Breathing guide" label
            AnimatedBuilder(
              animation: _breathController,
              builder: (context, _) {
                final isInhale = _breathController.value < 0.5;
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    isInhale ? 'Tarik napas...' : 'Hembuskan...',
                    key: ValueKey(isInhale),
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 2.5,
                      color: AppTheme.textSecondary.withOpacity(0.6),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Cycling message
            FadeTransition(
              opacity: _textFade,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Text(
                  _messages[_messageIndex],
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppTheme.textPrimary.withOpacity(0.75),
                        fontSize: 17,
                      ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Animated dots
            _AnimatedDots(controller: _dotController),
          ],
        ),
      ),
    );
  }
}

class _BreathingTurtle extends StatelessWidget {
  const _BreathingTurtle();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 42,
      child: CustomPaint(painter: _SmallTurtlePainter()),
    );
  }
}

class _SmallTurtlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Shell
    paint.color = Colors.white.withOpacity(0.9);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: 36, height: 26),
      paint,
    );

    // Shell pattern
    paint.color = AppTheme.primaryTeal.withOpacity(0.3);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - 1), width: 22, height: 14),
      paint,
    );

    // Head
    paint.color = Colors.white.withOpacity(0.85);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 20, cy - 2), width: 12, height: 10),
      paint,
    );

    // Flippers
    paint.color = Colors.white.withOpacity(0.6);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 5, cy - 14), width: 12, height: 7),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 5, cy + 14), width: 12, height: 7),
      paint,
    );
  }

  @override
  bool shouldRepaint(_SmallTurtlePainter old) => false;
}

class _AnimatedDots extends StatelessWidget {
  final AnimationController controller;

  const _AnimatedDots({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3;
            final value = ((controller.value - delay) % 1.0).clamp(0.0, 1.0);
            final opacity =
                (math_sin(value * 3.14159).clamp(0.0, 1.0) * 0.8) + 0.2;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryTeal.withOpacity(opacity),
              ),
            );
          }),
        );
      },
    );
  }
}

double math_sin(double x) {
  // Simple sine approximation for dots
  return (x < 3.14159) ? (4 * x * (3.14159 - x)) / (3.14159 * 3.14159) : 0.0;
}
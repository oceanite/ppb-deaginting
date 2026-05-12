import 'package:flutter/material.dart';
import '../models/empathy_map_data.dart';
import '../theme/app_theme.dart';

class ResultView extends StatefulWidget {
  final EmpathyMapData data;
  final VoidCallback onReset;

  const ResultView({
    super.key,
    required this.data,
    required this.onReset,
  });

  @override
  State<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView>
    with TickerProviderStateMixin {
  // Header entrance
  late AnimationController _headerController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  // Staggered card controllers
  final List<AnimationController> _cardControllers = [];
  final List<Animation<double>> _cardFades = [];
  final List<Animation<Offset>> _cardSlides = [];

  // Reset button
  late AnimationController _resetController;
  late Animation<double> _resetFade;

  static const int _cardCount = 4;
  static const Duration _cardStaggerDelay = Duration(milliseconds: 150);
  static const Duration _cardAnimDuration = Duration(milliseconds: 800);

  @override
  void initState() {
    super.initState();

    // Header
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _headerFade = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    ));

    // Cards with stagger
    for (int i = 0; i < _cardCount; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: _cardAnimDuration,
      );
      final fade = CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      );
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.25),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
      ));
      _cardControllers.add(controller);
      _cardFades.add(fade);
      _cardSlides.add(slide);
    }

    // Reset button
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _resetFade = CurvedAnimation(
      parent: _resetController,
      curve: Curves.easeOut,
    );

    _startAnimations();
  }

  void _startAnimations() async {
    // Header first
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _headerController.forward();

    // Then cards, staggered
    for (int i = 0; i < _cardCount; i++) {
      await Future.delayed(
        Duration(milliseconds: 300 + (i * _cardStaggerDelay.inMilliseconds)),
      );
      if (!mounted) return;
      _cardControllers[i].forward();
    }

    // Finally reset button
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _resetController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    for (final c in _cardControllers) {
      c.dispose();
    }
    _resetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final empathyMap = widget.data.empathyMap;

    final cardData = [
      _CardData(
        title: 'Perasaan',
        titleEn: 'FEELINGS',
        icon: Icons.favorite_outline_rounded,
        items: empathyMap.feelings,
        accentColor: AppTheme.feelingsColor,
        iconColor: const Color(0xFFC0604A),
      ),
      _CardData(
        title: 'Pikiran',
        titleEn: 'THOUGHTS',
        icon: Icons.lightbulb_outline_rounded,
        items: empathyMap.thoughts,
        accentColor: AppTheme.thoughtsColor,
        iconColor: const Color(0xFF4A8A5C),
      ),
      _CardData(
        title: 'Titik Berat',
        titleEn: 'PAIN POINTS',
        icon: Icons.bolt_outlined,
        items: empathyMap.painPoints,
        accentColor: AppTheme.painColor,
        iconColor: const Color(0xFF8A4A4A),
      ),
      _CardData(
        title: 'Tindakan',
        titleEn: 'ACTIONS',
        icon: Icons.directions_walk_rounded,
        items: empathyMap.actions,
        accentColor: AppTheme.actionsColor,
        iconColor: const Color(0xFF4A4A8A),
      ),
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            SlideTransition(
              position: _headerSlide,
              child: FadeTransition(
                opacity: _headerFade,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                      child: Text(
                        _getFormattedDate(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Sub label
                    Text(
                      'EMOSI DOMINAN',
                      style:
                          Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.white.withOpacity(0.7),
                                letterSpacing: 2.5,
                              ),
                    ),

                    const SizedBox(height: 8),

                    // Dominant emotion - large typography
                    Text(
                      widget.data.dominantEmotion,
                      style:
                          Theme.of(context).textTheme.displayLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w300,
                                fontSize: 36,
                                height: 1.2,
                              ),
                    ),

                    const SizedBox(height: 12),

                    // Divider
                    Container(
                      width: 48,
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Ini adalah peta empati dari refleksi suaramu hari ini.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.7),
                            fontStyle: FontStyle.italic,
                          ),
                    ),

                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),

            // ── Staggered Cards ──
            ...List.generate(_cardCount, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SlideTransition(
                  position: _cardSlides[i],
                  child: FadeTransition(
                    opacity: _cardFades[i],
                    child: _EmpathyCard(data: cardData[i]),
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),

            // ── Reset Button ──
            FadeTransition(
              opacity: _resetFade,
              child: Center(
                child: GestureDetector(
                  onTap: widget.onReset,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.mic_none_rounded,
                          color: Colors.white.withOpacity(0.9),
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Rekam Lagi',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
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

  String _getFormattedDate() {
    final now = DateTime.now();
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    const days = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
    ];
    final day = days[now.weekday - 1];
    return '$day, ${now.day} ${months[now.month - 1]} ${now.year}';
  }
}

class _CardData {
  final String title;
  final String titleEn;
  final IconData icon;
  final List<String> items;
  final Color accentColor;
  final Color iconColor;

  const _CardData({
    required this.title,
    required this.titleEn,
    required this.icon,
    required this.items,
    required this.accentColor,
    required this.iconColor,
  });
}

class _EmpathyCard extends StatelessWidget {
  final _CardData data;

  const _EmpathyCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Colored left accent bar
              Container(
                width: 4,
                color: data.iconColor.withOpacity(0.7),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: data.accentColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              data.icon,
                              color: data.iconColor,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                  fontFamily: 'Georgia',
                                  height: 1.2,
                                ),
                              ),
                              Text(
                                data.titleEn,
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.8,
                                  color: AppTheme.textSecondary,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Items list
                      ...data.items.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Container(
                                    width: 5,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: data.iconColor.withOpacity(0.6),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: const TextStyle(
                                      fontSize: 14.5,
                                      color: AppTheme.textPrimary,
                                      height: 1.55,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
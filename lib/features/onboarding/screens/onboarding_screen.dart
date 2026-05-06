import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router.dart';
import '../../../app/theme.dart';

class _Slide {
  final String tag;
  final String title;
  final String body;

  const _Slide({required this.tag, required this.title, required this.body});
}

const _slides = <_Slide>[
  _Slide(
    tag: '01',
    title: 'Learn by building',
    body: 'Each course ends with a project you actually ship.',
  ),
  _Slide(
    tag: '02',
    title: 'Get unstuck fast',
    body: 'Ask doubts inline; moderators respond within hours.',
  ),
  _Slide(
    tag: '03',
    title: 'Climb the ranks',
    body: 'Course, school, and cohort leaderboards update live.',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _index = 0;

  void _next() {
    if (_index < _slides.length - 1) {
      setState(() => _index++);
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final slide = _slides[_index];
    final isLast = _index == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppPalette.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 50, 28, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                slide.tag,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppPalette.textSoft,
                  letterSpacing: 1.2,
                  fontFamily: theme.textTheme.bodyMedium?.fontFamily,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                slide.title,
                style: theme.textTheme.displayMedium?.copyWith(
                  fontSize: 36,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                slide.body,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppPalette.textSoft,
                  height: 1.5,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              _HeroBlock(stepNumber: _index + 1),
              const Spacer(),
              Row(
                children: [
                  _Dots(current: _index, total: _slides.length),
                  const Spacer(),
                  FilledButton(
                    onPressed: _next,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(108, 48),
                    ),
                    child: Text(isLast ? 'Enter' : 'Next'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroBlock extends StatelessWidget {
  final int stepNumber;

  const _HeroBlock({required this.stepNumber});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: AppPalette.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.6, -0.4),
                  radius: 0.7,
                  colors: [
                    Colors.white.withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                  stops: const [0, 1],
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Text(
              'step.$stepNumber → loaded',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 11,
                fontFeatures: const [FontFeature.tabularFigures()],
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int current;
  final int total;

  const _Dots({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final selected = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          margin: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
          width: selected ? 22 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: selected ? AppPalette.primary : AppPalette.border,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

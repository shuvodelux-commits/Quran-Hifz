import 'dart:math' as math;

import 'package:flutter/material.dart';

class AppOpeningSplash extends StatefulWidget {
  const AppOpeningSplash({super.key, required this.child});

  final Widget child;

  @override
  State<AppOpeningSplash> createState() => _AppOpeningSplashState();
}

class _AppOpeningSplashState extends State<AppOpeningSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _reveal;
  late final Animation<double> _opacity;
  late final Animation<double> _glowOpacity;
  late final Animation<double> _glowScale;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1800),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed && mounted) {
            setState(() => _finished = true);
          }
        });
    _reveal = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.82, curve: Curves.easeInOutCubic),
    );
    _opacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.84, 1, curve: Curves.easeOut),
      ),
    );
    _glowOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.04,
          end: 0.9,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 68,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.9,
          end: 0.42,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 32,
      ),
    ]).animate(_controller);
    _glowScale = Tween<double>(
      begin: 0.72,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (!_finished)
          FadeTransition(
            opacity: _opacity,
            child: ColoredBox(
              key: const ValueKey('app-opening-splash'),
              color: Colors.white,
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = math.min(constraints.maxWidth * 0.76, 320.0);
                    final height = width * 350 / 335;
                    return SizedBox(
                      width: width,
                      height: height,
                      child: AnimatedBuilder(
                        animation: _reveal,
                        builder: (context, _) => Stack(
                          alignment: Alignment.center,
                          children: [
                            FadeTransition(
                              key: const ValueKey('opening-noor-glow'),
                              opacity: _glowOpacity,
                              child: ScaleTransition(
                                scale: _glowScale,
                                child: Container(
                                  width: width * 0.96,
                                  height: height * 0.9,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        Theme.of(context).colorScheme.primary
                                            .withValues(alpha: 0.3),
                                        Theme.of(context).colorScheme.primary
                                            .withValues(alpha: 0.12),
                                        Colors.white.withValues(alpha: 0),
                                      ],
                                      stops: const [0, 0.46, 1],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Center(child: _logo(Colors.white)),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: SizedBox(
                                key: const ValueKey('opening-logo-color-fill'),
                                width: width,
                                height: height * _reveal.value,
                                child: ClipRect(
                                  child: OverflowBox(
                                    alignment: Alignment.bottomCenter,
                                    minWidth: width,
                                    maxWidth: width,
                                    minHeight: height,
                                    maxHeight: height,
                                    child: _logo(
                                      Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _logo(Color color) => ColorFiltered(
    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    child: Image.asset(
      'assets/images/quran_opening_logo.png',
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    ),
  );
}

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tap_tap_game/app_theme.dart';
import 'package:tap_tap_game/routes/app_routes.dart';
import 'package:tap_tap_game/screens/two_player_game_over_screen.dart';
import 'package:tap_tap_game/services/sound_service.dart';

class TwoPlayerGameScreen extends StatefulWidget {
  const TwoPlayerGameScreen({super.key});

  static const int gameDurationSeconds = 30;

  @override
  State<TwoPlayerGameScreen> createState() => _TwoPlayerGameScreenState();
}

enum _GamePhase { countdown, playing, ended }

class _TwoPlayerGameScreenState extends State<TwoPlayerGameScreen>
    with TickerProviderStateMixin {
  final SoundService _soundService = SoundService();

  int _score1 = 0;
  int _score2 = 0;
  int _timeLeft = TwoPlayerGameScreen.gameDurationSeconds;
  int _countdown = 3;
  _GamePhase _phase = _GamePhase.countdown;

  Timer? _gameTimer;
  Timer? _countdownTimer;

  late AnimationController _ripple1Controller;
  late AnimationController _ripple2Controller;
  late AnimationController _countdownController;
  late AnimationController _timerPulseController;

  @override
  void initState() {
    super.initState();
    _ripple1Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _ripple2Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _countdownController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _timerPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _startCountdown();
  }

  void _startCountdown() {
    _countdownController.forward(from: 0);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown <= 1) {
        timer.cancel();
        setState(() => _phase = _GamePhase.playing);
        _startGame();
      } else {
        setState(() => _countdown--);
        _countdownController.forward(from: 0);
      }
    });
  }

  void _startGame() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft <= 1) {
        timer.cancel();
        _endGame();
      } else {
        setState(() => _timeLeft--);
        if (_timeLeft <= 10) {
          _timerPulseController.forward(from: 0);
        }
      }
    });
  }

  void _onTapPlayer1() {
    if (_phase != _GamePhase.playing) return;
    HapticFeedback.lightImpact();
    _soundService.playTap();
    _ripple1Controller.forward(from: 0);
    setState(() => _score1++);
  }

  void _onTapPlayer2() {
    if (_phase != _GamePhase.playing) return;
    HapticFeedback.lightImpact();
    _soundService.playTap();
    _ripple2Controller.forward(from: 0);
    setState(() => _score2++);
  }

  void _endGame() {
    if (_phase == _GamePhase.ended) return;
    setState(() => _phase = _GamePhase.ended);
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        FadeSlideRoute(
          page: TwoPlayerGameOverScreen(score1: _score1, score2: _score2),
        ),
      );
    });
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _countdownTimer?.cancel();
    _ripple1Controller.dispose();
    _ripple2Controller.dispose();
    _countdownController.dispose();
    _timerPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: RotatedBox(
                  quarterTurns: 2,
                  child: _PlayerTapArea(
                    playerNumber: 2,
                    score: _score2,
                    onTap: _onTapPlayer2,
                    rippleController: _ripple2Controller,
                    enabled: _phase == _GamePhase.playing,
                    gradientColors: const [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                    glowColor: const Color(0xFF8B5CF6),
                    isLeading: _score2 > _score1,
                  ),
                ),
              ),
              _CenterBar(
                timeLeft: _timeLeft,
                score1: _score1,
                score2: _score2,
                phase: _phase,
                pulseController: _timerPulseController,
              ),
              Expanded(
                child: _PlayerTapArea(
                  playerNumber: 1,
                  score: _score1,
                  onTap: _onTapPlayer1,
                  rippleController: _ripple1Controller,
                  enabled: _phase == _GamePhase.playing,
                  gradientColors: const [Color(0xFF2563EB), Color(0xFF06B6D4)],
                  glowColor: const Color(0xFF2563EB),
                  isLeading: _score1 > _score2,
                ),
              ),
            ],
          ),
          if (_phase == _GamePhase.countdown)
            _CountdownOverlay(
              countdown: _countdown,
              controller: _countdownController,
            ),
        ],
      ),
    );
  }
}

class _PlayerTapArea extends StatelessWidget {
  const _PlayerTapArea({
    required this.playerNumber,
    required this.score,
    required this.onTap,
    required this.rippleController,
    required this.enabled,
    required this.gradientColors,
    required this.glowColor,
    required this.isLeading,
  });

  final int playerNumber;
  final int score;
  final VoidCallback onTap;
  final AnimationController rippleController;
  final bool enabled;
  final List<Color> gradientColors;
  final Color glowColor;
  final bool isLeading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onTap(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              gradientColors[0].withValues(alpha: 0.14),
              gradientColors[1].withValues(alpha: 0.05),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: AnimatedBuilder(
          animation: rippleController,
          builder: (context, child) {
            final rippleOpacity = Tween<double>(begin: 0.3, end: 0.0).evaluate(
              CurvedAnimation(parent: rippleController, curve: Curves.easeOut),
            );
            final rippleScale = Tween<double>(begin: 0.2, end: 2.2).evaluate(
              CurvedAnimation(parent: rippleController, curve: Curves.easeOut),
            );
            return Stack(
              alignment: Alignment.center,
              children: [
                Transform.scale(
                  scale: rippleScale,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: gradientColors[0].withValues(alpha: rippleOpacity),
                    ),
                  ),
                ),
                child!,
              ],
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLeading) ...[
                    Icon(
                      Icons.arrow_drop_up_rounded,
                      color: gradientColors[0],
                      size: 22,
                    ),
                    const SizedBox(width: 2),
                  ],
                  Text(
                    'PLAYER $playerNumber',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3,
                      color: gradientColors[0].withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: gradientColors,
                ).createShader(bounds),
                child: Text(
                  '$score',
                  style: const TextStyle(
                    fontSize: 76,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  gradient: LinearGradient(
                    colors: enabled
                        ? gradientColors
                        : [
                            gradientColors[0].withValues(alpha: 0.3),
                            gradientColors[1].withValues(alpha: 0.3),
                          ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: glowColor.withValues(alpha: enabled ? 0.45 : 0.1),
                      blurRadius: enabled ? 22 : 8,
                      spreadRadius: enabled ? 2 : 0,
                    ),
                  ],
                ),
                child: Text(
                  enabled ? 'TAP!' : (score == 0 ? 'GET READY' : 'DONE'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
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

class _CenterBar extends StatelessWidget {
  const _CenterBar({
    required this.timeLeft,
    required this.score1,
    required this.score2,
    required this.phase,
    required this.pulseController,
  });

  final int timeLeft;
  final int score1;
  final int score2;
  final _GamePhase phase;
  final AnimationController pulseController;

  @override
  Widget build(BuildContext context) {
    final isLow = timeLeft <= 10 && phase == _GamePhase.playing;
    final total = score1 + score2;
    final s2Flex = max(score2, 1);
    final s1Flex = max(score1, 1);

    return Container(
      height: 68,
      color: AppTheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // P2 score
          SizedBox(
            width: 38,
            child: Text(
              '$score2',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B5CF6),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Battle bar
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: total == 0
                  ? Container(
                      height: 14,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: AppTheme.background,
                      ),
                    )
                  : Row(
                      children: [
                        Flexible(
                          flex: s2Flex,
                          child: Container(
                            height: 14,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          flex: s1Flex,
                          child: Container(
                            height: 14,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF06B6D4), Color(0xFF2563EB)],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(width: 8),
          // P1 score
          SizedBox(
            width: 38,
            child: Text(
              '$score1',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2563EB),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Timer
          AnimatedBuilder(
            animation: pulseController,
            builder: (context, child) {
              final scale = isLow
                  ? Tween<double>(begin: 1.0, end: 1.18).evaluate(
                      CurvedAnimation(
                          parent: pulseController, curve: Curves.elasticOut),
                    )
                  : 1.0;
              return Transform.scale(scale: scale, child: child);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isLow
                    ? Colors.redAccent.withValues(alpha: 0.18)
                    : AppTheme.background,
                borderRadius: BorderRadius.circular(10),
                border: isLow
                    ? Border.all(
                        color: Colors.redAccent.withValues(alpha: 0.6),
                        width: 1.5,
                      )
                    : null,
              ),
              child: Text(
                '${timeLeft}s',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isLow ? Colors.redAccent : AppTheme.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountdownOverlay extends StatelessWidget {
  const _CountdownOverlay({
    required this.countdown,
    required this.controller,
  });

  final int countdown;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'GET READY',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 4,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                final scale = Tween<double>(begin: 1.5, end: 0.85).evaluate(
                  CurvedAnimation(parent: controller, curve: Curves.easeOut),
                );
                final opacity = Tween<double>(begin: 1.0, end: 0.2).evaluate(
                  CurvedAnimation(parent: controller, curve: Curves.easeIn),
                );
                return Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF10B981)],
                      ).createShader(bounds),
                      child: Text(
                        '$countdown',
                        style: const TextStyle(
                          fontSize: 130,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Tap as fast as you can!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

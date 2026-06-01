import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tap_tap_game/app_theme.dart';
import 'package:tap_tap_game/routes/app_routes.dart';
import 'package:tap_tap_game/screens/game_over_screen.dart';
import 'package:tap_tap_game/services/score_service.dart';
import 'package:tap_tap_game/services/sound_service.dart';
import 'package:tap_tap_game/widgets/icon_action_button.dart';
import 'package:tap_tap_game/widgets/tap_circle_button.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  static const int gameDurationSeconds = 30;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final ScoreService _scoreService = ScoreService();
  final SoundService _soundService = SoundService();

  int _score = 0;
  int _timeLeft = GameScreen.gameDurationSeconds;
  bool _isPaused = false;
  bool _gameEnded = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused || _gameEnded) return;
      if (_timeLeft <= 1) {
        _endGame();
      } else {
        setState(() => _timeLeft--);
      }
    });
  }

  void _onTap() {
    if (_isPaused || _gameEnded) return;
    _soundService.playTap();
    setState(() => _score++);
  }

  void _togglePause() {
    if (_gameEnded) return;
    setState(() => _isPaused = !_isPaused);
  }

  void _toggleSound() {
    setState(() => _soundService.toggle());
  }

  Future<void> _endGame() async {
    if (_gameEnded) return;
    _gameEnded = true;
    _timer?.cancel();

    final highScore = await _scoreService.saveScoreIfHigh(_score);
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      FadeSlideRoute(
        page: GameOverScreen(
          score: _score,
          highScore: highScore,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildTopBar(),
              const Spacer(flex: 2),
              TapCircleButton(
                onTap: _onTap,
                enabled: !_isPaused && !_gameEnded,
              ),
              if (_isPaused)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    'PAUSED',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.textSecondary,
                          letterSpacing: 3,
                        ),
                  ),
                ),
              const Spacer(flex: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconActionButton(
                    icon: _isPaused
                        ? Icons.play_arrow_rounded
                        : Icons.pause_rounded,
                    label: _isPaused ? 'Resume' : 'Pause',
                    onPressed: _togglePause,
                  ),
                  const SizedBox(width: 48),
                  IconActionButton(
                    icon: _soundService.isEnabled
                        ? Icons.volume_up_rounded
                        : Icons.volume_off_rounded,
                    label: 'Sound',
                    isActive: _soundService.isEnabled,
                    onPressed: _toggleSound,
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _StatChip(
          icon: Icons.star_rounded,
          label: 'Score',
          value: '$_score',
        ),
        _StatChip(
          icon: Icons.timer_rounded,
          label: 'Time',
          value: '$_timeLeft s',
          highlight: _timeLeft <= 10,
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: highlight
            ? Border.all(color: Colors.redAccent.withValues(alpha: 0.6))
            : null,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: highlight ? Colors.redAccent : AppTheme.primaryStart,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: highlight ? Colors.redAccent : AppTheme.textPrimary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

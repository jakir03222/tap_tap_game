import 'package:flutter/material.dart';
import 'package:tap_tap_game/app_theme.dart';
import 'package:tap_tap_game/routes/app_routes.dart';
import 'package:tap_tap_game/screens/game_screen.dart';
import 'package:tap_tap_game/screens/home_screen.dart';
import 'package:tap_tap_game/widgets/gradient_button.dart';

class GameOverScreen extends StatelessWidget {
  const GameOverScreen({
    super.key,
    required this.score,
    required this.highScore,
  });

  final int score;
  final int highScore;

  bool get _isNewHighScore => score >= highScore && score > 0;

  void _restart(BuildContext context) {
    Navigator.of(context).pushReplacement(
      FadeSlideRoute(page: const GameScreen()),
    );
  }

  void _goHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      FadeSlideRoute(page: const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.surface,
                ),
                child: Icon(
                  _isNewHighScore
                      ? Icons.emoji_events_rounded
                      : Icons.flag_rounded,
                  size: 44,
                  color: _isNewHighScore
                      ? const Color(0xFFFBBF24)
                      : AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Game Over',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (_isNewHighScore) ...[
                const SizedBox(height: 8),
                Text(
                  'New High Score!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFFFBBF24),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
              const Spacer(),
              _ScoreCard(
                label: 'Your Score',
                value: score,
                isPrimary: true,
              ),
              const SizedBox(height: 16),
              _ScoreCard(
                label: 'Best Score',
                value: highScore,
              ),
              const Spacer(flex: 2),
              GradientButton(
                label: 'Play Again',
                icon: Icons.replay_rounded,
                onPressed: () => _restart(context),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () => _goHome(context),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Home'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textPrimary,
                    side: BorderSide(
                      color: AppTheme.textSecondary.withValues(alpha: 0.4),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.label,
    required this.value,
    this.isPrimary = false,
  });

  final String label;
  final int value;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: isPrimary
            ? Border.all(
                color: AppTheme.primaryStart.withValues(alpha: 0.5),
                width: 1.5,
              )
            : null,
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isPrimary ? AppTheme.primaryStart : AppTheme.textPrimary,
                ),
          ),
        ],
      ),
    );
  }
}

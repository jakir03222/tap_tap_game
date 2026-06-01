import 'package:flutter/material.dart';
import 'package:tap_tap_game/app_theme.dart';
import 'package:tap_tap_game/routes/app_routes.dart';
import 'package:tap_tap_game/screens/home_screen.dart';
import 'package:tap_tap_game/screens/two_player_game_screen.dart';
import 'package:tap_tap_game/widgets/gradient_button.dart';

class TwoPlayerGameOverScreen extends StatelessWidget {
  const TwoPlayerGameOverScreen({
    super.key,
    required this.score1,
    required this.score2,
  });

  final int score1;
  final int score2;

  bool get _isTie => score1 == score2;
  bool get _player1Wins => score1 > score2;

  @override
  Widget build(BuildContext context) {
    final winnerColor =
        _isTie ? AppTheme.textSecondary : (_player1Wins ? const Color(0xFF2563EB) : const Color(0xFF8B5CF6));

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Trophy / tie icon
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: winnerColor.withValues(alpha: 0.25),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  _isTie ? Icons.handshake_rounded : Icons.emoji_events_rounded,
                  size: 52,
                  color: _isTie ? AppTheme.textSecondary : const Color(0xFFFBBF24),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _isTie
                    ? "It's a Tie!"
                    : (_player1Wins ? 'Player 1 Wins!' : 'Player 2 Wins!'),
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                _isTie
                    ? 'Both players tapped equally!'
                    : (_player1Wins
                        ? 'By ${score1 - score2} tap${score1 - score2 == 1 ? '' : 's'}'
                        : 'By ${score2 - score1} tap${score2 - score1 == 1 ? '' : 's'}'),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const Spacer(),
              // Score cards
              Row(
                children: [
                  Expanded(
                    child: _PlayerScoreCard(
                      label: 'Player 2',
                      score: score2,
                      isWinner: !_isTie && !_player1Wins,
                      gradientColors: const [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _PlayerScoreCard(
                      label: 'Player 1',
                      score: score1,
                      isWinner: !_isTie && _player1Wins,
                      gradientColors: const [Color(0xFF2563EB), Color(0xFF06B6D4)],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Visual bar comparison
              _ComparisonBar(score1: score1, score2: score2),
              const Spacer(flex: 2),
              GradientButton(
                label: 'Play Again',
                icon: Icons.replay_rounded,
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    FadeSlideRoute(page: const TwoPlayerGameScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      FadeSlideRoute(page: const HomeScreen()),
                      (route) => false,
                    );
                  },
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

class _PlayerScoreCard extends StatelessWidget {
  const _PlayerScoreCard({
    required this.label,
    required this.score,
    required this.isWinner,
    required this.gradientColors,
  });

  final String label;
  final int score;
  final bool isWinner;
  final List<Color> gradientColors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: isWinner
            ? Border.all(
                color: gradientColors[0].withValues(alpha: 0.6),
                width: 2,
              )
            : null,
        boxShadow: isWinner
            ? [
                BoxShadow(
                  color: gradientColors[0].withValues(alpha: 0.2),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          if (isWinner) ...[
            const Icon(
              Icons.star_rounded,
              color: Color(0xFFFBBF24),
              size: 22,
            ),
            const SizedBox(height: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: gradientColors[0],
            ),
          ),
          const SizedBox(height: 6),
          ShaderMask(
            shaderCallback: (bounds) =>
                LinearGradient(colors: gradientColors).createShader(bounds),
            child: Text(
              '$score',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
          ),
          Text(
            'taps',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonBar extends StatelessWidget {
  const _ComparisonBar({required this.score1, required this.score2});

  final int score1;
  final int score2;

  @override
  Widget build(BuildContext context) {
    final total = score1 + score2;
    final s2Flex = total == 0 ? 1 : score2;
    final s1Flex = total == 0 ? 1 : score1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'P2',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.8),
              ),
            ),
            Text(
              'P1',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2563EB).withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Row(
            children: [
              Flexible(
                flex: s2Flex,
                child: Container(
                  height: 16,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                    ),
                  ),
                ),
              ),
              if (total == 0) const SizedBox(width: 2),
              Flexible(
                flex: s1Flex,
                child: Container(
                  height: 16,
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
      ],
    );
  }
}

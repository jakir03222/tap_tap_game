import 'package:flutter/material.dart';
import 'package:tap_tap_game/app_theme.dart';
import 'package:tap_tap_game/routes/app_routes.dart';
import 'package:tap_tap_game/screens/game_screen.dart';
import 'package:tap_tap_game/screens/two_player_game_screen.dart';
import 'package:tap_tap_game/services/score_service.dart';
import 'package:tap_tap_game/widgets/gradient_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScoreService _scoreService = ScoreService();
  int _highScore = 0;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final score = await _scoreService.getHighScore();
    if (mounted) setState(() => _highScore = score);
  }

  void _startGame() {
    Navigator.of(context)
        .push(FadeSlideRoute(page: const GameScreen()))
        .then((_) => _loadHighScore());
  }

  void _start2PlayerGame() {
    Navigator.of(context).push(
      FadeSlideRoute(page: const TwoPlayerGameScreen()),
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
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryStart.withValues(alpha: 0.4),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.touch_app_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Tap Tap Game',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap as fast as you can!',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      'High Score',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_highScore',
                      style:
                          Theme.of(context).textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                foreground: Paint()
                                  ..shader = AppTheme.primaryGradient
                                      .createShader(
                                    const Rect.fromLTWH(0, 0, 200, 70),
                                  ),
                              ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              GradientButton(
                label: 'Solo Mode',
                icon: Icons.person_rounded,
                onPressed: _startGame,
              ),
              const SizedBox(height: 14),
              GradientButton(
                label: '2 Player Mode',
                icon: Icons.people_rounded,
                onPressed: _start2PlayerGame,
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                glowColor: const Color(0xFF8B5CF6),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

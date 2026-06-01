import 'package:flutter/material.dart';
import 'package:tap_tap_game/app_theme.dart';

class TapCircleButton extends StatefulWidget {
  const TapCircleButton({
    super.key,
    required this.onTap,
    this.enabled = true,
  });

  final VoidCallback onTap;
  final bool enabled;

  @override
  State<TapCircleButton> createState() => _TapCircleButtonState();
}

class _TapCircleButtonState extends State<TapCircleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (!widget.enabled) return;
    await _controller.forward();
    await _controller.reverse();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: widget.enabled
                ? AppTheme.tapButtonGradient
                : LinearGradient(
                    colors: [
                      AppTheme.surface,
                      AppTheme.surface.withValues(alpha: 0.8),
                    ],
                  ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryStart.withValues(
                  alpha: widget.enabled ? 0.45 : 0.1,
                ),
                blurRadius: 32,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Center(
            child: Text(
              'TAP',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

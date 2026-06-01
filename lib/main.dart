import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tap_tap_game/app_theme.dart';
import 'package:tap_tap_game/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const TapTapGameApp());
}

class TapTapGameApp extends StatelessWidget {
  const TapTapGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tap Tap Game',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}


git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/jakir03222/tap_tap_game.git
git push -u origin main
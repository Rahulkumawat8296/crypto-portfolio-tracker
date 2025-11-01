import 'package:crypto_portfolio/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';



class SplashScreenCoin extends StatefulWidget {
  const SplashScreenCoin({super.key});
  @override
  State<SplashScreenCoin> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreenCoin> with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _anim.forward();
    Future.delayed(const Duration(seconds: 2), () {
      Get.off(() => const PortfolioScreen());
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade900,
      body: Center(
        child: FadeTransition(
          opacity: _anim.drive(CurveTween(curve: Curves.easeIn)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.show_chart, size: 88, color: Colors.white),
              SizedBox(height: 12),
              Text('Crypto Portfolio', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600,color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
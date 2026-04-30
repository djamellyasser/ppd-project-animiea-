import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/scan_result.dart';
import 'result_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with TickerProviderStateMixin {
  late AnimationController _borderController;
  late Animation<double> _borderOpacity;

  final bool _lightingOk = true;
  final bool _focusOk = true;
  bool _steady = false; // Simulates "not yet steady"

  @override
  void initState() {
    super.initState();
    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _borderOpacity = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _borderController, curve: Curves.easeInOut),
    );

    // Simulate steadiness after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _steady = true);
    });
  }

  @override
  void dispose() {
    _borderController.dispose();
    super.dispose();
  }

  void _onCapture() {
    // Navigate to result screen with mock data
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ResultScreen(result: ScanResult.mock())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cameraBg,
      body: Column(
        children: [
          _TopBar(),
          Expanded(child: _Viewfinder(borderOpacity: _borderOpacity)),
          _QualityBar(lightingOk: _lightingOk, focusOk: _focusOk, steady: _steady),
          _Controls(onCapture: _onCapture),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TOP BAR
// ─────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            _CameraIconBtn(
              icon: Icons.arrow_back,
              onTap: () => Navigator.pop(context),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  'Eyelid Scan',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFont,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            _CameraIconBtn(icon: Icons.info_outline, onTap: () {}),
          ],
        ),
      ),
    );
  }
}

class _CameraIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CameraIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// VIEWFINDER
// ─────────────────────────────────────────────
class _Viewfinder extends StatelessWidget {
  final Animation<double> borderOpacity;
  const _Viewfinder({required this.borderOpacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF1A1208),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Eyelid guide frame
            AnimatedBuilder(
              animation: borderOpacity,
              builder: (_, __) => Opacity(
                opacity: borderOpacity.value,
                child: CustomPaint(
                  size: const Size(260, 140),
                  painter: _EyelidFramePainter(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFont,
                    fontSize: 13,
                    color: Colors.white70,
                    height: 1.6,
                  ),
                  children: [
                    TextSpan(text: 'Pull down your '),
                    TextSpan(
                      text: 'lower eyelid',
                      style: TextStyle(color: AppColors.accent2, fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: '\nand center it in the frame'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EyelidFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent2.withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Oval frame
    canvas.drawOval(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Corner accents
    final cornerPaint = Paint()
      ..color = AppColors.accent2
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    const len = 22.0;
    // Top-left
    canvas.drawLine(const Offset(0, len), const Offset(0, 0), cornerPaint);
    canvas.drawLine(const Offset(0, 0), const Offset(len, 0), cornerPaint);
    // Bottom-right
    canvas.drawLine(Offset(size.width, size.height - len), Offset(size.width, size.height), cornerPaint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - len, size.height), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────
// QUALITY BAR
// ─────────────────────────────────────────────
class _QualityBar extends StatelessWidget {
  final bool lightingOk;
  final bool focusOk;
  final bool steady;
  const _QualityBar({required this.lightingOk, required this.focusOk, required this.steady});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          _QualityChip(label: 'Lighting', ok: lightingOk),
          const SizedBox(width: 8),
          _QualityChip(label: 'Focus', ok: focusOk),
          const SizedBox(width: 8),
          _QualityChip(label: steady ? 'Steady ✓' : 'Steady…', ok: steady),
        ],
      ),
    );
  }
}

class _QualityChip extends StatelessWidget {
  final String label;
  final bool ok;
  const _QualityChip({required this.label, required this.ok});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ok ? AppColors.green : AppColors.yellow,
              ),
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: const TextStyle(
                fontFamily: AppTextStyles.bodyFont,
                fontSize: 11,
                color: Colors.white60,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CONTROLS
// ─────────────────────────────────────────────
class _Controls extends StatelessWidget {
  final VoidCallback onCapture;
  const _Controls({required this.onCapture});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const _SideBtn(icon: Icons.flash_off_rounded),
            _ShutterBtn(onTap: onCapture),
            const _SideBtn(icon: Icons.flip_camera_ios_rounded),
          ],
        ),
      ),
    );
  }
}

class _SideBtn extends StatelessWidget {
  final IconData icon;
  const _SideBtn({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48, height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.1),
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }
}

class _ShutterBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _ShutterBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 76, height: 76,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.3), blurRadius: 20, spreadRadius: 4)],
        ),
        padding: const EdgeInsets.all(5),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border, width: 3),
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

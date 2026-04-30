import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../models/scan_result.dart';
import '../services/superbase_service.dart';
import '../config.dart';
import 'result_screen.dart';

class WaitingScreen extends StatefulWidget {
  final File image;
  const WaitingScreen({super.key, required this.image});

  @override
  State<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _arrowController;
  late Animation<double> _progressAnimation;
  late Animation<double> _arrowAnimation;
  String _statusText = 'Preparing image...';
  String? _segmentedBase64;
  bool _segmentDone = false;

  @override
  void initState() {
    super.initState();

    // Progress bar — slow and long
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    _progressController.forward();

    // Arrow — fast and independent, completes in 2 seconds
    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _arrowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _arrowController, curve: Curves.easeInOut),
    );

    _startScan();
  }

  Future<void> _startScan() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _statusText = 'Segmenting conjunctiva...');

    final segFuture = _fetchSegmented();
    final predictFuture = _fetchPredict();

    await segFuture;
    await predictFuture;
  }

  Future<void> _fetchSegmented() async {
    try {
      final uri = Uri.parse('${AppConfig.apiBaseUrl}/segment');
      final request = http.MultipartRequest('POST', uri);
      request.files.add(
        await http.MultipartFile.fromPath('file', widget.image.path),
      );
      final response = await request.send();
      final body = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        final decoded = jsonDecode(body);
        if (mounted) {
          setState(() {
            _segmentedBase64 = decoded['segmented_image'];
            _segmentDone = true;
          });
          // Start arrow animation as soon as segmented image arrives
          _arrowController.forward();
        }
      }
    } catch (_) {}
  }

  Future<void> _fetchPredict() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _statusText = 'Running AI model...');

    try {
      final uri = Uri.parse('${AppConfig.apiBaseUrl}/predict');
      final request = http.MultipartRequest('POST', uri);
      request.files.add(
        await http.MultipartFile.fromPath('file', widget.image.path),
      );
      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (mounted) setState(() => _statusText = 'Finalizing result...');

      // Wait so user can see the segmented image clearly
      await Future.delayed(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decoded = jsonDecode(body);
        final resultStr = decoded['result'] as String;
        final confidence = (decoded['confidence'] as num).toDouble();
        final status = resultStr == 'anemic'
            ? AnemiaStatus.anemic
            : AnemiaStatus.notAnemic;

        await SupabaseService().saveScan(resultStr, confidence);
        _goToResult(status, confidence);
      } else {
        _showError('Server error. Please try again.');
      }
    } catch (e) {
      _showError('Could not reach server: $e');
    }
  }

  void _goToResult(AnemiaStatus status, double confidence) {
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          result: ScanResult(
            status: status,
            scannedAt: DateTime.now(),
            scanMethod: 'eyelid',
            confidence: confidence,
          ),
        ),
      ),
      (r) => r.isFirst,
    );
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _progressController.dispose();
    _arrowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A1510), Color(0xFF3B2218)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Analyzing...',
                    style: TextStyle(
                      fontFamily: AppTextStyles.displayFont,
                      fontSize: 28,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _statusText,
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFont,
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.55),
                    ),
                  ),
                  const SizedBox(height: 20),
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            child: LinearProgressIndicator(
                              value: _progressAnimation.value,
                              minHeight: 6,
                              backgroundColor: Colors.white.withOpacity(0.15),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.accent),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${(_progressAnimation.value * 100).toInt()}%',
                            style: TextStyle(
                              fontFamily: AppTextStyles.bodyFont,
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            // ── Image comparison ──
            Expanded(
              child: Center(
                child: _segmentDone && _segmentedBase64 != null
                    ? _ImageComparison(
                        original: widget.image,
                        segmentedBase64: _segmentedBase64!,
                        arrowAnimation: _arrowAnimation,
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('👁️', style: TextStyle(fontSize: 64)),
                          SizedBox(height: 20),
                          Text(
                            'Segmenting conjunctiva...',
                            style: AppTextStyles.caption,
                          ),
                          SizedBox(height: 20),
                          CircularProgressIndicator(
                            color: AppColors.accent,
                            strokeWidth: 3,
                          ),
                        ],
                      ),
              ),
            ),

            // ── Bottom note ──
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
              child: Text(
                'This may take a few seconds. Please keep the app open.',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// IMAGE COMPARISON WIDGET
// ─────────────────────────────────────────────
class _ImageComparison extends StatelessWidget {
  final File original;
  final String segmentedBase64;
  final Animation<double> arrowAnimation;

  const _ImageComparison({
    required this.original,
    required this.segmentedBase64,
    required this.arrowAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final segBytes = base64Decode(segmentedBase64);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Original on top ──
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Original',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFont,
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.5),
                  )),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  original,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),

          // ── Animated arrow pointing down ──
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: AnimatedBuilder(
              animation: arrowAnimation,
              builder: (_, __) =>
                  _AnimatedArrowDown(progress: arrowAnimation.value),
            ),
          ),

          // ── Segmented below ──
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Segmented',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFont,
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.5),
                  )),
              const SizedBox(height: 8),
              AnimatedOpacity(
                opacity: arrowAnimation.value,
                duration: const Duration(milliseconds: 400),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.memory(
                    segBytes,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Text(
            'AI isolated the conjunctiva region',
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFont,
              fontSize: 12,
              color: Colors.white.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ANIMATED ARROW (pointing down)
// ─────────────────────────────────────────────
class _AnimatedArrowDown extends StatelessWidget {
  final double progress;
  const _AnimatedArrowDown({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 28,
      child: CustomPaint(
        painter: _ArrowDownPainter(progress: progress),
      ),
    );
  }
}

class _ArrowDownPainter extends CustomPainter {
  final double progress;
  const _ArrowDownPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent.withOpacity(progress.clamp(0.0, 1.0))
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final lineEnd = size.height * progress;
    canvas.drawLine(Offset(cx, 0), Offset(cx, lineEnd), paint);

    if (progress > 0.7) {
      final arrowOpacity = ((progress - 0.7) / 0.3).clamp(0.0, 1.0);
      final arrowPaint = Paint()
        ..color = AppColors.accent.withOpacity(arrowOpacity)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(cx - 8, size.height - 10),
        Offset(cx, size.height),
        arrowPaint,
      );
      canvas.drawLine(
        Offset(cx + 8, size.height - 10),
        Offset(cx, size.height),
        arrowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ArrowDownPainter old) => old.progress != progress;
}
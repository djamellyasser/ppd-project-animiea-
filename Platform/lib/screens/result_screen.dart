import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/scan_result.dart';
import '../widgets/common_widgets.dart';
import 'home_screen.dart';

class ResultScreen extends StatelessWidget {
  final ScanResult result;
  const ResultScreen({super.key, required this.result});

  bool get _isAnemic => result.status == AnemiaStatus.anemic;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          _ResultHeader(result: result),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
              child: Column(
                children: [
                  _ConfidenceCard(result: result),
                  const SizedBox(height: 16),
                  _ScanInfoCard(result: result),
                  const SizedBox(height: 16),
                  _RecommendationCard(isAnemic: _isAnemic),
                  const SizedBox(height: 20),
                  _ActionButtons(
                    onSave: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (r) => false,
                    ),
                    onShare: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// RESULT HEADER
// ─────────────────────────────────────────────
class _ResultHeader extends StatelessWidget {
  final ScanResult result;
  const _ResultHeader({required this.result});

  bool get _isAnemic => result.status == AnemiaStatus.anemic;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1510), Color(0xFF3B2218)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              top: -80, right: -80,
              child: Container(
                width: 300, height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      (_isAnemic ? AppColors.red : AppColors.green).withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.arrow_back, color: Colors.white54, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Back',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.5),
                            fontFamily: AppTextStyles.bodyFont,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Scan Result',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.5),
                      fontFamily: AppTextStyles.bodyFont,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: (_isAnemic ? AppColors.red : AppColors.green).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: (_isAnemic ? AppColors.red : AppColors.green).withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _isAnemic ? '⚠️' : '✅',
                        style: const TextStyle(fontSize: 36),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isAnemic ? 'Anemia Detected' : 'No Anemia Detected',
                    style: const TextStyle(
                      fontFamily: AppTextStyles.displayFont,
                      fontSize: 30,
                      color: Colors.white,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  StatusBadge(status: result.status, large: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CONFIDENCE CARD
// ─────────────────────────────────────────────
class _ConfidenceCard extends StatelessWidget {
  final ScanResult result;
  const _ConfidenceCard({required this.result});

  bool get _isAnemic => result.status == AnemiaStatus.anemic;

  Color get _barColor {
    if (result.confidence >= 0.75) {
      return _isAnemic ? AppColors.red : AppColors.green;
    } else if (result.confidence >= 0.55) {
      return const Color(0xFFE8A020); // orange — uncertain
    } else {
      return AppColors.inkSoft; // low confidence
    }
  }

  String get _confidenceLabel {
    if (result.confidence >= 0.75) return 'High Confidence';
    if (result.confidence >= 0.55) return 'Moderate Confidence';
    return 'Low Confidence — consider rescanning';
  }

  @override
  Widget build(BuildContext context) {
    final pct = (result.confidence * 100).toInt();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('AI Confidence', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
              Text(
                '$pct%',
                style: TextStyle(
                  fontFamily: AppTextStyles.displayFont,
                  fontSize: 24,
                  color: _barColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: result.confidence,
              minHeight: 10,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(_barColor),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _confidenceLabel,
            style: AppTextStyles.caption.copyWith(color: _barColor),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SCAN INFO CARD
// ─────────────────────────────────────────────
class _ScanInfoCard extends StatelessWidget {
  final ScanResult result;
  const _ScanInfoCard({required this.result});

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} · $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          _InfoCell(icon: '👁️', label: 'Method', value: 'Eyelid'),
          _Divider(),
          _InfoCell(icon: '📅', label: 'Date', value: _formatDate(result.scannedAt)),
          _Divider(),
          _InfoCell(icon: '🤖', label: 'Model', value: 'AI v2.0'),
        ],
      ),
    );
  }
}

class _InfoCell extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  const _InfoCell({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 2),
          Text(value, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 48, color: AppColors.border);
  }
}

// ─────────────────────────────────────────────
// RECOMMENDATION CARD
// ─────────────────────────────────────────────
class _RecommendationCard extends StatelessWidget {
  final bool isAnemic;
  const _RecommendationCard({required this.isAnemic});

  List<String> get _recs => isAnemic
      ? [
          'Visit a healthcare professional for a confirmatory blood test.',
          'Consider iron-rich foods: spinach, lentils, red meat, fortified cereals.',
          'Avoid intense physical activity until evaluated by a doctor.',
          'Re-scan in 7 days to monitor any changes.',
        ]
      : [
          'Your scan shows no signs of anemia — great news!',
          'Maintain a balanced diet rich in iron and vitamins.',
          'Continue regular scans every 2–4 weeks as a routine check.',
        ];

  @override
  Widget build(BuildContext context) {
    final color = isAnemic ? AppColors.red : AppColors.green;
    final bgColor = isAnemic ? AppColors.redLight : AppColors.greenLight;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(isAnemic ? '⚠️' : '💡', style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                'Recommendations',
                style: TextStyle(
                  fontFamily: AppTextStyles.bodyFont,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color.withOpacity(0.85),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._recs.map((rec) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('•', style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        rec,
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFont,
                          fontSize: 13,
                          color: color.withOpacity(0.8),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ACTION BUTTONS
// ─────────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onShare;
  const _ActionButtons({required this.onSave, required this.onShare});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onSave,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(AppRadius.cardSm),
                boxShadow: AppShadow.accent,
              ),
              child: const Center(
                child: Text('Save Result',
                    style: TextStyle(fontFamily: AppTextStyles.bodyFont, fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: onShare,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppRadius.cardSm),
                boxShadow: AppShadow.card,
              ),
              child: const Center(
                child: Text('Share',
                    style: TextStyle(fontFamily: AppTextStyles.bodyFont, fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
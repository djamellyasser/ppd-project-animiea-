import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/scan_result.dart';
import '../widgets/common_widgets.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'result_screen.dart';
import '../services/superbase_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _supabaseService = SupabaseService();
  String _name = '';
  ScanResult? _lastScan;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _supabaseService.getUser();
    final scans = await _supabaseService.getLastScan();
    if (mounted) {
      setState(() {
        _name = data?['name'] ?? 'there';
        if (scans != null) {
          final ts = scans['scanned_at'];
          _lastScan = ScanResult(
            status: scans['status'] == 'anemic' ? AnemiaStatus.anemic : AnemiaStatus.notAnemic,
            scannedAt: ts != null ? DateTime.parse(ts.toString()) : DateTime.now(),
            scanMethod: scans['scan_method'] ?? 'eyelid',
            confidence: (scans['confidence'] as num?)?.toDouble() ?? 0.0,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeroSection(name: _name),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_lastScan != null) _LastResultCard(result: _lastScan!),
                        const SizedBox(height: 28),
                        const SectionTitle('Quick Actions'),
                        const SizedBox(height: 14),
                        _QuickActionsGrid(context: context),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppBottomNav(
            currentIndex: 0,
            onTap: (i) => _onNavTap(context, i),
          ),
        ],
      ),
    );
  }

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        break;
    }
  }
}

class _HeroSection extends StatelessWidget {
  final String name;
  const _HeroSection({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1510), Color(0xFF3B2218), Color(0xFF5C2E1A)],
          stops: [0.0, 0.6, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              top: -60, right: -60,
              child: Container(
                width: 280, height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [AppColors.accent.withOpacity(0.25), Colors.transparent],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good morning, $name 👋',
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFont,
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.55),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontFamily: AppTextStyles.displayFont,
                        fontSize: 32,
                        color: Colors.white,
                        height: 1.15,
                      ),
                      children: [
                        TextSpan(text: 'Monitor your\n'),
                        TextSpan(
                          text: 'health ',
                          style: TextStyle(color: AppColors.accent2, fontStyle: FontStyle.italic),
                        ),
                        TextSpan(text: 'anywhere'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _PulseDot(),
                        const SizedBox(width: 8),
                        Text(
                          'AI Model Ready',
                          style: TextStyle(
                            fontFamily: AppTextStyles.bodyFont,
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _opacity = Tween<double>(begin: 1.0, end: 0.3).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: 7, height: 7,
        decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle),
      ),
    );
  }
}

class _LastResultCard extends StatelessWidget {
  final ScanResult result;
  const _LastResultCard({required this.result});

  Color get _iconBg => result.status == AnemiaStatus.notAnemic ? AppColors.greenLight : AppColors.redLight;

  Color get _confidenceColor {
    if (result.confidence >= 0.75) {
      return result.status == AnemiaStatus.notAnemic ? AppColors.green : AppColors.red;
    } else if (result.confidence >= 0.55) {
      return const Color(0xFFE8A020);
    }
    return AppColors.inkSoft;
  }

  @override
  Widget build(BuildContext context) {
    final pct = (result.confidence * 100).toInt();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Last Result'),
        const SizedBox(height: 14),
        AppCard(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ResultScreen(result: result))),
          child: Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: _iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(child: Text('👁️', style: TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Eyelid Scan', style: AppTextStyles.caption.copyWith(letterSpacing: 0.5)),
                    const SizedBox(height: 6),
                    StatusBadge(status: result.status, large: true),
                    const SizedBox(height: 8),
                    // Confidence bar
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            child: LinearProgressIndicator(
                              value: result.confidence,
                              minHeight: 4,
                              backgroundColor: AppColors.border,
                              valueColor: AlwaysStoppedAnimation<Color>(_confidenceColor),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$pct%',
                          style: AppTextStyles.caption.copyWith(
                            color: _confidenceColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.inkSoft),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  final BuildContext context;
  const _QuickActionsGrid({required this.context});

  static const _items = [
    {'icon': '📊', 'title': 'History', 'sub': 'View all scans'},
    {'icon': '👤', 'title': 'Profile', 'sub': 'Your info'},
    {'icon': '📤', 'title': 'Export', 'sub': 'PDF report'},
  ];

  @override
  Widget build(BuildContext bContext) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: List.generate(_items.length, (index) {
        final item = _items[index];
        return AppCard(
          padding: const EdgeInsets.all(18),
          radius: AppRadius.cardSm,
          onTap: () => _onQuickTap(bContext, index),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(item['icon']!, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 10),
              Text(item['title']!, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(item['sub']!, style: AppTextStyles.caption),
            ],
          ),
        );
      }),
    );
  }

  void _onQuickTap(BuildContext ctx, int index) {
    switch (index) {
      case 0:
        Navigator.push(ctx, MaterialPageRoute(builder: (_) => const HistoryScreen()));
        break;
      case 1:
        Navigator.push(ctx, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        break;
      case 2:
        break;
    }
  }
}
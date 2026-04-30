import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/scan_result.dart';
import '../widgets/common_widgets.dart';
import '../services/superbase_service.dart';
import 'result_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _supabaseService = SupabaseService();

  AnemiaStatus _statusFromString(String s) =>
      s == 'anemic' ? AnemiaStatus.anemic : AnemiaStatus.notAnemic;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _supabaseService.scansStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.accent));
                }

                final scans = snapshot.data ?? [];
                final anemicCount = scans.where((s) => s['status'] == 'anemic').length;

                final results = scans.map((s) {
                  final ts = s['scanned_at'];
                  DateTime scannedAt = DateTime.now();
                  if (ts != null) {
                    scannedAt = DateTime.parse(ts.toString());
                  }
                  return ScanResult(
                    status: _statusFromString(s['status'] ?? 'notAnemic'),
                    scannedAt: scannedAt,
                    scanMethod: s['scan_method'] ?? 'eyelid',
                    confidence: (s['confidence'] as num?)?.toDouble() ?? 0.0,
                  );
                }).toList();

                final Map<String, List<ScanResult>> grouped = {};
                for (final scan in results) {
                  final key = _monthKey(scan.scannedAt);
                  grouped.putIfAbsent(key, () => []).add(scan);
                }

                final List<Widget> items = [];
                for (final month in grouped.keys) {
                  items.add(_MonthLabel(month));
                  for (final scan in grouped[month]!) {
                    items.add(_HistoryItem(
                      result: scan,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ResultScreen(result: scan)),
                      ),
                    ));
                  }
                }

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _HistoryHeader(
                        totalScans: scans.length,
                        anemicCount: anemicCount,
                        lastScan: results.isNotEmpty ? results.first.scannedAt : null,
                      ),
                    ),
                    if (scans.isEmpty)
                      const SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('👁️', style: TextStyle(fontSize: 48)),
                              SizedBox(height: 16),
                              Text('No scans yet', style: AppTextStyles.title),
                              SizedBox(height: 8),
                              Text('Take your first scan to get started', style: AppTextStyles.caption),
                            ],
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(28, 8, 28, 32),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => items[index],
                            childCount: items.length,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          AppBottomNav(
            currentIndex: 1,
            onTap: (i) {
              switch (i) {
                case 0:
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (r) => false);
                  break;
                case 3:
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                  break;
              }
            },
          ),
        ],
      ),
    );
  }

  String _monthKey(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.year}';
  }
}

class _HistoryHeader extends StatelessWidget {
  final int totalScans;
  final int anemicCount;
  final DateTime? lastScan;
  const _HistoryHeader({required this.totalScans, required this.anemicCount, required this.lastScan});

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(28, MediaQuery.of(context).padding.top + 24, 28, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Scan History', style: AppTextStyles.headline.copyWith(fontSize: 30)),
          const SizedBox(height: 16),
          AppCard(
            padding: EdgeInsets.zero,
            child: IntrinsicHeight(
              child: Row(
                children: [
                  _StatCell(value: totalScans.toString(), label: 'Total Scans'),
                  const VerticalDivider(color: AppColors.border, width: 1),
                  _StatCell(
                    value: anemicCount.toString(),
                    label: 'Anemic',
                    valueColor: anemicCount > 0 ? AppColors.red : AppColors.green,
                  ),
                  const VerticalDivider(color: AppColors.border, width: 1),
                  _StatCell(
                    value: lastScan != null ? _formatDate(lastScan!) : '-',
                    label: 'Last Scan',
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

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;
  const _StatCell({required this.value, required this.label, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontFamily: AppTextStyles.displayFont, fontSize: 28, color: valueColor ?? AppColors.ink)),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

class _MonthLabel extends StatelessWidget {
  final String month;
  const _MonthLabel(this.month);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: SectionTitle(month),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final ScanResult result;
  final VoidCallback onTap;
  const _HistoryItem({required this.result, required this.onTap});

  Color get _iconBg => result.status == AnemiaStatus.notAnemic ? AppColors.greenLight : AppColors.redLight;

  Color get _confidenceColor {
    if (result.confidence >= 0.75) {
      return result.status == AnemiaStatus.notAnemic ? AppColors.green : AppColors.red;
    } else if (result.confidence >= 0.55) {
      return const Color(0xFFE8A020);
    }
    return AppColors.inkSoft;
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    if (diff.inHours < 6) return 'Today, $h:$m';
    if (diff.inDays < 2) return 'Yesterday, $h:$m';
    return '${months[dt.month - 1]} ${dt.day}, $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final pct = (result.confidence * 100).toInt();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        radius: AppRadius.cardSm,
        onTap: onTap,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: _iconBg, borderRadius: BorderRadius.circular(12)),
              child: const Center(child: Text('👁️', style: TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Eyelid Scan', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Text(_formatDate(result.scannedAt), style: AppTextStyles.caption),
                  const SizedBox(height: 6),
                  // Confidence mini bar
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
                      Text('$pct%', style: AppTextStyles.caption.copyWith(color: _confidenceColor, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            StatusBadge(status: result.status),
          ],
        ),
      ),
    );
  }
}
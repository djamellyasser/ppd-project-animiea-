import 'package:anemia_lens/screens/login_screen.dart';
import 'package:anemia_lens/services/auth_service.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/scan_result.dart';
import '../widgets/common_widgets.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import '../services/superbase_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabaseService = SupabaseService();
  Map<String, dynamic>? _userData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final data = await _supabaseService.getUser();
    setState(() { _userData = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _ProfileHeader(userData: _userData),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
                    child: Column(
                      children: [
                        _HealthCards(userData: _userData),
                        const SizedBox(height: 20),
                        const _SettingsGroup(
                          items: [
                            _SettingsItemData(iconEmoji: '🔔', iconBg: AppColors.redLight, title: 'Scan Reminders', subtitle: 'Every 7 days'),
                            _SettingsItemData(iconEmoji: '📤', iconBg: AppColors.greenLight, title: 'Export Data', subtitle: 'PDF or CSV report'),
                            _SettingsItemData(iconEmoji: '🏥', iconBg: Color(0xFFFEF5E4), title: 'Healthcare Provider', subtitle: 'Not connected'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const _SettingsGroup(
                          items: [
                            _SettingsItemData(iconEmoji: '🔒', iconBg: Color(0xFFF0EEFF), title: 'Privacy & Data', subtitle: 'Manage your data'),
                            _SettingsItemData(iconEmoji: 'ℹ️', iconBg: Color(0xFFE8F4FD), title: 'About AnemiaLens', subtitle: 'v1.0.0 · AI Model info'),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _LogoutButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppBottomNav(
            currentIndex: 3,
            onTap: (i) {
              switch (i) {
                case 0:
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (r) => false);
                  break;
                case 1:
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
                  break;
              }
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PROFILE HEADER
// ─────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final Map<String, dynamic>? userData;
  const _ProfileHeader({required this.userData});

  @override
  Widget build(BuildContext context) {
    final name = userData?['name'] ?? 'User';
    // rest of the widget stays the same, just replace profile.name with name
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
              bottom: -60, right: -40,
              child: Container(
                width: 200, height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [AppColors.accent.withOpacity(0.2), Colors.transparent],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withOpacity(0.15)),
                      ),
                      child: const Text('Edit Profile',
                          style: TextStyle(fontFamily: AppTextStyles.bodyFont, fontSize: 12, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: const LinearGradient(
                        colors: [AppColors.accent2, AppColors.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 8))],
                    ),
                    child: const Center(child: Icon(Icons.person_rounded, color: Colors.white, size: 36)),
                  ),
                  const SizedBox(height: 16),
                  Text(name,
                      style: const TextStyle(fontFamily: AppTextStyles.displayFont, fontSize: 26, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Member since Jan 2026',
                      style: TextStyle(fontFamily: AppTextStyles.bodyFont, fontSize: 13, color: Colors.white.withOpacity(0.5))),
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
// HEALTH CARDS
// ─────────────────────────────────────────────
class _HealthCards extends StatelessWidget {
  final Map<String, dynamic>? userData;
  const _HealthCards({required this.userData});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _HealthCard(icon: '🎂', value: '${userData?['age'] ?? '-'}', label: 'Age'),
        const SizedBox(width: 10),
        _HealthCard(icon: '⚖️', value: '${userData?['weight'] ?? '-'}kg', label: 'Weight'),
        const SizedBox(width: 10),
        _HealthCard(icon: '📊', value: '${userData?['scanCount'] ?? 0}', label: 'Scans'),
      ],
    );
  }
}

class _HealthCard extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  const _HealthCard({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        radius: AppRadius.cardSm,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            Text(value, style: AppTextStyles.title.copyWith(fontSize: 16)),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SETTINGS GROUP
// ─────────────────────────────────────────────
class _SettingsItemData {
  final String iconEmoji;
  final Color iconBg;
  final String title;
  final String subtitle;
  const _SettingsItemData({required this.iconEmoji, required this.iconBg, required this.title, required this.subtitle});
}

class _SettingsGroup extends StatelessWidget {
  final List<_SettingsItemData> items;
  const _SettingsGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadow.card,
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          return Column(
            children: [
              _SettingsItemTile(data: items[i]),
              if (i < items.length - 1)
                const Divider(color: AppColors.border, height: 1, indent: 70),
            ],
          );
        }),
      ),
    );
  }
}

class _SettingsItemTile extends StatelessWidget {
  final _SettingsItemData data;
  const _SettingsItemTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
  await AuthService().signOut();
  if (context.mounted) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (r) => false,
    );
  }
},
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: data.iconBg, borderRadius: BorderRadius.circular(10)),
              child: Center(child: Text(data.iconEmoji, style: const TextStyle(fontSize: 17))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(data.subtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.inkSoft, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// LOGOUT BUTTON
// ─────────────────────────────────────────────
class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
  await AuthService().signOut();
  if (context.mounted) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (r) => false,
    );
  }
},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.redLight,
          borderRadius: BorderRadius.circular(AppRadius.cardSm),
        ),
        child: const Center(
          child: Text('Sign Out',
              style: TextStyle(fontFamily: AppTextStyles.bodyFont, fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.accent)),
        ),
      ),
    );
  }
}

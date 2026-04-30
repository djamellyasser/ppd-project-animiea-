import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/scan_result.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../screens/image_preview_screen.dart';

// ─────────────────────────────────────────────
// STATUS BADGE
// ─────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final AnemiaStatus status;
  final bool large;

  const StatusBadge({super.key, required this.status, this.large = false});

  Color get _bg => status == AnemiaStatus.notAnemic ? AppColors.greenLight : AppColors.redLight;
  Color get _fg => status == AnemiaStatus.notAnemic ? AppColors.green : AppColors.red;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 14 : 8,
        vertical: large ? 6 : 3,
      ),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontFamily: AppTextStyles.bodyFont,
          fontSize: large ? 14 : 10,
          fontWeight: FontWeight.w700,
          color: _fg,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// APP CARD
// ─────────────────────────────────────────────
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double radius;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.radius = AppRadius.card,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            boxShadow: AppShadow.card,
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BOTTOM NAV BAR
// ─────────────────────────────────────────────
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(icon: Icons.home_rounded, label: 'Home', index: 0, current: currentIndex, onTap: onTap),
            _NavItem(icon: Icons.bar_chart_rounded, label: 'History', index: 1, current: currentIndex, onTap: onTap),
            _ScanButton(onTap: () => _showScanSheet(context)),
            _NavItem(icon: Icons.person_outline_rounded, label: 'Profile', index: 3, current: currentIndex, onTap: onTap),
          ],
        ),
      ),
    );
  }

  void _showScanSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ScanBottomSheet(),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int current;
  final Function(int) onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: active ? AppColors.accent : AppColors.inkSoft, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTextStyles.bodyFont,
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: active ? AppColors.accent : AppColors.inkSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ScanButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Transform.translate(
        offset: const Offset(0, -12),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppShadow.accent,
          ),
          child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SCAN BOTTOM SHEET
// ─────────────────────────────────────────────
class _ScanBottomSheet extends StatelessWidget {
  const _ScanBottomSheet();

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
  Navigator.pop(context);
  final navigator = Navigator.of(context);
  final picker = ImagePicker();
  final picked = await picker.pickImage(source: source, imageQuality: 90);
  if (picked != null) {
    navigator.push(
      MaterialPageRoute(
        builder: (_) => ImagePreviewScreen(image: File(picked.path)),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadow.card,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Text('New Scan', style: AppTextStyles.title),
          ),
          const Divider(color: AppColors.border, height: 1),
          _SheetOption(
            icon: Icons.photo_library_outlined,
            iconBg: const Color(0xFFE8F4FD),
            iconColor: const Color(0xFF2980B9),
            title: 'Device Images',
            subtitle: 'Choose a photo from your gallery',
            onTap: () => _pickImage(context, ImageSource.gallery),
          ),
          const Divider(color: AppColors.border, height: 1, indent: 70),
          _SheetOption(
            icon: Icons.camera_alt_outlined,
            iconBg: AppColors.accentLight,
            iconColor: AppColors.accent,
            title: 'Open Device Camera',
            subtitle: 'Take a photo with your camera',
            onTap: () => _pickImage(context, ImageSource.camera),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SheetOption({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.caption),
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
// SECTION TITLE
// ─────────────────────────────────────────────
class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(), style: AppTextStyles.label);
  }
}

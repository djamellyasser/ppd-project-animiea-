import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'camera_screen.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          const Expanded(
            child: Center(
              child: Text(
                'Tips — Coming Soon',
                style: AppTextStyles.title,
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
                case 2:
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CameraScreen()));
                  break;
                case 4:
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                  break;
              }
            },
          ),
        ],
      ),
    );
  }
}

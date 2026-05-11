import 'package:Constancy/presentation/screens/statistics_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import '../../generated/l10n.dart';
import '../providers/auth_provider.dart';
import 'search_screen.dart';
import '../providers/social_provider.dart';
import 'missions_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Widget> _screens = const [
    HomeScreen(),
    StatisticsScreen(),
    SearchScreen(),
    MissionsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<SocialProvider>().refreshSocialStats(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: IndexedStack(
        index: authProvider.currentTabIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: authProvider.currentTabIndex,
          onTap: (index) {
            authProvider.setTabIndex(index);
            if (authProvider.currentUser != null) {
              context.read<SocialProvider>().refreshSocialStats(authProvider.currentUser!.id);
            }
          },
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: Colors.grey.shade400,

          showSelectedLabels: false,
          showUnselectedLabels: false,

          type: BottomNavigationBarType.fixed,
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,

          iconSize: 28,

          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home_rounded),
              label: strings.navHome,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.calendar_month_outlined),
              activeIcon: const Icon(Icons.calendar_month_rounded),
              label: strings.navStats,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.hub_outlined),
              activeIcon: const Icon(Icons.hub_rounded),
              label: strings.navSearch,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.assignment_outlined),
              activeIcon: const Icon(Icons.assignment_rounded),
              label: strings.navMissions,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person_rounded),
              label: strings.navProfile,
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../home/screens/home_screen.dart';
import '../../profiles/screens/notifications_screen.dart';
import '../../profiles/screens/profile_screen.dart';
import '../../../generated/l10n.dart';
import '../../auth/data/repositories/auth_provider.dart';
import '../../search/screens/search_screen.dart';
import '../../profiles/data/repositories/social_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    NotificationsScreen(),
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
    final hasNotifications = context.watch<SocialProvider>().hasPendingRequests;

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
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          items: [
            BottomNavigationBarItem(
              icon: const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.home_outlined),
              ),
              activeIcon: const Icon(Icons.home_rounded),
              label: strings.navHome,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.search_outlined),
              activeIcon: const Icon(Icons.search_rounded),
              label: strings.navSearch,
            ),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_none_rounded),
                  if (hasNotifications)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.colorScheme.surface, width: 1.5),
                        ),
                        constraints: const BoxConstraints(minWidth: 10, minHeight: 10),
                      ),
                    ),
                ],
              ),
              activeIcon: const Icon(Icons.notifications_rounded),
              label: strings.navNotifications,
            ),
            BottomNavigationBarItem(
              icon: const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.person_outline),
              ),
              activeIcon: const Icon(Icons.person_rounded),
              label: strings.navProfile,
            ),
          ],
        ),
      ),
    );
  }
}
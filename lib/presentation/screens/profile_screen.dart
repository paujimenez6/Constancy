import '../providers/habit_provider.dart';
import 'settings_screen.dart';
import 'user_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../generated/l10n.dart';
import '../providers/auth_provider.dart';
import '../providers/social_provider.dart';
import 'edit_profile_screen.dart';
import 'profile_habits_list_screen.dart';

class ProfileScreen extends StatelessWidget {
  final bool isDirectTab;

  const ProfileScreen({
    super.key,
    this.isDirectTab = true,
  });

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);
    final user = context.watch<AuthProvider>().currentUser;
    final social = context.watch<SocialProvider>();
    final provider = context.watch<HabitProvider>();

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(strings.navProfile, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2), width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                      backgroundImage: (user.imatgePerfil != null && user.imatgePerfil!.isNotEmpty)
                          ? NetworkImage(user.imatgePerfil!)
                          : null,
                      child: (user.imatgePerfil == null || user.imatgePerfil!.isEmpty)
                          ? Text(
                        user.nickname.isNotEmpty ? user.nickname[0].toUpperCase() : '?',
                        style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary),
                      )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(user.nickname,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(user.correu, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 20),

                  Center(
                    child: SizedBox(
                      width: 280,
                      child: IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final list = await context.read<SocialProvider>().getFollowersList(user.id);
                                  if (context.mounted) {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                        UserListScreen(title: strings.followers, users: list, isMyFollowersList: true, ownerNickname: user.nickname)));
                                  }
                                },
                                child: _buildStatItem(social.followersCount.toString(), strings.followers),
                              ),
                            ),
                            VerticalDivider(
                              width: 1,
                              thickness: 1,
                              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final list = await context.read<SocialProvider>().getFollowingList(user.id);
                                  if (context.mounted) {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                        UserListScreen(title: strings.following, users: list, ownerNickname: user.nickname)));
                                  }
                                },
                                child: _buildStatItem(social.followingCount.toString(), strings.following),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Text(
                      strings.xpLevel(user.nivellXP),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(strings.homeTitle.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.primary, letterSpacing: 1.2)),
            ),
            const SizedBox(height: 12),
            buildHabitList(habits: provider.habits, isLoading: provider.isLoading, emptyMessage: strings.noHabits, strings: strings, theme: theme, context: context,),
            const SizedBox(height: 40),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                child: Text(
                  strings.settings.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),

            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  _buildProfileOption(
                    context: context,
                    icon: Icons.edit_outlined,
                    title: strings.editProfile,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  _buildProfileOption(
                    context: context,
                    icon: Icons.settings_outlined,
                    title: strings.settings,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),

            if (isDirectTab) ...[
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
                ),
                child: _buildProfileOption(
                  context: context,
                  icon: Icons.logout_rounded,
                  title: strings.logout,
                  isDestructive: true,
                  onTap: () => _confirmLogout(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildActionSheet(
        context: context,
        icon: Icons.logout_rounded,
        iconColor: theme.colorScheme.primary,
        title: strings.logout,
        description: strings.logoutConfirmMessage,
        confirmLabel: strings.logout,
        onConfirm: () async {
          await context.read<AuthProvider>().signOut();
          if (context.mounted) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Widget _buildActionSheet({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required String confirmLabel,
    required VoidCallback onConfirm,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final strings = S.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: theme.colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: iconColor),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 15),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(strings.cancel, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: isDestructive ? Colors.red : theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(confirmLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final Color color = isDestructive ? Colors.red : theme.colorScheme.onSurface;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 16),
      ),
      trailing: isDestructive
          ? null
          : Icon(Icons.chevron_right_rounded, size: 24, color: theme.colorScheme.outline),
      onTap: onTap,
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
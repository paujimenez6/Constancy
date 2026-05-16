import 'package:Constancy/presentation/screens/shop_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/achievement_model.dart';
import '../../generated/l10n.dart';
import '../../domain/models/league_model.dart';
import '../../domain/models/user_model.dart';
import '../providers/achievement_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/social_provider.dart';
import '../providers/habit_provider.dart';
import '../providers/league_provider.dart';
import 'edit_profile_screen.dart';
import 'profile_habits_list_screen.dart';
import 'settings_screen.dart';
import 'user_list_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool isDirectTab;

  const ProfileScreen({
    super.key,
    this.isDirectTab = true,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<AuthProvider>().initProfileListener(user.id);
        context.read<AchievementProvider>().loadUserAchievements(user.id);
      }
    });
  }

  IconData _getAchievementIcon(String iconName) {
    switch (iconName) {
      case 'edit_calendar': return Icons.edit_calendar;
      case 'check_circle_outline': return Icons.check_circle_outline;
      case 'whatshot': return Icons.whatshot;
      case 'groups': return Icons.groups;
      case 'person_add': return Icons.person_add;
      case 'assignment': return Icons.assignment;
      case 'storefront': return Icons.storefront;
      case 'backpack': return Icons.backpack;
      case 'military_tech': return Icons.military_tech;
      case 'diamond': return Icons.diamond;
      case 'face': return Icons.face;
      case 'phonelink_lock': return Icons.phonelink_lock;
      case 'bolt': return Icons.bolt;
      case 'savings': return Icons.savings;
      case 'auto_awesome': return Icons.auto_awesome;
      default: return Icons.star;
    }
  }

  void _navigateToUserList(String userId, String nickname, String title, bool isFollowers) async {
    if (_isNavigating) return;

    setState(() => _isNavigating = true);

    final socialProv = context.read<SocialProvider>();

    final List<Map<String, dynamic>> rawList = isFollowers
        ? await socialProv.getFollowersList(userId)
        : await socialProv.getFollowingList(userId);

    if (mounted) {
      final List<UserModel> list = rawList.map((m) {
        if (m.containsKey('profiles')) {
          return UserModel.fromJson(m['profiles']);
        }
        return UserModel.fromJson(m);
      }).toList();

      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => UserListScreen(
                  title: title,
                  users: list,
                  isMyFollowersList: isFollowers,
                  ownerNickname: nickname
              )
          )
      );
      if (mounted) setState(() => _isNavigating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);

    final user = context.watch<AuthProvider>().currentUser;
    final social = context.watch<SocialProvider>();
    final habitProv = context.watch<HabitProvider>();
    final leagueProv = context.watch<LeagueProvider>();

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
        actions: widget.isDirectTab ? [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(Icons.shopping_bag_outlined, color: theme.colorScheme.primary),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen()));
              },
            ),
          ),
        ] : null,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  _buildAvatar(user, theme),
                  const SizedBox(height: 16),

                  Text(user.nickname, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(user.correu, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 20),

                  if (leagueProv.currentLeague != null)
                    _buildLeagueBadge(theme, leagueProv.currentLeague!, strings),

                  const SizedBox(height: 12),

                  _buildBalanceRow(theme, user.puntsXP, user.monedes),

                  const SizedBox(height: 24),

                  _buildStatRow(user, social, strings, theme),
                ],
              ),
            ),
            const SizedBox(height: 40),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                  strings.homeTitle.toUpperCase(),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.colorScheme.primary, letterSpacing: 1.2)
              ),
            ),
            const SizedBox(height: 12),
            buildHabitList(
              habits: habitProv.habits,
              isLoading: habitProv.isLoading,
              emptyMessage: strings.noHabits,
              strings: strings,
              theme: theme,
              context: context,
            ),

            const SizedBox(height: 40),
            _buildSectionHeader(strings.achTitle.toUpperCase(), theme),
            const SizedBox(height: 16),
            _buildAchievementShowcase(context, user.id, isMe: true),
            const SizedBox(height: 5),

            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                child: Text(
                  strings.settings.toUpperCase(),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: theme.colorScheme.primary),
                ),
              ),
            ),

            _buildSettingsContainer(context, strings, theme),
            if (widget.isDirectTab) ...[
              const SizedBox(height: 24),
              _buildLogoutButton(context, strings, theme),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(UserModel user, ThemeData theme) {
    return Container(
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
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
        )
            : null,
      ),
    );
  }

  Widget _buildBalanceRow(ThemeData theme, int xp, int monedes) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.bolt_rounded, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 4),
              Text(
                "$xp XP",
                style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary, letterSpacing: 0.5, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.monetization_on_rounded, size: 18, color: Colors.amber),
              const SizedBox(width: 6),
              Text(
                "$monedes",
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeagueBadge(ThemeData theme, LeagueModel league, S strings) {
    final color = Color(int.parse(league.color.replaceFirst('#', '0xff')));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events_rounded, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            league.getLocalizedName(strings).toUpperCase(),
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(UserModel user, SocialProvider social, S strings, ThemeData theme) {
    return SizedBox(
      width: 280,
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _navigateToUserList(user.id, user.nickname, strings.followers, true),
                child: _buildStatItem(social.followersCount.toString(), strings.followers),
              ),
            ),
            VerticalDivider(width: 1, thickness: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
            Expanded(
              child: InkWell(
                onTap: () => _navigateToUserList(user.id, user.nickname, strings.following, false),
                child: _buildStatItem(social.followingCount.toString(), strings.following),
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildSettingsContainer(BuildContext context, S strings, ThemeData theme) {
    return Container(
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
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen())),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
          ),
          _buildProfileOption(
            context: context,
            icon: Icons.settings_outlined,
            title: strings.settings,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, S strings, ThemeData theme) {
    return Container(
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
    );
  }

  void _confirmLogout(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Icon(Icons.logout_rounded, size: 40, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(strings.logout, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(strings.logoutConfirmMessage, textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 15)),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(onPressed: () => Navigator.pop(context), child: Text(strings.cancel, style: const TextStyle(fontWeight: FontWeight.bold))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await context.read<AuthProvider>().signOut();
                      if (context.mounted) Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    child: Text(strings.logout, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
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
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 16)),
      trailing: isDestructive ? null : Icon(Icons.chevron_right_rounded, size: 24, color: theme.colorScheme.outline),
      onTap: onTap,
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
          title,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.colorScheme.primary, letterSpacing: 1.2)
      ),
    );
  }

  Widget _buildAchievementShowcase(BuildContext context, String userId, {required bool isMe}) {
    final prov = context.watch<AchievementProvider>();

    if (prov.isLoading && prov.achievements.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: prov.achievements.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final ach = prov.achievements[index];
          final color = ach.completat ? Theme.of(context).colorScheme.primary : Colors.grey;

          return GestureDetector(
            onTap: () => _showAchievementDetail(context, ach, isMe, userId),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
                  ),
                  child: Icon(_getAchievementIcon(ach.icona), color: color, size: 28),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 70,
                  child: Text(
                    ach.getNom(context),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAchievementDetail(BuildContext context, AchievementModel ach, bool isMe, String userId) {
    final strings = S.of(context);
    final theme = Theme.of(context);
    final color = ach.completat ? theme.colorScheme.primary : Colors.grey;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(_getAchievementIcon(ach.icona), color: color, size: 50),
            ),
            const SizedBox(height: 20),
            Text(ach.getNom(context), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(ach.getDescripcio(context), textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 16)),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${strings.progress}: ${ach.progresActual}/${ach.valorObjectiu}", style: const TextStyle(fontWeight: FontWeight.bold)),
                if (ach.completat) Text(ach.dataFormatada, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: ach.progresActual / ach.valorObjectiu,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: color,
              minHeight: 8,
              borderRadius: BorderRadius.circular(10),
            ),

            const SizedBox(height: 32),
            if (isMe && ach.completat && !ach.reclamat)
              ElevatedButton(
                onPressed: () async {
                  final xp = await context.read<AchievementProvider>().claimAchievementReward(ach.id, userId);
                  if (xp != null && context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${strings.rewardClaimed}: +$xp XP!")));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(strings.claimReward.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
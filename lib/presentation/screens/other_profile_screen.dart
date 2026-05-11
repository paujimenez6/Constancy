import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../generated/l10n.dart';
import '../providers/social_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/habit_provider.dart';
import 'user_list_screen.dart';
import 'profile_habits_list_screen.dart';
import '../providers/league_provider.dart';
import '../../domain/models/league_model.dart';

class OtherProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const OtherProfileScreen({super.key, required this.userData});

  @override
  State<OtherProfileScreen> createState() => _OtherProfileScreenState();
}

class _OtherProfileScreenState extends State<OtherProfileScreen> {
  bool _isFollowing = false;
  bool _isPending = false;
  bool _isLoadingStatus = true;
  bool _isNavigating = false;
  int _followersCount = 0;
  int _followingCount = 0;
  LeagueModel? _otherUserLeague;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final String userId = widget.userData['id'];
    await _loadFollowStatus();

    if (mounted) {
      final leagueProv = context.read<LeagueProvider>();
      final leagueData = await leagueProv.loadAnyUserLeague(userId);

      setState(() {
        _otherUserLeague = leagueData;
      });

      await context.read<HabitProvider>().loadProfileHabits(userId);
    }
  }

  Future<void> _loadFollowStatus() async {
    try {
      final socialProvider = context.read<SocialProvider>();
      final String userId = widget.userData['id'];

      final status = await socialProvider.getFollowStatus(userId);
      final stats = await socialProvider.getOtherUserStats(userId);

      if (mounted) {
        setState(() {
          _isFollowing = status['isFollowing']!;
          _isPending = status['isPending']!;
          _followersCount = stats.followersCount;
          _followingCount = stats.followingCount;
          _isLoadingStatus = false;
        });
      }
    } catch (e) {
      debugPrint("Error carregant dades d'usuari: $e");
      if (mounted) setState(() => _isLoadingStatus = false);
    }
  }

  void _showTopToast(String message) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 50,
        width: MediaQuery.of(context).size.width,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF323232).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))
                ],
              ),
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      if (overlayEntry.mounted) overlayEntry.remove();
    });
  }

  void _openUserList(bool isFollowers) async {
    if (_isNavigating) return;

    final strings = S.of(context);
    final privacitat = widget.userData['configuracio_privacitat'] ?? 'public';

    if (privacitat != 'public' && !_isFollowing) {
      _showTopToast(strings.privateInfoMessage);
      return;
    }

    setState(() => _isNavigating = true);

    final socialProvider = context.read<SocialProvider>();
    final list = isFollowers
        ? await socialProvider.getFollowersList(widget.userData['id'])
        : await socialProvider.getFollowingList(widget.userData['id']);

    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserListScreen(
            title: isFollowers ? strings.followers : strings.following,
            users: list,
            ownerNickname: widget.userData['nickname'],
          ),
        ),
      );
      if (mounted) setState(() => _isNavigating = false);
    }
  }

  void _handleFollowAction() async {
    final targetId = widget.userData['id'];
    final privacy = widget.userData['configuracio_privacitat'] ?? 'public';

    setState(() => _isLoadingStatus = true);

    try {
      final socialProvider = context.read<SocialProvider>();
      await socialProvider.toggleFollow(targetId, privacy);

      await _loadFollowStatus();

      if (mounted) {
        await context.read<HabitProvider>().loadProfileHabits(targetId);
      }

      final myId = context.read<AuthProvider>().currentUser!.id;
      socialProvider.refreshSocialStats(myId);
    } catch (e) {
      debugPrint("Error en acció social: $e");
    } finally {
      if (mounted) setState(() => _isLoadingStatus = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);
    final user = widget.userData;

    final int xpTotal = (user['punts_xp'] is int) ? user['punts_xp'] : 0;
    final int monedes = (user['monedes'] != null) ? int.parse(user['monedes'].toString()) : 0;

    final habitProvider = context.watch<HabitProvider>();
    final privacitat = user['configuracio_privacitat'] ?? 'public';
    bool canSeeDetails = privacitat == 'public' || _isFollowing;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(user['nickname'] ?? 'Usuari', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                  _buildAvatar(user, theme),
                  const SizedBox(height: 16),
                  Text("${user['nom'] ?? ''} ${user['cognom'] ?? ''}",
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  if (_otherUserLeague != null)
                    _buildLeagueBadge(theme, _otherUserLeague!, strings),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildXpDisplay(theme, xpTotal),
                      const SizedBox(width: 12),
                      _buildCoinsDisplay(theme, monedes),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _buildStatRow(strings, theme),

                  const SizedBox(height: 24),

                  _buildActionButtons(privacitat, theme, strings),
                ],
              ),
            ),

            const SizedBox(height: 40),

            if (!canSeeDetails)
              _buildPrivateMessage(theme, strings)
            else ...[
              _buildHabitsHeader(strings, theme, user['nickname'] ?? ''),
              const SizedBox(height: 12),

              buildHabitList(
                habits: habitProvider.profileHabits,
                isLoading: habitProvider.isLoading,
                emptyMessage: strings.noHabitsOther,
                strings: strings,
                theme: theme,
                context: context,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(Map<String, dynamic> user, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2), width: 3),
      ),
      child: CircleAvatar(
        radius: 55,
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
        backgroundImage: (user['imatge_perfil'] != null) ? NetworkImage(user['imatge_perfil']) : null,
        child: (user['imatge_perfil'] == null)
            ? Text(user['nickname'] != null ? user['nickname'][0].toUpperCase() : '?',
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: theme.colorScheme.primary))
            : null,
      ),
    );
  }

  Widget _buildXpDisplay(ThemeData theme, int xp) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt_rounded, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            "$xp XP",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
              letterSpacing: 0.5,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinsDisplay(ThemeData theme, int monedes) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.monetization_on_rounded, size: 18, color: Colors.amber),
          const SizedBox(width: 6),
          Text(
            "$monedes",
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 13),
          ),
        ],
      ),
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

  Widget _buildStatRow(S strings, ThemeData theme) {
    return Center(
      child: SizedBox(
        width: 280,
        child: IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: InkWell(onTap: () => _openUserList(true), child: _buildStatItem(_followersCount.toString(), strings.followers)),
              ),
              VerticalDivider(width: 1, thickness: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
              Expanded(
                child: InkWell(onTap: () => _openUserList(false), child: _buildStatItem(_followingCount.toString(), strings.following)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(String privacitat, ThemeData theme, S strings) {
    if (_isLoadingStatus) {
      return const SizedBox(height: 48, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    }

    String label;
    Color bgColor;
    Color textColor;
    IconData icon;

    if (_isFollowing) {
      label = strings.following;
      bgColor = theme.colorScheme.surfaceContainerHighest;
      textColor = theme.colorScheme.onSurface;
      icon = Icons.check_rounded;
    } else if (_isPending) {
      label = strings.requestPending;
      bgColor = theme.colorScheme.primary.withValues(alpha: 0.1);
      textColor = theme.colorScheme.primary;
      icon = Icons.timer_outlined;
    } else {
      label = privacitat == 'public' ? strings.follow : strings.sendRequest;
      bgColor = theme.colorScheme.primary;
      textColor = Colors.white;
      icon = privacitat == 'public' ? Icons.person_add_alt_1_rounded : Icons.lock_open_rounded;
    }

    return ElevatedButton.icon(
      onPressed: _handleFollowAction,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        minimumSize: const Size(220, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
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

  Widget _buildPrivateMessage(ThemeData theme, S strings) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Icon(Icons.lock_outline_rounded, size: 60, color: theme.colorScheme.outline),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
              strings.privateProfileMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 15, height: 1.4)
          ),
        ),
      ],
    );
  }

  Widget _buildHabitsHeader(S strings, ThemeData theme, String nickname) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
          strings.habitsTitleOther(nickname),
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
              letterSpacing: 1.2
          )
      ),
    );
  }
}
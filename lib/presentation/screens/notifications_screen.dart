import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../generated/l10n.dart';
import '../providers/auth_provider.dart';
import '../providers/social_provider.dart';
import 'other_profile_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _requests = [];
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  int _refreshCounter = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAll());
  }

  Future<void> _loadAll() async {
    try {
      final socialProvider = context.read<SocialProvider>();
      final reqs = await socialProvider.getPendingRequests();
      final notifs = await socialProvider.getFollowNotifications();

      if (mounted) {
        setState(() {
          _requests = reqs;
          _notifications = notifs;
          _isLoading = false;
          _refreshCounter++;
        });
        socialProvider.markNotificationsAsRead();
      }
    } catch (e) {
      debugPrint("Error carregant notificacions: $e");
    }
  }

  void _navigateToProfile(Map<String, dynamic> userData) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OtherProfileScreen(userData: userData)),
    ).then((_) {
      _loadAll();
      final myId = context.read<AuthProvider>().currentUser!.id;
      context.read<SocialProvider>().refreshSocialStats(myId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = S.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(strings.navNotifications, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_requests.isEmpty && _notifications.isEmpty)
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined, size: 40, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text(strings.noNotifications, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      )
          : ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          if (_requests.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 8.0, top: 4.0),
              child: Text(strings.followRequests.toUpperCase(), style: _sectionStyle(theme)),
            ),
            ..._requests.map((r) => _buildRequestCard(r, theme, strings)),
            const SizedBox(height: 8),
          ],
          if (_notifications.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 8.0, top: 8.0),
              child: Text(strings.recentActivity.toUpperCase(), style: _sectionStyle(theme)),
            ),
            ..._notifications.map((n) => _buildFollowNotification(n, theme, strings)),
          ],
        ],
      ),
    );
  }

  TextStyle _sectionStyle(ThemeData theme) => TextStyle(
    fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1, color: theme.colorScheme.primary,
  );

  Widget _buildRequestCard(Map<String, dynamic> req, ThemeData theme, S strings) {
    final sender = req['profiles'];
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () => _navigateToProfile(sender),
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: _buildAvatar(sender, theme),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sender['nickname'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(strings.wantsToFollow, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    onPressed: () async {
                      await context.read<SocialProvider>().acceptFollowRequest(req['id'], req['sender_id']);
                      if (mounted) {
                        _loadAll();
                        final myId = context.read<AuthProvider>().currentUser!.id;
                        context.read<SocialProvider>().refreshSocialStats(myId);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: Text(strings.accept, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: OutlinedButton(
                    onPressed: () async {
                      await context.read<SocialProvider>().rejectFollowRequest(req['id']);
                      if (mounted) {
                        _loadAll();
                        final myId = context.read<AuthProvider>().currentUser!.id;
                        context.read<SocialProvider>().refreshSocialStats(myId);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                    child: Text(strings.reject, style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFollowNotification(Map<String, dynamic> notif, ThemeData theme, S strings) {
    final sender = notif['profiles'];
    final date = DateTime.parse(notif['created_at']).toLocal();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: ListTile(
        onTap: () => _navigateToProfile(sender),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        dense: true,
        leading: _buildAvatar(sender, theme),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(sender['nickname'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text(strings.startedFollowingYou, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(DateFormat.MMMd().add_Hm().format(date), style: TextStyle(fontSize: 10, color: theme.colorScheme.outline)),
        ),
        trailing: FollowToggleButton(
          key: ValueKey("${sender['id']}_$_refreshCounter"),
          userData: sender,
        ),
      ),
    );
  }

  Widget _buildAvatar(dynamic user, ThemeData theme) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
      backgroundImage: user['imatge_perfil'] != null ? NetworkImage(user['imatge_perfil']) : null,
      child: user['imatge_perfil'] == null ? Text(user['nickname'][0].toUpperCase(), style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 14)) : null,
    );
  }
}

class FollowToggleButton extends StatefulWidget {
  final Map<String, dynamic> userData;
  const FollowToggleButton({super.key, required this.userData});

  @override
  State<FollowToggleButton> createState() => _FollowToggleButtonState();
}

class _FollowToggleButtonState extends State<FollowToggleButton> {
  bool _isFollowing = false;
  bool _isPending = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkStatus());
  }

  void _checkStatus() async {
    final provider = context.read<SocialProvider>();
    final status = await provider.getFollowStatus(widget.userData['id']);
    if (mounted) {
      setState(() {
        _isFollowing = status['isFollowing']!;
        _isPending = status['isPending']!;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);

    if (_loading) {
      return const SizedBox(width: 90, child: Center(child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))));
    }

    String text;
    if (_isFollowing) {
      text = strings.following;
    } else if (_isPending) {
      text = strings.requestPending;
    } else {
      text = strings.follow;
    }

    return TextButton(
      onPressed: () async {
        setState(() => _loading = true);
        final provider = context.read<SocialProvider>();
        final privacy = widget.userData['configuracio_privacitat'] ?? 'public';

        await provider.toggleFollow(widget.userData['id'], privacy);

        _checkStatus();
        final myId = context.read<AuthProvider>().currentUser!.id;
        provider.refreshSocialStats(myId);
      },
      style: TextButton.styleFrom(
        backgroundColor: _isFollowing ? theme.colorScheme.surfaceContainerHighest : theme.colorScheme.primary,
        foregroundColor: _isFollowing ? theme.colorScheme.onSurface : Colors.white,
        minimumSize: const Size(90, 30),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
    );
  }
}
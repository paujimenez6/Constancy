import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../generated/l10n.dart';
import '../providers/auth_provider.dart';
import '../providers/social_provider.dart';
import 'profile_screen.dart';
import 'other_profile_screen.dart';

class UserListScreen extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> users;
  final bool isMyFollowersList;
  final String ownerNickname;

  const UserListScreen({
    super.key,
    required this.title,
    required this.users,
    required this.ownerNickname,
    this.isMyFollowersList = false,
  });

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late List<Map<String, dynamic>> _currentUsers;

  @override
  void initState() {
    super.initState();
    _currentUsers = List.from(widget.users);
  }

  void _confirmRemoveFollower(Map<String, dynamic> user) {
    final strings = S.of(context);
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildActionSheet(
        context: context,
        icon: Icons.person_remove_rounded,
        iconColor: theme.colorScheme.primary,
        title: strings.removeFollower,
        description: "${strings.confirmRemoveFollower} ${user['nickname']}?",
        confirmLabel: strings.remove,
        isDestructive: true,
        onConfirm: () async {
          final socialProvider = context.read<SocialProvider>();
          await socialProvider.removeFollower(user['id']);

          if (mounted) {
            setState(() => _currentUsers.removeWhere((u) => u['id'] == user['id']));
            final myId = context.read<AuthProvider>().currentUser!.id;
            socialProvider.refreshSocialStats(myId);
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
      child: SingleChildScrollView(
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);
    final currentUserId = context.read<AuthProvider>().currentUser?.id;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${strings.listFor} ${widget.ownerNickname}",
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${_currentUsers.length} ${_currentUsers.length == 1 ? strings.totalCount1 : strings.totalCount2}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.people_outline_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _currentUsers.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group_outlined, size: 64, color: theme.colorScheme.outlineVariant),
                  const SizedBox(height: 16),
                  Text(
                    strings.noResultsFound,
                    style: TextStyle(color: theme.colorScheme.outline, fontSize: 16),
                  ),
                ],
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const BouncingScrollPhysics(),
              itemCount: _currentUsers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final user = _currentUsers[index];
                final bool isMe = user['id'] == currentUserId;

                return InkWell(
                  onTap: () {
                    if (isMe) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
                    } else {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => OtherProfileScreen(userData: user)));
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe
                          ? theme.colorScheme.primary.withValues(alpha: 0.03)
                          : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: isMe
                              ? theme.colorScheme.primary.withValues(alpha: 0.2)
                              : theme.colorScheme.outlineVariant.withValues(alpha: 0.5)
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                          backgroundImage: user['imatge_perfil'] != null ? NetworkImage(user['imatge_perfil']) : null,
                          child: user['imatge_perfil'] == null
                              ? Text(user['nickname'][0].toUpperCase(), style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold))
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(user['nickname'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  if (isMe) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        strings.me.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              Text("${user['nom']} ${user['cognom']}", style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14)),
                            ],
                          ),
                        ),
                        if (widget.isMyFollowersList && !isMe)
                          TextButton(
                            onPressed: () => _confirmRemoveFollower(user),
                            style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                            child: Text(strings.remove, style: const TextStyle(fontWeight: FontWeight.bold)),
                          )
                        else
                          Icon(Icons.chevron_right_rounded, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
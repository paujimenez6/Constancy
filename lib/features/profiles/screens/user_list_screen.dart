import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../generated/l10n.dart';
import '../../auth/data/repositories/auth_provider.dart';
import 'profile_screen.dart';
import 'other_profile_screen.dart';

class UserListScreen extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> users;

  const UserListScreen({super.key, required this.title, required this.users});

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);
    final currentUserId = context.read<AuthProvider>().currentUser?.id;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: users.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_outlined, size: 45, color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 16),
            Text(
              strings.noResultsFound,
              style: TextStyle(color: theme.colorScheme.outline, fontSize: 16),
            ),
          ],
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        itemCount: users.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final user = users[index];
          final bool isMe = user['id'] == currentUserId;

          return InkWell(
            onTap: () {
              if (isMe) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OtherProfileScreen(userData: user)),
                );
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
                      : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  // Avatar amb vora fina
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 26,
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                      backgroundImage: user['imatge_perfil'] != null
                          ? NetworkImage(user['imatge_perfil'])
                          : null,
                      child: user['imatge_perfil'] == null
                          ? Text(
                        user['nickname'][0].toUpperCase(),
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Informació de l'usuari
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              user['nickname'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
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
                        const SizedBox(height: 2),
                        Text(
                          "${user['nom']} ${user['cognom']}",
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
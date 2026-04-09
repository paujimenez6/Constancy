import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../generated/l10n.dart';
import '../../auth/data/repositories/auth_provider.dart';
import '../data/repositories/social_provider.dart';
import '../data/repositories/social_repository.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final SocialRepository _socialRepo = SocialRepository();
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    try {
      final data = await _socialRepo.getPendingRequests();
      if (mounted) setState(() { _requests = data; _isLoading = false; });
    } catch (e) {
      debugPrint("Error carregant notificacions: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = S.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(strings.navNotifications, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined, size: 45, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(strings.noNotifications, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _requests.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final req = _requests[index];
          final sender = req['profiles'];
          return _buildRequestCard(req['id'], req['sender_id'], sender, theme, strings);
        },
      ),
    );
  }

  Widget _buildRequestCard(String reqId, String senderId, dynamic sender, ThemeData theme, S strings) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: sender['imatge_perfil'] != null ? NetworkImage(sender['imatge_perfil']) : null,
                child: sender['imatge_perfil'] == null ? Text(sender['nickname'][0].toUpperCase()) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
                    children: [
                      TextSpan(text: sender['nickname'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: " ${strings.wantsToFollow}"),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await _socialRepo.acceptFollowRequest(reqId, senderId);
                    if (mounted) {
                      final userId = context.read<AuthProvider>().currentUser!.id;
                      context.read<SocialProvider>().refreshSocialStats(userId);
                      _loadRequests();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(strings.accept),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    await _socialRepo.rejectFollowRequest(reqId);
                    if (mounted) {
                      final userId = context.read<AuthProvider>().currentUser!.id;
                      context.read<SocialProvider>().refreshSocialStats(userId);
                      _loadRequests();
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(strings.reject),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
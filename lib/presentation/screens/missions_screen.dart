import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../generated/l10n.dart';
import '../providers/mission_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/social_provider.dart';
import 'notifications_screen.dart';
import 'package:confetti/confetti.dart';

class MissionsScreen extends StatefulWidget {
  const MissionsScreen({super.key});

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<MissionProvider>().initMissionsListener(user.id);
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);

    final missionProv = context.watch<MissionProvider>();
    final hasNotifications = context.watch<SocialProvider>().hasPendingRequests;
    final userId = context.read<AuthProvider>().currentUser?.id;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: theme.colorScheme.surface,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 130,
                pinned: true,
                elevation: 0,
                backgroundColor: theme.colorScheme.surface,
                surfaceTintColor: Colors.transparent,
                centerTitle: true,
                leading: const SizedBox.shrink(),
                title: Text(
                  strings.navMissions,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NotificationsScreen()),
                        );
                      },
                      icon: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(Icons.notifications_none_rounded,
                              color: theme.colorScheme.onSurface, size: 28),
                          if (hasNotifications)
                            Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                padding: const EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: theme.colorScheme.surface,
                                      width: 1.5),
                                ),
                                constraints: const BoxConstraints(
                                    minWidth: 12, minHeight: 12),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: theme.colorScheme.surface,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.assignment_turned_in_rounded,
                            color:
                            theme.colorScheme.primary.withValues(alpha: 0.9),
                            size: 45),
                        const SizedBox(height: 4),
                        Text(
                          strings.missionsSubtitle,
                          style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color:
                    theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                sliver: missionProv.isLoading
                    ? const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()))
                    : missionProv.missions.isEmpty
                    ? SliverFillRemaining(
                    child: _buildEmptyState(strings, theme))
                    : SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final mission = missionProv.missions[index];
                      return _MissionCard(
                        mission: mission,
                        onClaim: () async {
                          final success = await missionProv
                              .claimMission(mission, userId!);
                          if (success && mounted) {
                            _showRewardEffect(context, mission.definicio);
                          }
                        },
                      );
                    },
                    childCount: missionProv.missions.length,
                  ),
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.blue,
              Colors.red,
              Colors.orange,
              Colors.green
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(S strings, ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.emoji_events_outlined,
            size: 60, color: theme.colorScheme.outline),
        const SizedBox(height: 16),
        Text(strings.noMissions,
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }

  void _showRewardEffect(BuildContext context, dynamic missionDef) {
    final strings = S.of(context);
    final theme = Theme.of(context);

    _confettiController.play();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                      Icons.celebration,
                      size: 60,
                      color: theme.colorScheme.primary.withValues(alpha: 0.8)
                  ),
                  const SizedBox(height: 16),
                  Text(strings.missionRewardTitle,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(strings.missionRewardSubtitle,
                      textAlign: TextAlign.center,
                      style:
                      TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildRewardItem("${missionDef.recompensaXp} XP",
                          Icons.bolt_rounded, theme.colorScheme.primary),
                      const SizedBox(width: 20),
                      _buildRewardItem("${missionDef.recompensaMonedes}",
                          Icons.monetization_on_rounded, Colors.amber),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(strings.awesome),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRewardItem(String text, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 8),
        Text(text,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}

class _MissionCard extends StatelessWidget {
  final dynamic mission;
  final VoidCallback onClaim;

  const _MissionCard({required this.mission, required this.onClaim});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = S.of(context);
    final isDone = mission.completada;
    final isClaimed = mission.reclamada;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isClaimed
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDone && !isClaimed
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: isDone && !isClaimed ? 2 : 1,
        ),
        boxShadow: [
          if (!isClaimed)
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getIconColor(mission.definicio.tipus)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_getIcon(mission.definicio.tipus),
                    color: _getIconColor(mission.definicio.tipus)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getLocalizedTitle(mission.definicio.titolClau, strings),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      _getLocalizedDesc(mission.definicio.descripcioClau,
                          strings, mission.definicio.objectiu),
                      style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("+${mission.definicio.recompensaXp}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: theme.colorScheme.primary)),
                      const SizedBox(width: 4),
                      Icon(Icons.bolt_rounded,
                          size: 14, color: theme.colorScheme.primary),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("+${mission.definicio.recompensaMonedes}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.amber)),
                      const SizedBox(width: 4),
                      const Icon(Icons.monetization_on_rounded,
                          size: 14, color: Colors.amber),
                    ],
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: mission.percentatge,
                    minHeight: 8,
                    backgroundColor:
                    theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                strings.missionProgress(
                  mission.progresActual.toInt().toString(),
                  mission.definicio.objectiu.toInt().toString(),
                ),
                style:
                const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (isDone || isClaimed) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: (isDone && !isClaimed) ? onClaim : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isClaimed
                      ? theme.colorScheme.outlineVariant
                      : theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Text(
                  isClaimed ? strings.rewardClaimed : strings.claimReward,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getIcon(String tipus) {
    switch (tipus) {
      case 'habits': return Icons.task_alt_rounded;
      case 'social': return Icons.people_rounded;
      case 'xp': return Icons.bolt_rounded;
      case 'perfect_day': return Icons.local_fire_department;
      case 'league': return Icons.emoji_events_rounded;
      default: return Icons.star_rounded;
    }
  }

  Color _getIconColor(String tipus) {
    switch (tipus) {
      case 'habits': return Colors.green;
      case 'social': return Colors.blue;
      case 'xp': return Colors.orange;
      case 'perfect_day': return Colors.red;
      case 'league': return Colors.purpleAccent;
      default: return Colors.grey;
    }
  }

  String _getLocalizedTitle(String clau, S strings) {
    switch (clau) {
      case 'mission_habits_title': return strings.missionHabitsTitle;
      case 'mission_social_title': return strings.missionSocialTitle;
      case 'mission_xp_title': return strings.missionXpTitle;
      case 'mission_perfect_day_title': return strings.missionPerfectDayTitle;
      case 'mission_top_league_title': return strings.missionTopLeagueTitle;
      default: return clau;
    }
  }

  String _getLocalizedDesc(String clau, S strings, double goal) {
    final g = goal.toInt().toString();
    switch (clau) {
      case 'mission_habits_desc': return strings.missionHabitsDesc(g);
      case 'mission_social_desc': return strings.missionSocialDesc(g);
      case 'mission_xp_desc': return strings.missionXpDesc(g);
      case 'mission_perfect_day_desc': return strings.missionPerfectDayDesc;
      case 'mission_top_league_desc': return strings.missionTopLeagueDesc;
      default: return clau;
    }
  }
}
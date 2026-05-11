import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../generated/l10n.dart';
import '../providers/mission_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/social_provider.dart';
import '../providers/shop_provider.dart';
import 'notifications_screen.dart';
import 'package:confetti/confetti.dart';
import '../../domain/models/inventory_item_model.dart';

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
        context.read<ShopProvider>().loadShopAndInventory(user.id);
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _handleRerollAction(String userMissionId, String inventoryId) async {
    final strings = S.of(context);
    final theme = Theme.of(context);
    final user = context.read<AuthProvider>().currentUser;

    if (user == null) return;

    final bool? confirm = await showModalBottomSheet<bool>(
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
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Icon(Icons.refresh_rounded, size: 45, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(strings.rerollConfirmTitle, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              strings.rerollConfirmDesc,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 15),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(strings.cancel, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(strings.confirm, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (confirm == true) {
      await context.read<MissionProvider>().reroll(user.id, userMissionId, inventoryId);

      if (mounted) {
        await context.read<MissionProvider>().notifyAction(
            user.id,
            'inventory_use',
            'reroll_${userMissionId}_${DateTime.now().millisecondsSinceEpoch}'
        );
        await context.read<ShopProvider>().loadShopAndInventory(user.id);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(strings.rerollSuccess)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);

    final missionProv = context.watch<MissionProvider>();
    final shopProv = context.watch<ShopProvider>();
    final user = context.watch<AuthProvider>().currentUser;
    final userId = user?.id;

    final bool isMultiplierActive = user?.isMultiplierActive ?? false;
    final bool isCoinMagnetActive = user?.isCoinMagnetActive ?? false;

    final rerollItems = shopProv.inventory.where(
            (item) => item.definicio.tipusEfecte == 'mission_reroll'
    ).toList();

    final InventoryItemModel? rerollItem = rerollItems.isNotEmpty ? rerollItems.first : null;
    final int rerollCount = rerollItem?.quantitat ?? 0;

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
                  style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()));
                      },
                      icon: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(Icons.notifications_none_rounded, color: theme.colorScheme.onSurface, size: 28),
                          if (context.watch<SocialProvider>().hasPendingRequests)
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
                                constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
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
                        Icon(Icons.assignment_turned_in_rounded, color: theme.colorScheme.primary.withValues(alpha:0.9), size: 45),
                        const SizedBox(height: 4),
                        Text(
                          strings.missionsSubtitle,
                          style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w500),
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
                  child: Divider(height: 1, thickness: 1, color: theme.colorScheme.outlineVariant.withValues(alpha:0.5)),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                sliver: missionProv.isLoading
                    ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
                    : missionProv.missions.isEmpty
                    ? SliverFillRemaining(child: _buildEmptyState(strings, theme))
                    : SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final mission = missionProv.missions[index];
                      return _MissionCard(
                        mission: mission,
                        isMultiplierActive: isMultiplierActive,
                        isCoinMagnetActive: isCoinMagnetActive,
                        canReroll: rerollCount > 0 && !mission.reclamada,
                        onReroll: () => _handleRerollAction(mission.id, rerollItem!.id),
                        onClaim: () async {
                          final success = await missionProv.claimMission(mission, userId!, isMultiplierActive);
                          if (success && mounted) {
                            _showRewardEffect(context, mission.definicio, isMultiplierActive, isCoinMagnetActive);
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
            colors: const [Colors.blue, Colors.red, Colors.orange, Colors.green],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(S strings, ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.emoji_events_outlined, size: 60, color: theme.colorScheme.outline),
        const SizedBox(height: 16),
        Text(strings.noMissions, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }

  void _showRewardEffect(BuildContext context, dynamic missionDef, bool isXpActive, bool isCoinActive) {
    final strings = S.of(context);
    final theme = Theme.of(context);

    final int xpFinal = isXpActive ? (missionDef.recompensaXp * 2) : missionDef.recompensaXp;
    final int monedesFinals = isCoinActive ? (missionDef.recompensaMonedes * 2) : missionDef.recompensaMonedes;

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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.celebration, size: 60, color: theme.colorScheme.primary.withValues(alpha:0.8)),
                  const SizedBox(height: 16),
                  Text(strings.missionRewardTitle, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(strings.missionRewardSubtitle, textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildRewardBadge(
                        "$xpFinal XP ${isXpActive ? '(x2)' : ''}",
                        Icons.bolt_rounded,
                        isXpActive ? Colors.orange : theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 20),
                      _buildRewardBadge(
                        "$monedesFinals ${isCoinActive ? '(x2)' : ''}",
                        Icons.monetization_on_rounded,
                        isCoinActive ? Colors.amber[700]! : Colors.amber,
                      ),
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

  Widget _buildRewardBadge(String text, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withValues(alpha:0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 8),
        Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}

class _MissionCard extends StatelessWidget {
  final dynamic mission;
  final VoidCallback onClaim;
  final VoidCallback onReroll;
  final bool isMultiplierActive;
  final bool isCoinMagnetActive;
  final bool canReroll;

  const _MissionCard({
    required this.mission,
    required this.onClaim,
    required this.onReroll,
    required this.isMultiplierActive,
    required this.isCoinMagnetActive,
    required this.canReroll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = S.of(context);
    final bool isDone = mission.completada;
    final bool isClaimed = mission.reclamada;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isClaimed ? theme.colorScheme.surfaceContainerHighest.withValues(alpha:0.3) : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDone && !isClaimed ? theme.colorScheme.primary : theme.colorScheme.outlineVariant.withValues(alpha:0.5),
          width: isDone && !isClaimed ? 2 : 1,
        ),
        boxShadow: [if (!isClaimed) BoxShadow(color: Colors.black.withValues(alpha:0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getIconColor(mission.definicio.tipus).withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_getIcon(mission.definicio.tipus), color: _getIconColor(mission.definicio.tipus)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getLocalizedTitle(mission.definicio.titolClau, strings),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      _getLocalizedDesc(mission.definicio.descripcioClau, strings, mission.definicio.objectiu),
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              if (canReroll)
                IconButton(
                  onPressed: onReroll,
                  icon: const Icon(Icons.refresh_rounded, size: 22, color: Colors.blueGrey),
                  tooltip: strings.item_mission_reroll_title,
                ),
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
                    backgroundColor: theme.colorScheme.outlineVariant.withValues(alpha:0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                strings.missionProgress(mission.progresActual.toInt().toString(), mission.definicio.objectiu.toInt().toString()),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildSmallRewardBadge(
                "${isMultiplierActive ? mission.definicio.recompensaXp * 2 : mission.definicio.recompensaXp} XP",
                Icons.bolt_rounded,
                isMultiplierActive ? Colors.orange : theme.colorScheme.primary,
                isMultiplierActive,
              ),
              const SizedBox(width: 12),
              _buildSmallRewardBadge(
                "${isCoinMagnetActive ? mission.definicio.recompensaMonedes * 2 : mission.definicio.recompensaMonedes}",
                Icons.monetization_on_rounded,
                isCoinMagnetActive ? Colors.amber[700]! : Colors.amber,
                isCoinMagnetActive,
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
                  backgroundColor: isClaimed ? theme.colorScheme.outlineVariant : theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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

  Widget _buildSmallRewardBadge(String text, IconData icon, Color color, bool isActive) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
        const SizedBox(width: 2),
        if (isActive) Text("x2", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
        Icon(icon, size: 14, color: color),
      ],
    );
  }

  IconData _getIcon(String tipus) {
    switch (tipus) {
      case 'habits': return Icons.task_alt_rounded;
      case 'social': return Icons.people_rounded;
      case 'xp': return Icons.bolt_rounded;
      case 'perfect_day': return Icons.local_fire_department;
      case 'league': return Icons.emoji_events_rounded;
      case 'shop_buy': return Icons.shopping_cart;
      case 'inventory_use': return Icons.inventory_2_rounded;
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
      case 'shop_buy': return Colors.teal;
      case 'inventory_use': return Colors.indigo;
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
      case 'mission_shop_buy_title': return strings.mission_shop_buy_title;
      case 'mission_inventory_use_title': return strings.mission_inventory_use_title;
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
      case 'mission_shop_buy_desc': return strings.mission_shop_buy_desc;
      case 'mission_inventory_use_desc': return strings.mission_inventory_use_desc;
      default: return clau;
    }
  }
}
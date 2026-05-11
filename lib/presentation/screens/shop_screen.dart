import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../generated/l10n.dart';
import '../providers/shop_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/habit_provider.dart';
import '../../domain/models/shop_item_model.dart';
import '../../domain/models/inventory_item_model.dart';
import '../../domain/models/user_model.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  bool _isProcessing = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser?.id;
      if (userId != null) {
        context.read<ShopProvider>().loadShopAndInventory(userId);
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTimeLeft(DateTime fins) {
    final diff = fins.difference(DateTime.now());
    if (diff.isNegative) return "00:00:00";
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final h = twoDigits(diff.inHours);
    final m = twoDigits(diff.inMinutes.remainder(60));
    final s = twoDigits(diff.inSeconds.remainder(60));
    return "$h:$m:$s";
  }

  Future<void> _handlePurchaseAction(ShopItemModel item) async {
    final strings = S.of(context);
    final user = context.read<AuthProvider>().currentUser;
    final messenger = ScaffoldMessenger.of(context);

    if (user == null) return;

    final bool? confirm = await _showStyledConfirm(
      title: strings.buy,
      desc: "${strings.buy} ${_getLocalizedName(item.nomClau, strings)}?",
      icon: Icons.shopping_cart_outlined,
    );

    if (confirm == true) {
      setState(() => _isProcessing = true);
      try {
        await context.read<ShopProvider>().buyItem(item.id, user.id);
        if (mounted) {
          messenger.showSnackBar(SnackBar(content: Text(strings.purchaseSuccess)));
        }
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text(strings.errorTransaction)));
      } finally {
        if (mounted) setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _handleUseItemAction(InventoryItemModel invItem) async {
    final strings = S.of(context);
    final user = context.read<AuthProvider>().currentUser;
    final messenger = ScaffoldMessenger.of(context);

    if (user == null) return;

    final String effectType = invItem.definicio.tipusEfecte;

    if (effectType == 'streak_shield') {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now(),
        helpText: strings.shieldApplyTitle,
      );

      if (picked != null) {
        final habitProv = context.read<HabitProvider>();
        final alreadyShielded = await habitProv.isDateShielded(picked);

        if (alreadyShielded) {
          messenger.showSnackBar(SnackBar(content: Text(strings.shieldAlreadyActive)));
          return;
        }

        setState(() => _isProcessing = true);
        try {
          await habitProv.useStreakShield(user.id, picked, invItem.id);
          if (mounted) {
            await context.read<ShopProvider>().loadShopAndInventory(user.id);
            messenger.showSnackBar(SnackBar(content: Text(strings.shieldActivated)));
          }
        } catch (e) {
          messenger.showSnackBar(SnackBar(content: Text(strings.errorProcessingItem)));
        } finally {
          if (mounted) setState(() => _isProcessing = false);
        }
      }
    }
    else if (effectType == 'xp_multiplier') {
      if (user.isMultiplierActive) {
        messenger.showSnackBar(SnackBar(content: Text(strings.itemNotActive)));
        return;
      }

      final bool? confirm = await _showStyledConfirm(
        title: strings.multiplierConfirmTitle,
        desc: strings.multiplierConfirmDesc,
        icon: Icons.bolt_rounded,
      );

      if (confirm == true) {
        setState(() => _isProcessing = true);
        try {
          await context.read<ShopProvider>().activateXpMultiplier(user.id, invItem.id);
          if (mounted) {
            await context.read<ShopProvider>().loadShopAndInventory(user.id);
            messenger.showSnackBar(SnackBar(content: Text(strings.multiplierActive)));
          }
        } catch (e) {
          messenger.showSnackBar(SnackBar(content: Text(strings.errorProcessingItem)));
        } finally {
          if (mounted) setState(() => _isProcessing = false);
        }
      }
    }
    else if (effectType == 'coin_magnet') {
      if (user.isCoinMagnetActive) {
        messenger.showSnackBar(SnackBar(content: Text(strings.itemNotActive)));
        return;
      }

      final bool? confirm = await _showStyledConfirm(
        title: strings.coinMagnetConfirmTitle,
        desc: strings.coinMagnetConfirmDesc,
        icon: Icons.attach_money,
      );

      if (confirm == true) {
        setState(() => _isProcessing = true);
        try {
          await context.read<ShopProvider>().activateCoinMagnet(user.id, invItem.id);
          if (mounted) {
            await context.read<ShopProvider>().loadShopAndInventory(user.id);
            messenger.showSnackBar(SnackBar(content: Text(strings.coinMultiplierLabel)));
          }
        } catch (e) {
          messenger.showSnackBar(SnackBar(content: Text(strings.errorProcessingItem)));
        } finally {
          if (mounted) setState(() => _isProcessing = false);
        }
      }
    }
    else if (effectType == 'mission_reroll') {
      Navigator.pop(context);
      context.read<AuthProvider>().setTabIndex(3);
    }
  }

  Future<bool?> _showStyledConfirm({required String title, required String desc, required IconData icon}) {
    final theme = Theme.of(context);
    final strings = S.of(context);
    return showModalBottomSheet<bool>(
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
                  borderRadius: BorderRadius.circular(2)
              ),
            ),
            const SizedBox(height: 24),
            Icon(icon, size: 45, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(desc, textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 15)),
            const SizedBox(height: 32),
            Row(children: [
              Expanded(
                child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(strings.cancel, style: const TextStyle(fontWeight: FontWeight.bold))
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
                      elevation: 0
                  ),
                  child: Text(strings.confirm, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);
    final user = context.watch<AuthProvider>().currentUser;

    return DefaultTabController(
      length: 2,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: theme.colorScheme.surface,
            appBar: AppBar(
              title: Text(strings.navShop, style: const TextStyle(fontWeight: FontWeight.bold)),
              centerTitle: true,
              actions: [
                if (user != null) _buildCoinsBadge(user.monedes),
              ],
              bottom: TabBar(
                indicatorColor: theme.colorScheme.primary,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                tabs: [
                  Tab(text: strings.navShop.toUpperCase()),
                  Tab(text: strings.navInventory.toUpperCase()),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _ShopCatalogTab(onBuyItem: _handlePurchaseAction),
                _UserInventoryTab(onUseItem: _handleUseItemAction, user: user, timeLeftFormatter: _formatTimeLeft),
              ],
            ),
          ),

          if (_isProcessing)
            Container(
                color: Colors.black.withValues(alpha:0.4),
                child: const Center(child: CircularProgressIndicator())
            ),
        ],
      ),
    );
  }

  Widget _buildCoinsBadge(int monedes) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.withValues(alpha:0.2))
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.monetization_on_rounded, color: Colors.amber, size: 18),
            const SizedBox(width: 6),
            Text("$monedes", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14)),
          ]),
        ),
      ),
    );
  }
}

class _ShopCatalogTab extends StatelessWidget {
  final Function(ShopItemModel) onBuyItem;
  const _ShopCatalogTab({required this.onBuyItem});

  @override
  Widget build(BuildContext context) {
    final shopProv = context.watch<ShopProvider>();
    final user = context.watch<AuthProvider>().currentUser;
    final strings = S.of(context);
    final theme = Theme.of(context);

    if (shopProv.isLoading) return const Center(child: CircularProgressIndicator());

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: shopProv.shopItems.length,
      itemBuilder: (context, index) {
        final item = shopProv.shopItems[index];
        final canAfford = (user?.monedes ?? 0) >= item.preu;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha:0.1), borderRadius: BorderRadius.circular(15)),
                  child: Icon(_getIconData(item.icona), color: theme.colorScheme.primary, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_getLocalizedName(item.nomClau, strings), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(_getLocalizedDesc(item.descClau, strings), style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                ])),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: canAfford ? () => onBuyItem(item) : null,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: canAfford ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
                      foregroundColor: canAfford ? Colors.white : theme.colorScheme.outline,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0
                  ),
                  child: Row(children: [
                    Text("${item.preu}"),
                    const SizedBox(width: 4),
                    const Icon(Icons.monetization_on_rounded, size: 14)
                  ]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _UserInventoryTab extends StatelessWidget {
  final Function(InventoryItemModel) onUseItem;
  final UserModel? user;
  final String Function(DateTime) timeLeftFormatter;
  const _UserInventoryTab({required this.onUseItem, this.user, required this.timeLeftFormatter});

  @override
  Widget build(BuildContext context) {
    final shopProv = context.watch<ShopProvider>();
    final strings = S.of(context);
    final theme = Theme.of(context);

    if (shopProv.isLoading) return const Center(child: CircularProgressIndicator());

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (user != null && user!.isMultiplierActive)
          _buildPowerUpBadge(
            color: Colors.orange,
            icon: Icons.bolt_rounded,
            title: strings.multiplierActive.toUpperCase(),
            time: timeLeftFormatter(user!.multiplicadorXpFins!),
            strings: strings,
          ),

        if (user != null && user!.isCoinMagnetActive)
          _buildPowerUpBadge(
            color: Colors.amber[700]!,
            icon: Icons.attach_money,
            title: strings.coinMultiplierLabel.toUpperCase(),
            time: timeLeftFormatter(user!.imantMonedesFins!),
            strings: strings,
          ),

        if (shopProv.inventory.isEmpty)
          Center(child: Padding(padding: const EdgeInsets.only(top: 100), child: Text(strings.inventoryEmpty, style: TextStyle(color: theme.colorScheme.onSurfaceVariant))))
        else
          ...shopProv.inventory.map((invItem) {
            final String effect = invItem.definicio.tipusEfecte;
            final bool isXpActive = effect == 'xp_multiplier' && (user?.isMultiplierActive ?? false);
            final bool isCoinActive = effect == 'coin_magnet' && (user?.isCoinMagnetActive ?? false);
            final bool isActive = isXpActive || isCoinActive;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha:0.1), borderRadius: BorderRadius.circular(15)),
                    child: Icon(_getIconData(invItem.definicio.icona), color: theme.colorScheme.primary, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_getLocalizedName(invItem.definicio.nomClau, strings), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(strings.owned(invItem.quantitat), style: TextStyle(fontSize: 12, color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
                    Text(_getLocalizedDesc(invItem.definicio.descClau, strings), style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                  ])),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: (invItem.quantitat > 0 && !isActive) ? () => onUseItem(invItem) : null,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: isActive
                            ? (isXpActive ? Colors.orange : Colors.amber[700])
                            : theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0
                    ),
                    child: Text(isActive ? strings.itemInUse.toUpperCase() : strings.use.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ]),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildPowerUpBadge({required Color color, required IconData icon, required String title, required String time, required S strings}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color.withValues(alpha:0.7), color]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: color.withValues(alpha:0.3), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: Row(children: [
        Icon(icon, color: Colors.white, size: 30),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
          Text(strings.finishIn(time), style: const TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'monospace')),
        ])),
      ]),
    );
  }
}

IconData _getIconData(String iconName) {
  switch (iconName) {
    case 'shield_rounded': return Icons.shield_rounded;
    case 'bolt_rounded': return Icons.bolt_rounded;
    case 'magnet_rounded': return Icons.attach_money;
    case 'refresh_rounded': return Icons.refresh_rounded;
    default: return Icons.help_outline_rounded;
  }
}

String _getLocalizedName(String clau, S strings) {
  if (clau == 'item_streak_shield_title') return strings.item_streak_shield_title;
  if (clau == 'item_xp_multiplier_title') return strings.item_xp_multiplier_title;
  if (clau == 'item_coin_magnet_title') return strings.item_coin_magnet_title;
  if (clau == 'item_mission_reroll_title') return strings.item_mission_reroll_title;
  return clau;
}

String _getLocalizedDesc(String clau, S strings) {
  if (clau == 'item_streak_shield_desc') return strings.item_streak_shield_desc;
  if (clau == 'item_xp_multiplier_desc') return strings.item_xp_multiplier_desc;
  if (clau == 'item_coin_magnet_desc') return strings.item_coin_magnet_desc;
  if (clau == 'item_mission_reroll_desc') return strings.item_mission_reroll_desc;
  return clau;
}
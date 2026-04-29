import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../domain/models/habit_model.dart';
import '../providers/habit_provider.dart';
import '../../generated/l10n.dart';
import 'habit_form_screen.dart';

class HabitDetailScreen extends StatelessWidget {
  final String habitId;

  const HabitDetailScreen({super.key, required this.habitId});

  IconData _getIcona(String name) {
    final map = {
      'star': Icons.star_rounded,
      'fitness_center': Icons.fitness_center_rounded,
      'directions_run': Icons.directions_run_rounded,
      'directions_bike': Icons.directions_bike_rounded,
      'pool': Icons.pool_rounded,
      'self_improvement': Icons.self_improvement_rounded,
      'monitor_heart': Icons.monitor_heart_rounded,
      'water_drop': Icons.water_drop_rounded,
      'restaurant': Icons.restaurant_rounded,
      'apple': Icons.apple_rounded,
      'book': Icons.menu_book_rounded,
      'edit': Icons.edit_rounded,
      'lightbulb': Icons.lightbulb_rounded,
      'laptop': Icons.laptop_mac_rounded,
      'timer': Icons.timer_rounded,
      'language': Icons.language_rounded,
      'bedtime': Icons.bedtime_rounded,
      'psychology': Icons.psychology_rounded,
      'local_florist': Icons.local_florist_rounded,
      'pets': Icons.pets_rounded,
      'music_note': Icons.music_note_rounded,
      'brush': Icons.brush_rounded,
      'camera': Icons.camera_alt_rounded,
      'home': Icons.home_rounded,
      'cleaning_services': Icons.cleaning_services_rounded,
      'shopping_cart': Icons.shopping_cart_rounded,
      'attach_money': Icons.attach_money_rounded,
      'commute': Icons.directions_bus_rounded,
      'videogame_asset': Icons.videogame_asset_rounded,
      'smoke_free': Icons.smoke_free_rounded,
    };
    return map[name] ?? Icons.star_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider = context.watch<HabitProvider>();
    final theme = Theme.of(context);
    final strings = S.of(context);
    final dateFormat = DateFormat.yMMMMd(Intl.getCurrentLocale());

    final habit = habitProvider.habits.firstWhere(
          (h) => h.id == habitId,
      orElse: () => habitProvider.habits.first,
    );

    final record = habitProvider.dailyRecords[habit.id];
    final progresActual = record?.valorProgres ?? 0.0;
    final double valorObj = habit.valorObjectiu > 0 ? habit.valorObjectiu : 1.0;
    final percentatge = (progresActual / valorObj).clamp(0.0, 1.0);
    final habitColor = Color(int.parse(habit.color.replaceFirst('#', '0xff')));

    final dataIniciStr = dateFormat.format(habit.dataInici);
    final dataFiStr = habit.dataFi != null ? dateFormat.format(habit.dataFi!) : "/";
    final periodeText = "$dataIniciStr\n-\n$dataFiStr";

    return Scaffold(
      appBar: AppBar(
        title: Text(habit.titol, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (value) => _handleMenuAction(context, value, habit),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit_outlined, color: theme.colorScheme.primary),
                  title: Text(strings.editHabitTitle),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              PopupMenuItem(
                value: 'archive',
                child: ListTile(
                  leading: Icon(Icons.archive_outlined, color: theme.colorScheme.primary),
                  title: Text(strings.archive),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: Text(strings.remove, style: const TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              if (habit.descripcio != null && habit.descripcio!.isNotEmpty) ...[
                Text(
                  habit.descripcio!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (habit.grup != null && habit.grup!.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.category_outlined, size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        habit.grup!,
                        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_month_outlined, size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        periodeText,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.2),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: CircularProgressIndicator(
                        value: percentatge,
                        strokeWidth: 10,
                        backgroundColor: habitColor.withValues(alpha: 0.1),
                        color: habitColor,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Positioned(
                      left: 25,
                      child: _CircleActionButton(
                        icon: Icons.remove_rounded,
                        color: habitColor,
                        onPressed: () {
                          double nouVal = (progresActual - 1).clamp(0.0, double.infinity);
                          habitProvider.updateProgress(
                            habitId: habit.id,
                            valorProgres: nouVal,
                            completat: nouVal >= habit.valorObjectiu,
                          );
                        },
                      ),
                    ),
                    Positioned(
                      right: 25,
                      child: _CircleActionButton(
                        icon: Icons.add_rounded,
                        color: habitColor,
                        onPressed: () {
                          double nouVal = progresActual + 1;
                          habitProvider.updateProgress(
                            habitId: habit.id,
                            valorProgres: nouVal,
                            completat: nouVal >= habit.valorObjectiu,
                          );
                        },
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getIcona(habit.icona), color: habitColor, size: 45),
                        const SizedBox(height: 4),
                        Text("${(percentatge * 100).toInt()}%", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(
                          "${progresActual % 1 == 0 ? progresActual.toInt() : progresActual} / ${habit.valorObjectiu % 1 == 0 ? habit.valorObjectiu.toInt() : habit.valorObjectiu}",
                          style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        Text(habit.unitatMesura.getLocalizedString(context), style: TextStyle(color: theme.colorScheme.outline, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showAddProgressSheet(context, habit),
                    icon: const Icon(Icons.add),
                    label: Text(strings.addProgress, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(180, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 56, width: 56,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                    ),
                    child: IconButton(
                      onPressed: () => _showCommentSheet(context, habit),
                      icon: Icon(Icons.edit_note_rounded, color: theme.colorScheme.primary, size: 30),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  void _showCommentSheet(BuildContext context, HabitModel habit) {
    final strings = S.of(context);
    final theme = Theme.of(context);

    bool isEditing = false;
    final TextEditingController commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
          builder: (context, setModalState) {
            final habitProvider = context.watch<HabitProvider>();
            final record = habitProvider.dailyRecords[habit.id];
            final currentComment = record?.comentari ?? "";

            if (currentComment.isEmpty && !isEditing) {
              isEditing = true;
            }

            if (isEditing && commentController.text.isEmpty) {
              commentController.text = currentComment;
            }

            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                        const SizedBox(height: 24),
                        Text(strings.todayComment, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),

                        if (!isEditing && currentComment.isNotEmpty) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    currentComment,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.edit_outlined, color: theme.colorScheme.primary, size: 22),
                                  onPressed: () => setModalState(() => isEditing = true),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                                  onPressed: () async {
                                    await habitProvider.updateComment(habitId: habit.id, comentari: null);
                                    setModalState(() => isEditing = true);
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          TextField(
                            controller: commentController,
                            autofocus: true,
                            maxLines: 3,
                            maxLength: 150,
                            decoration: InputDecoration(
                              hintText: strings.commentHint,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: theme.colorScheme.primary.withValues(alpha: 0.05),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () async {
                              await habitProvider.updateComment(
                                habitId: habit.id,
                                comentari: commentController.text.trim(),
                              );
                              if (context.mounted) Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 56),
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Text(strings.confirm, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
      ),
    );
  }

  void _showAddProgressSheet(BuildContext context, HabitModel habit) {
    final controller = TextEditingController();
    final strings = S.of(context);
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 24),
                  Text(strings.enterValue, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                    decoration: InputDecoration(
                      hintText: "0",
                      suffix: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(habit.unitatMesura.getLocalizedString(context), style: TextStyle(fontSize: 16, color: theme.colorScheme.outline)),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: theme.colorScheme.primary.withValues(alpha: 0.05),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      final valor = double.tryParse(controller.text) ?? 0.0;
                      context.read<HabitProvider>().updateProgress(
                        habitId: habit.id,
                        valorProgres: valor,
                        completat: valor >= habit.valorObjectiu,
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(strings.confirm, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action, HabitModel currentHabit) {
    final strings = S.of(context);
    final provider = context.read<HabitProvider>();
    if (action == 'edit') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => HabitFormScreen(habitToEdit: currentHabit)));
    } else if (action == 'archive') {
      _showConfirmDialog(context, title: strings.archiveHabitConfirm, message: strings.archiveHabitMessage, onConfirm: () async => await provider.archiveHabit(currentHabit.id, true));
    } else if (action == 'delete') {
      _showConfirmDialog(context, title: strings.deleteHabitConfirm, message: strings.deleteHabitMessage, isDestructive: true, onConfirm: () async => await provider.deleteHabit(currentHabit.id));
    }
  }

  void _showConfirmDialog(BuildContext context, {required String title, required String message, required Future<void> Function() onConfirm, bool isDestructive = false}) {
    final strings = S.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(strings.cancel)),
          ElevatedButton(
            onPressed: () async {
              await onConfirm();
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: isDestructive ? Colors.red : Theme.of(context).colorScheme.primary, foregroundColor: Colors.white, elevation: 0),
            child: Text(isDestructive ? strings.remove : strings.confirm),
          ),
        ],
      ),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  const _CircleActionButton({required this.icon, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
      child: IconButton(icon: Icon(icon, color: color, size: 20), onPressed: onPressed, padding: EdgeInsets.zero),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/habit_model.dart';
import '../../generated/l10n.dart';
import '../providers/habit_provider.dart';
import 'habit_form_screen.dart';

class ArchivedHabitsScreen extends StatelessWidget {
  const ArchivedHabitsScreen({super.key});

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
    final strings = S.of(context);
    final theme = Theme.of(context);

    final archivedHabits = habitProvider.habits.where((h) => h.arxivat).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.archivedHabits, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: archivedHabits.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.archive_outlined, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text(strings.noArchivedHabits, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: archivedHabits.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final habit = archivedHabits[index];
          final color = Color(int.parse(habit.color.replaceFirst('#', '0xff')));

          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(_getIcona(habit.icona), color: color),
              ),
              title: Text(habit.titol, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Text(
                habit.periodeObjectiu.getLocalizedString(context).toUpperCase(),
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
              ),
              trailing: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onSelected: (value) async {
                  if (value == 'unarchive') {
                    await habitProvider.archiveHabit(habit.id, false);
                  } else if (value == 'edit') {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => HabitFormScreen(habitToEdit: habit),
                    ));
                  } else if (value == 'delete') {
                    _confirmDelete(context, habitProvider, habit.id, strings);
                  }
                },
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
                    value: 'unarchive',
                    child: ListTile(
                      leading: Icon(Icons.unarchive_outlined, color: theme.colorScheme.primary),
                      title: Text(strings.unarchive),
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
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, HabitProvider provider, String id, S strings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
            strings.deleteHabitConfirm,
            style: const TextStyle(fontWeight: FontWeight.bold)
        ),
        content: Text(strings.deleteHabitMessage),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(strings.cancel)
          ),
          ElevatedButton(
            onPressed: () async {
              await provider.deleteHabit(id);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(strings.remove),
          ),
        ],
      ),
    );
  }
}
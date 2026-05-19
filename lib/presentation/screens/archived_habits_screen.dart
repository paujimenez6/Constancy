import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/habit_model.dart';
import '../../domain/models/habit_assets.dart';
import '../../generated/l10n.dart';
import '../providers/habit_provider.dart';
import '../providers/auth_provider.dart';
import 'habit_form_screen.dart';

class ArchivedHabitsScreen extends StatelessWidget {
  const ArchivedHabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habitProvider = context.watch<HabitProvider>();
    final authProvider = context.watch<AuthProvider>();
    final strings = S.of(context);
    final theme = Theme.of(context);

    final archivedHabits = habitProvider.archivedHabits;
    final currentUserId = authProvider.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.archivedHabits,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: archivedHabits.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.archive_outlined,
                size: 64,
                color: theme.colorScheme.primary
                    .withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text(strings.noArchivedHabits,
                style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: archivedHabits.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final habit = archivedHabits[index];
          final color = HabitAssets.hexToColor(habit.color);

          final bool isAdmin = !habit.isGroup || habit.userId == currentUserId;

          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                  color: theme.colorScheme.outlineVariant
                      .withValues(alpha: 0.5)),
            ),
            child: ListTile(
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(HabitAssets.getIconByName(habit.icona),
                    color: color),
              ),
              title: Row(
                children: [
                  if (habit.isGroup)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(Icons.groups_rounded,
                          size: 20, color: theme.colorScheme.primary),
                    ),
                  Expanded(
                    child: Text(
                      habit.titol,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                habit.periodeObjectiu
                    .getLocalizedString(context)
                    .toUpperCase(),
                style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 12),
              ),
              trailing: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                onSelected: (value) async {
                  if (value == 'unarchive') {
                    await habitProvider.archiveHabit(habit.id, false);
                  } else if (value == 'edit') {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              HabitFormScreen(habitToEdit: habit),
                        ));
                  } else if (value == 'delete') {
                    _confirmDelete(
                        context, habitProvider, habit.id, strings);
                  } else if (value == 'leave') {
                    _confirmLeave(
                        context, habitProvider, habit.id, strings);
                  }
                },
                itemBuilder: (context) {
                  if (isAdmin) {
                    return [
                      PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit_outlined,
                              color: theme.colorScheme.primary),
                          title: Text(strings.editHabitTitle),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'unarchive',
                        child: ListTile(
                          leading: Icon(Icons.unarchive_outlined,
                              color: theme.colorScheme.primary),
                          title: Text(strings.unarchive),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          title: Text(strings.remove,
                              style: const TextStyle(color: Colors.red)),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ),
                    ];
                  } else {
                    return [
                      PopupMenuItem(
                        value: 'leave',
                        child: ListTile(
                          leading: const Icon(Icons.logout_rounded,
                              color: Colors.orange),
                          title: Text(strings.leaveAction,
                              style:
                              const TextStyle(color: Colors.orange)),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ),
                    ];
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, HabitProvider provider, String id, S strings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(strings.deleteHabitConfirm,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(strings.deleteHabitMessage),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(strings.cancel)),
          ElevatedButton(
            onPressed: () async {
              await provider.deleteHabit(id);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(strings.remove),
          ),
        ],
      ),
    );
  }

  void _confirmLeave(
      BuildContext context, HabitProvider provider, String id, S strings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(strings.leaveHabitConfirm,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(strings.leaveHabitMessage),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(strings.cancel)),
          ElevatedButton(
            onPressed: () async {
              await provider.leaveGroup(id);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(strings.leaveAction),
          ),
        ],
      ),
    );
  }
}
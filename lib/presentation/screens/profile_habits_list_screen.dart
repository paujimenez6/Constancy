import 'package:flutter/material.dart';
import '../../domain/models/habit_assets.dart';
import '../../domain/models/habit_model.dart';
import '../../generated/l10n.dart';

Widget buildHabitList({
  required List<HabitModel> habits,
  required bool isLoading,
  required String emptyMessage,
  required S strings,
  required ThemeData theme,
  required BuildContext context,
}) {
  if (isLoading) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: CircularProgressIndicator(),
      ),
    );
  }

  if (habits.isEmpty) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Column(
          children: [
            Icon(Icons.format_list_bulleted_rounded,
                size: 40, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text(
              emptyMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.outline, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  return ListView.separated(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: habits.length,
    separatorBuilder: (context, index) => const SizedBox(height: 12),
    itemBuilder: (context, index) {
      final h = habits[index];
      final bool isArchived = h.arxivat;
      final color = HabitAssets.hexToColor(h.color);
      final unitatStr = h.unitatMesura.getLocalizedString(context);

      return Opacity(
        opacity: isArchived ? 0.6 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: isArchived
                    ? theme.colorScheme.outlineVariant.withValues(alpha: 0.3)
                    : theme.colorScheme.outlineVariant.withValues(alpha: 0.5)
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        shape: BoxShape.circle
                    ),
                    child: Icon(
                        HabitAssets.getIconByName(h.icona),
                        color: color,
                        size: 24
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                  h.titol,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    fontStyle: isArchived ? FontStyle.italic : FontStyle.normal,
                                    decoration: isArchived ? TextDecoration.none : null,
                                  )
                              ),
                            ),
                            if (isArchived) ...[
                              const SizedBox(width: 8),
                              Icon(
                                  Icons.archive_outlined,
                                  size: 16,
                                  color: theme.colorScheme.outline
                              ),
                            ],
                          ],
                        ),
                        Text(
                          "${h.valorObjectiu % 1 == 0 ? h.valorObjectiu.toInt() : h.valorObjectiu} $unitatStr / ${h.periodeObjectiu.getLocalizedString(context).toLowerCase()}",
                          style: TextStyle(
                              color: isArchived ? theme.colorScheme.outline : theme.colorScheme.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (h.descripcio != null && h.descripcio!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                    h.descripcio!,
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 14,
                      fontStyle: isArchived ? FontStyle.italic : FontStyle.normal,
                    )
                ),
              ],

              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStreakInfo(
                      context,
                      strings.currentStreakLabel,
                      h.ratxaActual.toString(),
                      Icons.local_fire_department_rounded,
                      isArchived ? Colors.grey : Colors.orange,
                      theme
                  ),
                  _buildStreakInfo(
                      context,
                      strings.bestStreakLabel,
                      h.millorRatxa.toString(),
                      Icons.emoji_events_rounded,
                      isArchived ? Colors.grey : Colors.amber,
                      theme
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildStreakInfo(BuildContext context, String label, String value, IconData icon, Color color, ThemeData theme) {
  return Row(
    children: [
      Icon(icon, color: color, size: 18),
      const SizedBox(width: 6),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text(label.toUpperCase(), style: TextStyle(fontSize: 9, color: theme.colorScheme.outline, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ],
      ),
    ],
  );
}
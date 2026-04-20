import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../generated/l10n.dart';
import '../providers/auth_provider.dart';
import '../providers/habit_provider.dart';
import 'habit_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitProvider>().loadDataForDate(DateTime.now());
    });
  }

  Color _hexToColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xff')));
  }

  IconData _getIcona(String name) {
    final map = {
      'star': Icons.star_rounded,
      'fitness_center': Icons.fitness_center_rounded,
      'water_drop': Icons.water_drop_rounded,
      'book': Icons.menu_book_rounded,
      'directions_run': Icons.directions_run_rounded,
      'self_improvement': Icons.self_improvement_rounded,
      'bedtime': Icons.bedtime_rounded,
      'restaurant': Icons.restaurant_rounded,
      'monitor_heart': Icons.monitor_heart_rounded,
      'lightbulb': Icons.lightbulb_rounded,
    };
    return map[name] ?? Icons.star_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final user = context.watch<AuthProvider>().currentUser;
    final habitProvider = context.watch<HabitProvider>();

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final dataAvuiFormatada = DateFormat.yMMMMd(Intl.getCurrentLocale()).format(habitProvider.selectedDate);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset('assets/images/Logo_Constancy.png', width: 45, height: 45),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.welcomeUser(user.nickname), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(dataAvuiFormatada, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
      body: habitProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : habitProvider.habits.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, size: 64, color: colorScheme.primary.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              strings.noHabits,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        itemCount: habitProvider.habits.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final habit = habitProvider.habits[index];
          final record = habitProvider.dailyRecords[habit.id];

          final color = _hexToColor(habit.color);
          final progresActual = record?.valorProgres ?? 0.0;
          final estaCompletat = progresActual >= habit.valorObjectiu;

          return InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => HabitFormScreen(habitToEdit: habit)
              ));
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: estaCompletat ? color.withValues(alpha: 0.1) : colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: estaCompletat ? color : colorScheme.outlineVariant.withValues(alpha: 0.5),
                  width: estaCompletat ? 2 : 1,
                ),
                boxShadow: estaCompletat ? [] : [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_getIcona(habit.icona), color: color, size: 28),
                  ),
                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.titol,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            decoration: estaCompletat ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${progresActual == progresActual.toInt() ? progresActual.toInt() : progresActual} / ${habit.valorObjectiu == habit.valorObjectiu.toInt() ? habit.valorObjectiu.toInt() : habit.valorObjectiu} ${habit.unitatMesura.name}",
                          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed: () async {
                      double nouProgres = estaCompletat ? 0 : (progresActual + 1);
                      if (nouProgres > habit.valorObjectiu) nouProgres = habit.valorObjectiu;

                      await context.read<HabitProvider>().updateProgress(
                        habitId: habit.id,
                        valorProgres: nouProgres,
                        completat: nouProgres >= habit.valorObjectiu,
                      );
                    },
                    icon: Icon(
                      estaCompletat ? Icons.check_circle_rounded : Icons.circle_outlined,
                      color: estaCompletat ? color : colorScheme.outline,
                      size: 32,
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => const HabitFormScreen()
          ));
        },
        label: Text(strings.addHabit),
        icon: const Icon(Icons.add),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );
  }
}
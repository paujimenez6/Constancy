import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/habit_provider.dart';
import '../../domain/models/habit_record_model.dart';
import '../../domain/models/habit_model.dart';
import '../../generated/l10n.dart';
import 'habit_form_screen.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

enum StatsView { mensual, global }

class _StatisticsScreenState extends State<StatisticsScreen> {
  DateTime _currentMonth = DateTime.now();
  List<HabitRecordModel> _prevMonthRecords = [];
  bool _isComparing = false;
  StatsView _currentView = StatsView.mensual;
  HabitModel? _selectedHabit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() async {
    final provider = context.read<HabitProvider>();
    await provider.loadMonthlyData(_currentMonth);
    await provider.loadAllTimeData();

    setState(() => _isComparing = true);
    final prevMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    final startOfPrev = DateTime(prevMonth.year, prevMonth.month, 1);
    final endOfPrev = DateTime(prevMonth.year, prevMonth.month + 1, 0);

    final records = await provider.getRecordsForRange(startOfPrev, endOfPrev);

    setState(() {
      _prevMonthRecords = records;
      _isComparing = false;
    });
  }

  void _changeMonth(int increment) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + increment, 1);
    });
    _loadData();
  }

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
    final provider = context.watch<HabitProvider>();
    final strings = S.of(context);
    final theme = Theme.of(context);

    if (_selectedHabit != null) {
      _selectedHabit = provider.habits.cast<HabitModel?>().firstWhere(
            (h) => h?.id == _selectedHabit!.id,
        orElse: () => null,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.navStats, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildHabitSelector(provider, strings, theme),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => _changeMonth(-1)),
                Text(
                  DateFormat.yMMMM(Intl.getCurrentLocale()).format(_currentMonth).toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => _changeMonth(1)),
              ],
            ),
            const SizedBox(height: 10),
            _buildCalendarGrid(provider, strings, theme),
            const SizedBox(height: 20),
            SegmentedButton<StatsView>(
              segments: [
                ButtonSegment(value: StatsView.mensual, label: Text(strings.monthlyLabel), icon: const Icon(Icons.calendar_view_month)),
                ButtonSegment(value: StatsView.global, label: Text(strings.globalLabel), icon: const Icon(Icons.public)),
              ],
              selected: {_currentView},
              onSelectionChanged: (Set<StatsView> newSelection) {
                setState(() {
                  _currentView = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            _buildAdvancedStats(provider, strings, theme),
            if (_selectedHabit != null) ...[
              const SizedBox(height: 30),
              _buildCommentsSection(provider, strings, theme),
              const SizedBox(height: 40),
              _buildHabitActions(provider, strings, theme),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitSelector(HabitProvider provider, S strings, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha:0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha:0.5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<HabitModel?>(
          value: _selectedHabit,
          isExpanded: true,
          icon: const Icon(Icons.filter_list_rounded),
          items: [
            DropdownMenuItem<HabitModel?>(
              value: null,
              child: Row(
                children: [
                  const Icon(Icons.public, size: 20),
                  const SizedBox(width: 10),
                  Text(strings.statsAllHabits, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            ...provider.habits.map((h) => DropdownMenuItem<HabitModel?>(
              value: h,
              child: Row(
                children: [
                  Icon(_getIcona(h.icona), size: 20, color: Color(int.parse(h.color.replaceFirst('#', '0xff')))),
                  const SizedBox(width: 10),
                  Expanded(child: Text(h.titol)),
                  if (h.arxivat) const Icon(Icons.archive_outlined, size: 18, color: Colors.grey),
                ],
              ),
            )),
          ],
          onChanged: (HabitModel? newValue) {
            setState(() {
              _selectedHabit = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(HabitProvider provider, S strings, ThemeData theme) {
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final offset = firstDayOfMonth.weekday - 1;

    final DateTime baseDate = DateTime(2024, 1, 1);
    final List<String> localizedWeekDays = List.generate(7, (index) {
      return DateFormat.E(Intl.getCurrentLocale()).format(baseDate.add(Duration(days: index)));
    });

    final Color primaryProgressColor = _selectedHabit != null
        ? Color(int.parse(_selectedHabit!.color.replaceFirst('#', '0xff')))
        : theme.colorScheme.primary;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: localizedWeekDays.map((d) => Expanded(
            child: Center(
              child: Text(
                d.toUpperCase().replaceAll('.', ''),
                style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant, fontSize: 11),
              ),
            ),
          )).toList(),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemCount: daysInMonth + offset,
          itemBuilder: (context, index) {
            if (index < offset) return const SizedBox.shrink();

            final day = index - offset + 1;
            final date = DateTime(_currentMonth.year, _currentMonth.month, day);

            var expected = provider.getExpectedHabitsForDate(date);
            double progress = 0.0;

            if (_selectedHabit == null) {
              final completedRecords = provider.monthlyRecords.where((r) =>
              r.dataRegistre.day == day &&
                  r.dataRegistre.month == _currentMonth.month &&
                  r.completat
              ).toList();

              progress = expected.isEmpty ? 0.0 : completedRecords.length / expected.length;
            } else {
              bool isExpectedToday = expected.any((h) => h.id == _selectedHabit!.id);

              if (isExpectedToday) {
                final record = provider.monthlyRecords.firstWhere(
                      (r) => r.habitId == _selectedHabit!.id &&
                      r.dataRegistre.day == day &&
                      r.dataRegistre.month == _currentMonth.month,
                  orElse: () => HabitRecordModel(
                      id: '', habitId: _selectedHabit!.id, userId: '',
                      dataRegistre: date, createdAt: DateTime.now(), updatedAt: DateTime.now()
                  ),
                );
                progress = (record.valorProgres / _selectedHabit!.valorObjectiu).clamp(0.0, 1.0);
              }
            }

            return GestureDetector(
              onTap: () => _showDailyDetail(context, date, expected, provider.monthlyRecords.where((r) => r.dataRegistre.day == day).toList(), strings),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (expected.any((h) => _selectedHabit == null || h.id == _selectedHabit!.id))
                    SizedBox(
                      width: 45,
                      height: 45,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 3,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        color: primaryProgressColor,
                      ),
                    ),
                  Text(
                      "$day",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: !expected.any((h) => _selectedHabit == null || h.id == _selectedHabit!.id)
                              ? (theme.brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey.shade400)
                              : theme.colorScheme.onSurface
                      )
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAdvancedStats(HabitProvider provider, S strings, ThemeData theme) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime startDate;
    DateTime endDate;
    List<HabitRecordModel> recordsToAnalyze;

    if (_currentView == StatsView.mensual) {
      startDate = DateTime(_currentMonth.year, _currentMonth.month, 1);
      DateTime lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
      endDate = (_currentMonth.year == now.year && _currentMonth.month == now.month) ? today : lastDayOfMonth;
      recordsToAnalyze = provider.monthlyRecords;
    } else {
      if (provider.habits.isEmpty) return const SizedBox.shrink();
      startDate = provider.habits.map((h) => h.dataInici).reduce((a, b) => a.isBefore(b) ? a : b);
      endDate = today;
      recordsToAnalyze = provider.allTimeRecords;
    }

    if (_selectedHabit != null) {
      recordsToAnalyze = recordsToAnalyze.where((r) => r.habitId == _selectedHabit!.id).toList();
    }

    int totalExpected = 0;
    int totalCompleted = 0;
    int perfectDays = 0;
    int activeDays = 0;
    double totalAccumulatedValue = 0;

    Map<String, int> habitCurrentStreaks = {};
    Map<String, int> habitMaxStreaks = {};

    int totalDaysInRange = endDate.difference(startDate).inDays + 1;

    for (int i = 0; i < totalDaysInRange; i++) {
      DateTime date = startDate.add(Duration(days: i));
      var expectedHabits = provider.getExpectedHabitsForDate(date);
      if (_selectedHabit != null) expectedHabits = expectedHabits.where((h) => h.id == _selectedHabit!.id).toList();

      if (expectedHabits.isNotEmpty) activeDays++;

      for (var h in (_selectedHabit != null ? [_selectedHabit!] : provider.habits)) {
        bool expectedToday = expectedHabits.any((eh) => eh.id == h.id);
        var recordToday = recordsToAnalyze.where((r) => r.habitId == h.id && r.dataRegistre.year == date.year && r.dataRegistre.month == date.month && r.dataRegistre.day == date.day).toList();
        bool completedToday = recordToday.any((r) => r.completat);
        if (recordToday.isNotEmpty) totalAccumulatedValue += recordToday.first.valorProgres;

        if (completedToday) {
          habitCurrentStreaks[h.id] = (habitCurrentStreaks[h.id] ?? 0) + 1;
          if ((habitCurrentStreaks[h.id] ?? 0) > (habitMaxStreaks[h.id] ?? 0)) habitMaxStreaks[h.id] = habitCurrentStreaks[h.id]!;
        } else if (expectedToday) {
          habitCurrentStreaks[h.id] = 0;
        }
      }

      final completedOnDate = recordsToAnalyze.where((r) => r.dataRegistre.year == date.year && r.dataRegistre.month == date.month && r.dataRegistre.day == date.day && r.completat).length;
      totalExpected += expectedHabits.length;
      totalCompleted += completedOnDate;
      if (expectedHabits.isNotEmpty && completedOnDate >= expectedHabits.length) perfectDays++;
    }

    double completionPercentage = totalExpected > 0 ? (totalCompleted / totalExpected) * 100 : 0.0;
    double dailyAverage = activeDays > 0 ? totalCompleted / activeDays : 0.0;
    final cardWidth = (MediaQuery.of(context).size.width - 52) / 2;

    HabitModel? starHabit;
    int maxStreakInPeriod = 0;
    int currentStreakInPeriod = 0;

    if (_selectedHabit != null) {
      maxStreakInPeriod = habitMaxStreaks[_selectedHabit!.id] ?? 0;
      currentStreakInPeriod = habitCurrentStreaks[_selectedHabit!.id] ?? 0;
    } else if (provider.habits.isNotEmpty) {
      habitMaxStreaks.forEach((id, streak) { if (streak > maxStreakInPeriod) maxStreakInPeriod = streak; });
      if (maxStreakInPeriod > 0) {
        String starId = habitMaxStreaks.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
        starHabit = provider.habits.firstWhere((h) => h.id == starId);
      }
    }

    return Column(
      children: [
        Text(_selectedHabit != null ? _selectedHabit!.titol : (_currentView == StatsView.mensual ? strings.monthlySummary : strings.globalSummary), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: CircularProgressIndicator(
                value: completionPercentage / 100,
                strokeWidth: 12,
                backgroundColor: theme.colorScheme.primary.withValues(alpha:0.1),
                color: _selectedHabit != null ? Color(int.parse(_selectedHabit!.color.replaceFirst('#', '0xff'))) : theme.colorScheme.primary,
                strokeCap: StrokeCap.round,
              ),
            ),
            Column(children: [
              Text("${completionPercentage.toStringAsFixed(2)}%", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              Text(strings.completedLabel, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ]),
          ],
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            SizedBox(width: cardWidth, child: _statCard(strings.completedLabel, "$totalCompleted", Icons.check_circle, Colors.green)),
            if (_selectedHabit == null) ...[
              SizedBox(width: cardWidth, child: _statCard(strings.starHabitLabel, starHabit?.titol ?? "-", starHabit != null ? _getIcona(starHabit.icona) : Icons.star_border_rounded, Colors.amber)),
              SizedBox(width: cardWidth, child: _statCard(strings.perfectDaysLabel, "$perfectDays", Icons.workspace_premium, Colors.blueAccent)),
              SizedBox(width: cardWidth, child: _statCard(strings.dailyAverageLabel, dailyAverage.toStringAsFixed(1), Icons.bar_chart, Colors.deepPurple)),
              if (_currentView == StatsView.mensual)
                SizedBox(width: cardWidth, child: _buildWorkloadCard(provider, strings))
              else
                SizedBox(width: cardWidth, child: _statCard(strings.allTimeRecord, "${starHabit?.millorRatxa ?? 0}", Icons.emoji_events, Colors.orange)),
            ] else ...[
              SizedBox(width: cardWidth, child: _statCard(strings.totalAccumulated, "${totalAccumulatedValue % 1 == 0 ? totalAccumulatedValue.toInt() : totalAccumulatedValue.toStringAsFixed(1)} ${_selectedHabit!.unitatMesura.name}", Icons.analytics_outlined, Colors.blue)),
              SizedBox(width: cardWidth, child: _statCard(strings.currentStreakLabel, "$currentStreakInPeriod", Icons.local_fire_department, Colors.orange)),
              SizedBox(width: cardWidth, child: _statCard(strings.bestStreakLabel, "$maxStreakInPeriod", Icons.military_tech, Colors.amber)),
              if (_currentView == StatsView.mensual)
                SizedBox(width: cardWidth, child: _buildWorkloadCard(provider, strings)),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildCommentsSection(HabitProvider provider, S strings, ThemeData theme) {
    final recordsWithComments = (_currentView == StatsView.mensual ? provider.monthlyRecords : provider.allTimeRecords)
        .where((r) => r.habitId == _selectedHabit!.id && r.comentari != null && r.comentari!.isNotEmpty)
        .toList();

    recordsWithComments.sort((a, b) => b.dataRegistre.compareTo(a.dataRegistre));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 40),
        Row(
          children: [
            const Icon(Icons.comment_bank_outlined, size: 20),
            const SizedBox(width: 8),
            Text(strings.habitComments, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            IconButton(
              icon: Icon(Icons.add_circle_outline_rounded, color: theme.colorScheme.primary),
              onPressed: () => _showAddCommentFlow(context, _selectedHabit!),
              tooltip: strings.addComment,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (recordsWithComments.isEmpty)
          Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Text(strings.noComments, style: TextStyle(color: Colors.grey.shade500, fontStyle: FontStyle.italic))))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recordsWithComments.length,
            itemBuilder: (context, index) {
              final r = recordsWithComments[index];
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 10),
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha:0.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(DateFormat.yMMMMd(Intl.getCurrentLocale()).format(r.dataRegistre), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text(r.comentari!, style: const TextStyle(fontSize: 15, height: 1.3)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit_outlined, size: 18, color: theme.colorScheme.primary),
                        onPressed: () => _showCommentEditSheet(context, r, _selectedHabit!),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        onPressed: () => provider.updateComment(habitId: r.habitId, comentari: null),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Future<void> _showAddCommentFlow(BuildContext context, HabitModel habit) async {
    final strings = S.of(context);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: habit.dataInici,
      lastDate: DateTime.now(),
      helpText: strings.selectDate,
    );

    if (pickedDate != null && mounted) {
      final provider = context.read<HabitProvider>();
      final existingRecords = provider.allTimeRecords.where((r) =>
      r.habitId == habit.id &&
          r.dataRegistre.year == pickedDate.year &&
          r.dataRegistre.month == pickedDate.month &&
          r.dataRegistre.day == pickedDate.day
      ).toList();

      final HabitRecordModel recordToEdit = existingRecords.isNotEmpty
          ? existingRecords.first
          : HabitRecordModel(
          id: '',
          habitId: habit.id,
          userId: habit.userId,
          dataRegistre: pickedDate,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now()
      );

      _showCommentEditSheet(context, recordToEdit, habit);
    }
  }

  void _showCommentEditSheet(BuildContext context, HabitRecordModel record, HabitModel habit) {
    final strings = S.of(context);
    final theme = Theme.of(context);
    final controller = TextEditingController(text: record.comentari);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(strings.addComment, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                maxLines: 3,
                maxLength: 150,
                autofocus: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: theme.colorScheme.primary.withValues(alpha:0.05),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final oldDate = context.read<HabitProvider>().selectedDate;
                  await context.read<HabitProvider>().loadDataForDate(record.dataRegistre);
                  await context.read<HabitProvider>().updateComment(habitId: habit.id, comentari: controller.text.trim());
                  await context.read<HabitProvider>().loadDataForDate(oldDate);
                  if (context.mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: Text(strings.confirm),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHabitActions(HabitProvider provider, S strings, ThemeData theme) {
    final habit = _selectedHabit!;
    return Column(
      children: [
        const Divider(height: 40),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HabitFormScreen(habitToEdit: habit))),
                icon: const Icon(Icons.edit_outlined),
                label: Text(strings.editHabitTitle),
                style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showConfirmDialog(
                  context,
                  title: habit.arxivat ? strings.unarchive : strings.archive,
                  message: habit.arxivat ? strings.unarchiveDialog : strings.archiveHabitMessage,
                  onConfirm: () async => await provider.archiveHabit(habit.id, !habit.arxivat),
                ),
                icon: Icon(habit.arxivat ? Icons.unarchive_outlined : Icons.archive_outlined),
                label: Text(habit.arxivat ? strings.unarchive : strings.archive),
                style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showConfirmDialog(
                  context,
                  title: strings.deleteHabitConfirm,
                  message: strings.deleteHabitMessage,
                  isDestructive: true,
                  onConfirm: () async {
                    await provider.deleteHabit(habit.id);
                    setState(() => _selectedHabit = null);
                  },
                ),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: Text(strings.remove, style: const TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
          ],
        ),
      ],
    );
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
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: isDestructive ? Colors.red : Theme.of(context).colorScheme.primary, foregroundColor: Colors.white, elevation: 0),
            child: Text(isDestructive ? strings.remove : strings.confirm),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkloadCard(HabitProvider provider, S strings) {
    var currentRecs = provider.monthlyRecords;
    var prevRecs = _prevMonthRecords;
    if (_selectedHabit != null) {
      currentRecs = currentRecs.where((r) => r.habitId == _selectedHabit!.id).toList();
      prevRecs = prevRecs.where((r) => r.habitId == _selectedHabit!.id).toList();
    }
    final completedCurrent = currentRecs.where((r) => r.completat).length;
    final completedPrev = prevRecs.where((r) => r.completat).length;
    String workloadVal = "-";
    Color workloadColor = Colors.blue;
    IconData workloadIcon = Icons.trending_flat;
    if (!_isComparing && completedPrev > 0) {
      double diff = ((completedCurrent - completedPrev) / completedPrev) * 100;
      workloadVal = "${diff > 0 ? '+' : ''}${diff.toStringAsFixed(0)}%";
      workloadColor = diff >= 0 ? Colors.blue : Colors.red;
      workloadIcon = diff >= 0 ? Icons.trending_up : Icons.trending_down;
    }
    return _statCard(strings.workloadLabel, workloadVal, workloadIcon, workloadColor);
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withValues(alpha:0.1), borderRadius: BorderRadius.circular(15), border: Border.all(color: color.withValues(alpha:0.2))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600), textAlign: TextAlign.center, maxLines: 1),
        ],
      ),
    );
  }

  void _showDailyDetail(BuildContext context, DateTime date, List<HabitModel> expected, List<HabitRecordModel> records, S strings) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text(DateFormat.yMMMMd(Intl.getCurrentLocale()).format(date), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: expected.isEmpty
                  ? Center(child: Text(strings.noHabitsDay))
                  : ListView.builder(
                itemCount: expected.length,
                itemBuilder: (context, i) {
                  final h = expected[i];
                  final record = records.firstWhere((r) => r.habitId == h.id, orElse: () => HabitRecordModel(id: '', habitId: h.id, userId: '', dataRegistre: date, createdAt: DateTime.now(), updatedAt: DateTime.now()));
                  final isDone = record.id.isNotEmpty && record.completat;
                  final color = Color(int.parse(h.color.replaceFirst('#', '0xff')));
                  return Opacity(
                    opacity: h.arxivat ? 0.6 : 1.0,
                    child: ListTile(
                      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha:0.1), shape: BoxShape.circle), child: Icon(_getIcona(h.icona), color: color)),
                      title: Row(children: [
                        Flexible(child: Text(h.titol, style: const TextStyle(fontWeight: FontWeight.bold))),
                        if (h.arxivat) ...[const SizedBox(width: 8), const Icon(Icons.archive, size: 14, color: Colors.grey)],
                      ]),
                      subtitle: isDone ? Text("${strings.registeredAt} ${DateFormat.Hm().format(record.updatedAt)}") : Text(strings.pendingStatus),
                      trailing: Text("${record.valorProgres % 1 == 0 ? record.valorProgres.toInt() : record.valorProgres} / ${h.valorObjectiu % 1 == 0 ? h.valorObjectiu.toInt() : h.valorObjectiu}", style: TextStyle(fontWeight: FontWeight.bold, color: isDone ? color : Colors.grey)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
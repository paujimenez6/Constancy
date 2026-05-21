import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/habit_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/social_provider.dart';
import '../../domain/models/habit_record_model.dart';
import '../../domain/models/habit_model.dart';
import '../../generated/l10n.dart';
import '../../domain/models/habit_assets.dart';
import 'habit_form_screen.dart';
import 'other_profile_screen.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

enum StatsView { mensual, global }

class _StatisticsScreenState extends State<StatisticsScreen> with SingleTickerProviderStateMixin {
  DateTime _currentMonth = DateTime.now();
  List<HabitRecordModel> _prevMonthRecords = [];
  bool _isComparing = false;
  bool _isCumulativeView = false;
  StatsView _currentView = StatsView.mensual;
  HabitModel? _selectedHabit;
  String? _selectedCategory;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController!.addListener(() {
      if (!_tabController!.indexIsChanging) {
        setState(() {});
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final provider = context.read<HabitProvider>();

    await provider.loadMonthlyData(_currentMonth);
    await provider.loadAllTimeData();

    if (_selectedHabit != null && _selectedHabit!.isGroup) {
      await provider.loadGroupStatistics(_selectedHabit!.id, _currentMonth);
      await provider.loadGroupDetails(_selectedHabit!.id);
    }

    setState(() => _isComparing = true);
    final prevMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    final startOfPrev = DateTime(prevMonth.year, prevMonth.month, 1);
    final endOfPrev = DateTime(prevMonth.year, prevMonth.month + 1, 0);

    final records = await provider.getRecordsForRange(startOfPrev, endOfPrev);

    if (mounted) {
      setState(() {
        _prevMonthRecords = records;
        _isComparing = false;
      });
    }
  }

  void _changeMonth(int increment) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + increment, 1);
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();
    final authProvider = context.watch<AuthProvider>();
    final strings = S.of(context);
    final theme = Theme.of(context);
    final currentUserId = authProvider.currentUser?.id;

    if (_selectedHabit != null) {
      _selectedHabit = provider.habits.cast<HabitModel?>().firstWhere(
            (h) => h?.id == _selectedHabit!.id,
        orElse: () => null,
      );
    }

    final bool isGroupHabit = _selectedHabit?.isGroup ?? false;
    final bool isAdmin = _selectedHabit == null || !isGroupHabit || _selectedHabit!.userId == currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.navStats, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        bottom: isGroupHabit ? TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            Tab(text: strings.personalStats.toUpperCase()),
            Tab(text: strings.groupStats.toUpperCase()),
          ],
        ) : null,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : isGroupHabit
          ? TabBarView(
        controller: _tabController,
        children: [
          _buildMainContent(provider, strings, theme, isAdmin, isGroupMode: false),
          _buildMainContent(provider, strings, theme, isAdmin, isGroupMode: true),
        ],
      )
          : _buildMainContent(provider, strings, theme, isAdmin, isGroupMode: false),
    );
  }

  Widget _buildMainContent(HabitProvider provider, S strings, ThemeData theme, bool isAdmin, {required bool isGroupMode}) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
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
          _buildCalendarGrid(provider, strings, theme, isGroupMode: isGroupMode),
          const SizedBox(height: 20),
          SegmentedButton<StatsView>(
            segments: [
              ButtonSegment(value: StatsView.mensual, label: Text(strings.monthlyLabel), icon: const Icon(Icons.calendar_view_month)),
              ButtonSegment(value: StatsView.global, label: Text(strings.globalLabel), icon: const Icon(Icons.public)),
            ],
            selected: {_currentView},
            onSelectionChanged: (Set<StatsView> newSelection) {
              setState(() => _currentView = newSelection.first);
            },
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          _buildAdvancedStats(provider, strings, theme, isGroupMode: isGroupMode),
          const SizedBox(height: 30),
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(value: false, label: Text(strings.statsPunctual), icon: const Icon(Icons.show_chart)),
              ButtonSegment(value: true, label: Text(strings.statsCumulative), icon: const Icon(Icons.stacked_line_chart)),
            ],
            selected: {_isCumulativeView},
            onSelectionChanged: (Set<bool> newSelection) {
              setState(() => _isCumulativeView = newSelection.first);
            },
          ),
          _buildTrendChart(provider, strings, theme, isGroupMode: isGroupMode),

          if (_selectedHabit != null) ...[
            const SizedBox(height: 30),
            if (isAdmin && !isGroupMode) _buildCommentsSection(provider, strings, theme),

            if (isGroupMode) ...[
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 30),
              _buildGroupMembersSection(context, provider, theme, strings),
            ],

            const SizedBox(height: 40),
            if (!isGroupMode) _buildHabitActions(provider, strings, theme, isAdmin),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHabitSelector(HabitProvider provider, S strings, ThemeData theme) {
    final categories = provider.availableCategories;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedHabit != null
              ? 'h_${_selectedHabit!.id}'
              : (_selectedCategory != null ? 'c_$_selectedCategory' : 'all'),
          isExpanded: true,
          icon: const Icon(Icons.filter_list_rounded),
          items: [
            DropdownMenuItem(
              value: 'all',
              child: Row(
                children: [
                  const Icon(Icons.public, size: 20),
                  const SizedBox(width: 10),
                  Text(strings.statsAllHabits, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            if (categories.isNotEmpty) ...[
              const DropdownMenuItem(enabled: false, child: Divider()),
              ...categories.map((cat) => DropdownMenuItem(
                value: 'c_$cat',
                child: Row(
                  children: [
                    const Icon(Icons.folder_open_rounded, size: 20, color: Colors.orange),
                    const SizedBox(width: 10),
                    Text(cat, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              )),
            ],
            const DropdownMenuItem(enabled: false, child: Divider()),
            ...provider.habits.map((h) {
              final bool isArchived = h.arxivat;
              return DropdownMenuItem(
                value: 'h_${h.id}',
                child: Opacity(
                  opacity: isArchived ? 0.5 : 1.0,
                  child: Row(
                    children: [
                      Icon(HabitAssets.getIconByName(h.icona),
                          size: 20,
                          color: HabitAssets.hexToColor(h.color)),
                      const SizedBox(width: 10),
                      if (h.isGroup)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(Icons.groups_rounded, size: 18, color: theme.colorScheme.primary),
                        ),
                      Expanded(
                          child: Text(h.titol,
                              style: TextStyle(fontStyle: isArchived ? FontStyle.italic : FontStyle.normal))),
                      if (isArchived)
                        Icon(Icons.archive_outlined, size: 16, color: theme.colorScheme.outline),
                    ],
                  ),
                ),
              );
            }),
          ],
          onChanged: (String? newValue) {
            setState(() {
              if (newValue == 'all') {
                _selectedHabit = null;
                _selectedCategory = null;
              } else if (newValue!.startsWith('c_')) {
                _selectedCategory = newValue.replaceFirst('c_', '');
                _selectedHabit = null;
              } else if (newValue.startsWith('h_')) {
                final id = newValue.replaceFirst('h_', '');
                _selectedHabit = provider.habits.firstWhere((h) => h.id == id);
                _selectedCategory = null;
              }
            });
            _loadData();
          },
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(HabitProvider provider, S strings, ThemeData theme, {required bool isGroupMode}) {
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final offset = firstDayOfMonth.weekday - 1;

    final Color primaryProgressColor = _selectedHabit != null
        ? HabitAssets.hexToColor(_selectedHabit!.color)
        : theme.colorScheme.primary;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (index) {
            final day = DateFormat.E(Intl.getCurrentLocale()).format(DateTime(2024, 1, index + 1));
            return Expanded(
                child: Center(
                    child: Text(day.toUpperCase().replaceAll('.', ''),
                        style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant, fontSize: 11))));
          }),
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
            final expectedTotal = provider.getExpectedHabitsForDate(date);

            List<HabitModel> filteredExpected = expectedTotal;
            if (_selectedHabit != null) {
              filteredExpected = expectedTotal.where((h) => h.id == _selectedHabit!.id).toList();
            }

            double progress = 0.0;
            final sourceRecords = isGroupMode ? provider.groupAggregatedMonthlyRecords : provider.monthlyRecords;
            final dayRecords = sourceRecords.where((r) => r.dataRegistre.day == day).toList();

            if (filteredExpected.isNotEmpty) {
              if (_selectedHabit != null) {
                final r = dayRecords.firstWhere((r) => r.habitId == _selectedHabit!.id, orElse: () => HabitRecordModel(id: '', habitId: '', userId: '', dataRegistre: date, createdAt: DateTime.now(), updatedAt: DateTime.now()));
                progress = (r.valorProgres / _selectedHabit!.valorObjectiu).clamp(0.0, 1.0);
              } else {
                final completedCount = dayRecords.where((r) {
                  final h = provider.habits.firstWhere((hab) => hab.id == r.habitId);
                  return r.valorProgres >= h.valorObjectiu;
                }).length;
                progress = (completedCount / filteredExpected.length).clamp(0.0, 1.0);
              }
            }

            return GestureDetector(
              onTap: () {
                final detailRecords = dayRecords.where((r) => filteredExpected.any((h) => h.id == r.habitId)).toList();
                _showDailyDetail(context, date, filteredExpected, detailRecords, strings, isGroupMode: isGroupMode);
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (filteredExpected.isNotEmpty)
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
                  Text("$day",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: filteredExpected.isEmpty
                              ? theme.colorScheme.outline.withValues(alpha: 0.5)
                              : theme.colorScheme.onSurface)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTrendChart(HabitProvider provider, S strings, ThemeData theme, {required bool isGroupMode}) {
    final isMensual = _currentView == StatsView.mensual;
    final chartData = provider.getStatisticsChartData(
      isMensual: isMensual,
      selectedHabit: _selectedHabit,
      selectedCategory: _selectedCategory,
      viewDate: _currentMonth,
      isCumulative: _isCumulativeView,
      useGroupData: isGroupMode,
    );

    if (chartData.isEmpty) return const SizedBox.shrink();

    final Color primaryColor = _selectedHabit != null
        ? HabitAssets.hexToColor(_selectedHabit!.color)
        : theme.colorScheme.primary;

    final String unitat = _selectedHabit?.unitatMesura.getLocalizedString(context) ?? strings.completedLabel;
    final String yAxisLabel = _isCumulativeView ? "${strings.statsCumulative.toUpperCase()} ($unitat)" : unitat.toUpperCase();
    final bool showObjectiveLine = _selectedHabit != null && isMensual && !_isCumulativeView;

    double maxY = chartData.map((e) => e.y).fold(0.0, (max, e) => e > max ? e : max);
    if (showObjectiveLine && _selectedHabit!.valorObjectiu > maxY) maxY = _selectedHabit!.valorObjectiu;
    maxY = maxY == 0 ? 5 : (maxY * 1.3).ceilToDouble();

    double yInterval = 1;
    if (maxY > 5 && maxY <= 12) {
      yInterval = 2;
    } else if (maxY > 12 && maxY <= 30) {
      yInterval = 5;
    } else if (maxY > 30 && maxY <= 70) {
      yInterval = 10;
    } else if (maxY > 70 && maxY <= 200) {
      yInterval = 25;
    } else if (maxY > 200) {
      yInterval = (maxY / 6).ceilToDouble();
    }

    return Container(
      height: 380,
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.fromLTRB(10, 24, 20, 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => theme.colorScheme.primaryContainer,
              getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
                "${s.y.toInt()} $unitat\n",
                TextStyle(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: isMensual ? "${strings.day} ${s.x.toInt()}" : provider.getMonthLabels()[s.x.toInt() - 1],
                    style: TextStyle(color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7), fontSize: 11),
                  ),
                ],
              )).toList(),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: yInterval,
            getDrawingHorizontalLine: (value) => FlLine(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2), strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              axisNameWidget: Padding(padding: const EdgeInsets.only(bottom: 12.0), child: Text(yAxisLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryColor))),
              axisNameSize: 30,
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: yInterval,
                getTitlesWidget: (val, meta) {
                  if (val % yInterval != 0) return const SizedBox.shrink();
                  return Text(val.toInt().toString(), style: _chartLabelStyle(theme));
                },
              ),
            ),
            bottomTitles: AxisTitles(
              axisNameWidget: Padding(padding: const EdgeInsets.only(top: 10.0), child: Text((isMensual ? strings.daysOfMonth : strings.monthsOfYear).toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryColor))),
              axisNameSize: 25,
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                getTitlesWidget: (val, meta) {
                  if (val % 1 != 0) return const SizedBox.shrink();
                  final int index = val.toInt();
                  final label = isMensual ? Text(index.toString(), style: _chartLabelStyle(theme)) : Text(provider.getMonthLabels()[index - 1].toUpperCase(), style: _chartLabelStyle(theme));
                  return Padding(padding: const EdgeInsets.only(top: 10), child: label);
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: chartData.map((p) => FlSpot(p.x, p.y)).toList(),
              isCurved: true,
              color: primaryColor,
              barWidth: 4,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(show: true, gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [primaryColor.withValues(alpha: 0.2), primaryColor.withValues(alpha: 0.0)])),
            ),
          ],
          extraLinesData: ExtraLinesData(
            horizontalLines: showObjectiveLine ? [HorizontalLine(y: _selectedHabit!.valorObjectiu, color: Colors.orange.withValues(alpha: 0.5), strokeWidth: 2, dashArray: [8, 4], label: HorizontalLineLabel(show: true, alignment: Alignment.topRight, style: const TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold), labelResolver: (line) => strings.habitObjective.toUpperCase()))] : [],
          ),
          minY: 0,
          maxY: maxY,
        ),
      ),
    );
  }

  Widget _buildAdvancedStats(HabitProvider provider, S strings, ThemeData theme, {required bool isGroupMode}) {
    final stats = provider.getStats(
      isMensual: _currentView == StatsView.mensual,
      habitId: _selectedHabit?.id,
      categoryId: _selectedCategory,
      useGroupData: isGroupMode,
    );

    final cardWidth = (MediaQuery.of(context).size.width - 52) / 2;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_selectedHabit != null && _selectedHabit!.isGroup)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(Icons.groups_rounded, color: theme.colorScheme.primary, size: 28),
              ),
            Flexible(
              child: Text(
                _selectedHabit != null ? _selectedHabit!.titol : (_selectedCategory ?? ( _currentView == StatsView.mensual ? strings.monthlySummary : strings.globalSummary)),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: CircularProgressIndicator(
                value: (stats.completionPercentage / 100).clamp(0.0, 1.0),
                strokeWidth: 12,
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                color: _selectedHabit != null ? HabitAssets.hexToColor(_selectedHabit!.color) : theme.colorScheme.primary,
                strokeCap: StrokeCap.round,
              ),
            ),
            Column(children: [
              Text("${stats.completionPercentage.toStringAsFixed(1)}%", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
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
            _statCard(strings.completedLabel, "${stats.totalCompleted}", Icons.check_circle, Colors.green, cardWidth),
            _statCard(strings.currentStreakLabel, "${isGroupMode ? _selectedHabit?.ratxaActual : stats.currentStreak}", Icons.local_fire_department, Colors.orange, cardWidth),
            _statCard(strings.totalAccumulated, "${stats.totalAccumulatedValue.toInt()} ${_selectedHabit?.unitatMesura.getLocalizedString(context) ?? ''}", Icons.analytics_outlined, Colors.blue, cardWidth),
            _statCard(strings.bestStreakLabel, "${isGroupMode ? _selectedHabit?.millorRatxa : stats.maxStreak}", Icons.military_tech, Colors.amber, cardWidth),
            if (_currentView == StatsView.mensual)
              _buildWorkloadCard(provider, strings, cardWidth),
          ],
        ),
      ],
    );
  }

  Widget _buildCommentsSection(HabitProvider provider, S strings, ThemeData theme) {
    final recordsWithComments = (_currentView == StatsView.mensual ? provider.monthlyRecords : provider.allTimeRecords)
        .where((r) => r.habitId == _selectedHabit?.id && r.comentari != null && r.comentari!.isNotEmpty)
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
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
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
                        onPressed: () async {
                          await provider.updateComment(habitId: r.habitId, comentari: null);
                          await _loadData();
                        },
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
    final pickedDate = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: habit.dataInici, lastDate: DateTime.now());

    if (pickedDate != null && mounted) {
      final HabitRecordModel rec = HabitRecordModel(id: '', habitId: habit.id, userId: habit.userId, dataRegistre: pickedDate, createdAt: DateTime.now(), updatedAt: DateTime.now());
      _showCommentEditSheet(context, rec, habit);
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
                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: theme.colorScheme.primary.withValues(alpha: 0.05)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final prov = context.read<HabitProvider>();
                  final oldDate = prov.selectedDate;

                  await prov.loadDataForDate(record.dataRegistre);
                  await prov.updateComment(habitId: habit.id, comentari: controller.text.trim());

                  await _loadData();
                  await prov.loadDataForDate(oldDate);

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

  Widget _buildHabitActions(HabitProvider provider, S strings, ThemeData theme, bool isAdmin) {
    final habit = _selectedHabit!;

    if (!isAdmin) {
      return Column(
        children: [
          const Divider(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showConfirmDialog(
                context,
                title: strings.leaveHabitConfirm,
                message: strings.leaveHabitMessage,
                isDestructive: true,
                onConfirm: () async => await provider.leaveGroup(habit.id),
              ),
              icon: const Icon(Icons.logout_rounded),
              label: Text(strings.leaveAction, style: const TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        const Divider(height: 40),
        Row(
          children: [
            Expanded(child: ElevatedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HabitFormScreen(habitToEdit: habit))), icon: const Icon(Icons.edit_outlined), label: Text(strings.editHabitTitle))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: OutlinedButton.icon(onPressed: () => provider.archiveHabit(habit.id, !habit.arxivat), icon: Icon(habit.arxivat ? Icons.unarchive_outlined : Icons.archive_outlined), label: Text(habit.arxivat ? strings.unarchive : strings.archive))),
            const SizedBox(width: 12),
            Expanded(child: OutlinedButton.icon(onPressed: () => _showConfirmDialog(context, title: strings.deleteHabitConfirm, message: strings.deleteHabitMessage, isDestructive: true, onConfirm: () async => await provider.deleteHabit(habit.id)), icon: const Icon(Icons.delete_outline, color: Colors.red), label: Text(strings.remove, style: const TextStyle(color: Colors.red)), style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)))),
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
              if (context.mounted) {
                Navigator.pop(context);
                if (isDestructive) setState(() => _selectedHabit = null);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? Colors.red : Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: Text(isDestructive ? (title == strings.leaveHabitConfirm ? strings.leaveAction : strings.remove) : strings.confirm),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkloadCard(HabitProvider provider, S strings, double width) {
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
    if (!_isComparing && completedPrev > 0) {
      double diff = ((completedCurrent - completedPrev) / completedPrev) * 100;
      workloadVal = "${diff > 0 ? '+' : ''}${diff.toStringAsFixed(0)}%";
      workloadColor = diff >= 0 ? Colors.blue : Colors.red;
    }
    return _statCard(strings.workloadLabel, workloadVal, Icons.trending_up, workloadColor, width);
  }

  Widget _statCard(String label, String value, IconData icon, Color color, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(15), border: Border.all(color: color.withValues(alpha: 0.2))),
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

  Widget _buildGroupMembersSection(BuildContext context, HabitProvider prov, ThemeData theme, S strings) {
    final myId = context.read<AuthProvider>().currentUser?.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(strings.invitationCode.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.outline, letterSpacing: 1)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(16), border: Border.all(color: theme.colorScheme.outlineVariant)),
          child: Row(
            children: [
              const Icon(Icons.key_rounded, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(prov.currentInviteCode ?? "---", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2, fontFamily: 'monospace'))),
              IconButton(
                icon: const Icon(Icons.copy_rounded),
                onPressed: () {
                  if (prov.currentInviteCode != null) {
                    Clipboard.setData(ClipboardData(text: prov.currentInviteCode!));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(strings.invitationCopied)));
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text(strings.members.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.outline, letterSpacing: 1)),
        const SizedBox(height: 16),
        if (prov.isLoading)
          const Center(child: CircularProgressIndicator())
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: prov.currentGroupMembers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final member = prov.currentGroupMembers[index];
              final bool isMe = member.userId == myId;

              return InkWell(
                onTap: () async {
                  if (isMe) return;
                  final socialProv = context.read<SocialProvider>();
                  final targetUser = await socialProv.getUserById(member.userId);
                  if (targetUser != null && context.mounted) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => OtherProfileScreen(userData: targetUser)));
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMe ? theme.colorScheme.primary.withValues(alpha: 0.05) : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isMe ? theme.colorScheme.primary.withValues(alpha: 0.3) : theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(backgroundColor: theme.colorScheme.primaryContainer, child: Text(member.nickname[0].toUpperCase())),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(member.nickname, style: const TextStyle(fontWeight: FontWeight.bold)),
                            if (member.esAdministrador)
                              Text(strings.groupAdmin, style: TextStyle(fontSize: 10, color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                          ],
                        ),
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

  TextStyle _chartLabelStyle(ThemeData theme) => TextStyle(fontSize: 9, color: theme.colorScheme.outline, fontWeight: FontWeight.bold);

  void _showDailyDetail(BuildContext context, DateTime date, List<HabitModel> expected, List<HabitRecordModel> records, S strings, {required bool isGroupMode}) {
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

                  final bool estaRealmentFet = isGroupMode
                      ? (record.valorProgres >= h.valorObjectiu)
                      : (record.id.isNotEmpty && record.valorProgres >= h.valorObjectiu);

                  final color = HabitAssets.hexToColor(h.color);

                  return ListTile(
                    leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(HabitAssets.getIconByName(h.icona), color: color)),
                    title: Row(
                      children: [
                        if (h.isGroup)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Icon(Icons.groups_rounded, size: 16, color: Theme.of(context).colorScheme.primary),
                          ),
                        Expanded(child: Text(h.titol, style: const TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        estaRealmentFet
                            ? Text("${strings.registeredAt} ${DateFormat.Hm().format(record.updatedAt)}")
                            : Text(strings.pendingStatus),
                        if (h.recordatoris && h.horesRecordatori.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.notifications_active_outlined, size: 12, color: Theme.of(context).colorScheme.primary),
                                const SizedBox(width: 4),
                                Text(
                                  h.horesRecordatori.join(' • '),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    trailing: Text("${record.valorProgres % 1 == 0 ? record.valorProgres.toInt() : record.valorProgres} / ${h.valorObjectiu % 1 == 0 ? h.valorObjectiu.toInt() : h.valorObjectiu}",
                        style: TextStyle(fontWeight: FontWeight.bold, color: estaRealmentFet ? color : Colors.grey)),
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
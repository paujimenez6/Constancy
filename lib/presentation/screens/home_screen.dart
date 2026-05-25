import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../domain/models/habit_model.dart';
import '../../domain/models/habit_assets.dart';
import '../../generated/l10n.dart';
import '../providers/auth_provider.dart';
import '../providers/habit_provider.dart';
import 'archived_habits_screen.dart';
import 'habit_detail_screen.dart';
import 'habit_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HabitProvider _habitProviderRef;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<HabitProvider>();
      prov.loadDataForDate(DateTime.now()).then((_) {
        prov.listenToAllVisibleGroups();
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _habitProviderRef = Provider.of<HabitProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _habitProviderRef.stopListeningToAllGroups();
    super.dispose();
  }

  void _showTopToast(BuildContext context, String message, {bool isError = true}) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: isError ? Colors.redAccent.withValues(alpha:0.95) : Colors.green.withValues(alpha:0.95),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Row(
              children: [
                Icon(
                  isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 4), () {
      if (overlayEntry.mounted) overlayEntry.remove();
    });
  }

  Future<bool?> _showShieldWarning(BuildContext context) async {
    final strings = S.of(context);
    final theme = Theme.of(context);

    return await showModalBottomSheet<bool>(
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
            Icon(Icons.shield_outlined, size: 45, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              strings.shieldWarningTitle,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              strings.shieldWarningDesc,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      strings.cancel,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      strings.confirm,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha:0.1), shape: BoxShape.circle),
                  child: Icon(Icons.person_rounded, color: theme.colorScheme.primary)),
              title: Text(strings.newHabitTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(strings.habitPersonalDesc),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const HabitFormScreen()));
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.orange.withValues(alpha:0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.groups_rounded, color: Colors.orange)),
              title: Text(strings.joinGroupHabit, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(strings.joinGroupDesc),
              onTap: () {
                Navigator.pop(context);
                _showJoinDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showJoinDialog(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);
    final codeController = TextEditingController();
    bool isJoining = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: SingleChildScrollView(
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
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha:0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.groups_rounded, size: 40, color: Colors.orange),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      strings.joinGroupHabit,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      strings.joinGroupDialogDesc,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 15),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: codeController,
                      enabled: !isJoining,
                      textCapitalization: TextCapitalization.characters,
                      style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
                      decoration: InputDecoration(
                        hintText: "CONST-XXXX",
                        hintStyle: TextStyle(letterSpacing: 0, color: theme.colorScheme.outline.withValues(alpha:0.5)),
                        prefixIcon: const Icon(Icons.key_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha:0.3),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: isJoining ? null : () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(strings.cancel, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isJoining
                                ? null
                                : () async {
                              final code = codeController.text.trim();
                              if (code.isEmpty) return;

                              setDialogState(() => isJoining = true);

                              try {
                                final habitProvider = context.read<HabitProvider>();
                                final authProvider = context.read<AuthProvider>();

                                await habitProvider.joinGroup(authProvider.currentUser!.id, code);

                                if (context.mounted) {
                                  FocusScope.of(context).unfocus();
                                  Navigator.pop(context);
                                  _showTopToast(context, strings.joinedSuccessfully, isError: false);
                                  habitProvider.listenToAllVisibleGroups();
                                }
                              } catch (e) {
                                FocusScope.of(context).unfocus();
                                setDialogState(() => isJoining = false);

                                String message = strings.genericError;
                                if (e == 'invalid_code' || e.toString().contains('23505')) {
                                  message = strings.errorInvalidInviteCode;
                                }

                                if (context.mounted) {
                                  _showTopToast(context, message, isError: true);
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            child: isJoining
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : Text(strings.joinAction, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = context.watch<AuthProvider>().currentUser;
    final habitProvider = context.watch<HabitProvider>();

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final activeHabits = habitProvider.filteredHabits;
    final dataStr = DateFormat.yMMMMd(Intl.getCurrentLocale()).format(habitProvider.selectedDate);
    final bool isShieldedToday = habitProvider.dailyRecords.values.any((r) => r.isShielded);

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
                Text(dataStr, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.archive_outlined),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ArchivedHabitsScreen()));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const DateSelectorWidget(),
          if (isShieldedToday) _buildShieldBanner(strings),
          const SizedBox(height: 8),
          Expanded(
            child: habitProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : activeHabits.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome, size: 64, color: colorScheme.primary.withValues(alpha:0.3)),
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
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 80),
              physics: const BouncingScrollPhysics(),
              key: const Key('habits_list'),
              itemCount: activeHabits.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final habit = activeHabits[index];
                final record = habitProvider.dailyRecords[habit.id];
                final color = HabitAssets.hexToColor(habit.color);

                final double displayProgres = habit.isGroup
                    ? (habitProvider.groupTotals[habit.id] ?? 0.0)
                    : (record?.valorProgres ?? 0.0);

                final bool estaCompletat = habit.isGroup
                    ? (displayProgres >= habit.valorObjectiu)
                    : (record?.completat ?? false);

                final isItemShielded = record?.isShielded ?? false;

                return InkWell(
                  onTap: () async {
                    if (isShieldedToday) {
                      final proceed = await _showShieldWarning(context);
                      if (proceed != true) return;
                    }
                    if (context.mounted) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => HabitDetailScreen(habitId: habit.id)));
                    }
                  },
                  key: const Key('habit_tile_h1'),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: estaCompletat ? color.withValues(alpha:0.1) : colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isItemShielded ? Colors.blueGrey : (estaCompletat ? color : colorScheme.outlineVariant.withValues(alpha:0.5)), width: estaCompletat ? 2 : 1,
                      ),
                      boxShadow: estaCompletat ? [BoxShadow(color: color.withValues(alpha:0.1), blurRadius: 8, offset: const Offset(0, 4))] : [],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha:0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(HabitAssets.getIconByName(habit.icona), color: color, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (habit.isGroup)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 6, top: 2),
                                      child: Icon(Icons.groups_rounded, size: 22, color: theme.colorScheme.primary),
                                    ),
                                  Expanded(
                                    child: Text(
                                      habit.titol,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        decoration: estaCompletat ? TextDecoration.lineThrough : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isItemShielded
                                    ? strings.shieldDayTag
                                    : "${displayProgres % 1 == 0 ? displayProgres.toInt() : displayProgres} / ${habit.valorObjectiu.toInt()} ${habit.unitatMesura.getLocalizedString(context)}",
                                style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        if (habit.ratxaActual > 0) ...[
                          const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.local_fire_department_rounded, color: Colors.orange[700], size: 20),
                              Text(
                                "${habit.ratxaActual}",
                                style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(width: 4),
                        IconButton(
                          onPressed: () async {
                            if (isShieldedToday) {
                              final proceed = await _showShieldWarning(context);
                              if (proceed != true) return;
                            }

                            double nouIndividual = (record?.valorProgres ?? 0.0) >= habit.valorObjectiu ? 0 : habit.valorObjectiu;

                            await habitProvider.updateProgress(
                              habitId: habit.id,
                              valorProgres: nouIndividual,
                              completat: nouIndividual >= habit.valorObjectiu,
                            );
                          },
                          icon: Icon(
                            isItemShielded
                                ? Icons.shield_rounded
                                : (estaCompletat
                                ? Icons.check_circle_rounded
                                : Icons.circle_outlined),
                            color: isItemShielded
                                ? Colors.blueGrey
                                : (estaCompletat ? color : colorScheme.outline),
                            size: 32,
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOptions(context),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }

  Widget _buildShieldBanner(S strings) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueGrey.shade400, Colors.blueGrey.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_rounded, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.shieldDayTag.toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 1)),
                Text(strings.shieldActivated,
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DateSelectorWidget extends StatefulWidget {
  const DateSelectorWidget({super.key});

  @override
  State<DateSelectorWidget> createState() => _DateSelectorWidgetState();
}

class _DateSelectorWidgetState extends State<DateSelectorWidget> {
  late ScrollController _scrollController;
  final double itemWidth = 50.0;
  final double itemMargin = 5.0;
  final double paddingLeft = 16.0;

  final List<DateTime> dates = List.generate(29, (index) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.subtract(const Duration(days: 14)).add(Duration(days: index));
  });

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerToday();
    });
  }

  void _centerToday() {
    if (!_scrollController.hasClients) return;

    final double fullItemWidth = itemWidth + (itemMargin * 2);
    const int todayIndex = 14;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double offset =
        (todayIndex * fullItemWidth) + paddingLeft + (fullItemWidth / 2) - (screenWidth / 2);

    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider = context.watch<HabitProvider>();
    final theme = Theme.of(context);
    final now = DateTime.now();

    return SizedBox(
      height: 85,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: paddingLeft, vertical: 8),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];

          final isSelected = date.day == habitProvider.selectedDate.day &&
              date.month == habitProvider.selectedDate.month &&
              date.year == habitProvider.selectedDate.year;

          final isToday = date.day == now.day &&
              date.month == now.month &&
              date.year == now.year;

          return GestureDetector(
            onTap: () => habitProvider.changeDate(date),
            child: Container(
              width: itemWidth,
              margin: EdgeInsets.symmetric(horizontal: itemMargin),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.primary.withValues(alpha:0.05),
                borderRadius: BorderRadius.circular(15),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha:0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E', Intl.getCurrentLocale()).format(date),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Column(
                      children: [
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                          ),
                        ),
                        if (isToday)
                          Container(
                            width: 25,
                            height: 5,
                            decoration: BoxDecoration(
                              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.primary.withValues(alpha:0.5),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                      ],
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
}
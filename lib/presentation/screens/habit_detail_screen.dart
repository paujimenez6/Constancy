import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../domain/models/habit_model.dart';
import '../../domain/models/habit_assets.dart';
import '../../domain/models/habit_group_member_model.dart';
import '../providers/habit_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/social_provider.dart';
import '../../generated/l10n.dart';
import 'habit_form_screen.dart';
import 'other_profile_screen.dart';

class HabitDetailScreen extends StatefulWidget {
  final String habitId;
  const HabitDetailScreen({super.key, required this.habitId});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  late HabitProvider _habitProviderReference;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final habitProv = context.read<HabitProvider>();
      final habit = habitProv.habits.firstWhere(
            (h) => h.id == widget.habitId,
        orElse: () => habitProv.habits.first,
      );
      if (habit.isGroup) {
        habitProv.loadGroupDetails(widget.habitId);
        habitProv.listenToGroupChanges(widget.habitId);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _habitProviderReference = Provider.of<HabitProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _habitProviderReference.stopListeningToGroupChanges();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider = context.watch<HabitProvider>();
    final authProvider = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final strings = S.of(context);
    final dateFormat = DateFormat.yMMMMd(Intl.getCurrentLocale());

    final habit = habitProvider.habits.firstWhere(
          (h) => h.id == widget.habitId,
      orElse: () => habitProvider.habits.first,
    );

    bool isUserAdmin = !habit.isGroup;
    if (habit.isGroup) {
      final myId = authProvider.currentUser?.id;
      final myMemberData = habitProvider.currentGroupMembers.firstWhere(
            (m) => m.userId == myId,
        orElse: () => HabitGroupMember(
            userId: '',
            nickname: '',
            progresAcumulat: 0,
            progresAvui: 0,
            esAdministrador: false
        ),
      );
      isUserAdmin = myMemberData.esAdministrador;
    }

    final record = habitProvider.dailyRecords[habit.id];
    final double progresActual = record?.valorProgres ?? 0.0;

    final bool isGroup = habit.isGroup;
    final double progresCercle = isGroup
        ? habitProvider.currentGroupTotalProgress
        : progresActual;

    final double valorObj = habit.valorObjectiu > 0 ? habit.valorObjectiu : 1.0;
    final double percentatge = (progresCercle / valorObj).clamp(0.0, 1.0);
    final habitColor = HabitAssets.hexToColor(habit.color);

    return Scaffold(
      appBar: AppBar(
        title: Text(habit.titol, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          if (habit.isGroup)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(Icons.groups_rounded, color: theme.colorScheme.primary),
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (value) => _handleMenuAction(context, value, habit, isUserAdmin),
            itemBuilder: (context) {
              final List<PopupMenuEntry<String>> menuItems = [];

              if (isUserAdmin) {
                menuItems.addAll([
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
                ]);
              } else {
                menuItems.add(
                  PopupMenuItem(
                    value: 'leave',
                    child: ListTile(
                      leading: const Icon(Icons.logout_rounded, color: Colors.orange),
                      title: Text(strings.leaveAction, style: const TextStyle(color: Colors.orange)),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                );
              }

              return menuItems;
            },
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
                _buildChip(theme, Icons.category_outlined, habit.grup!),
                const SizedBox(height: 12),
              ],

              _buildChip(
                  theme,
                  Icons.calendar_month_outlined,
                  "${dateFormat.format(habit.dataInici)} - ${habit.dataFi != null ? dateFormat.format(habit.dataFi!) : "/"}"
              ),

              if (habit.recordatoris && habit.horesRecordatori.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildChip(
                    theme,
                    Icons.notifications_active_outlined,
                    habit.horesRecordatori.join(' • ')
                ),
              ],

              const SizedBox(height: 30),

              _buildProgressCircle(context, habit, progresActual, progresCercle, percentatge, habitColor, theme),

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
                  _buildCommentButton(context, habit, theme),
                ],
              ),

              if (habit.isGroup) ...[
                const SizedBox(height: 40),
                _buildGroupSection(context, habitProvider, theme, strings),
              ],

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(ThemeData theme, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant
              )
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCircle(BuildContext context, HabitModel habit, double individual, double actualCercle, double percentatge, Color habitColor, ThemeData theme) {
    final habitProvider = context.read<HabitProvider>();
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 220, height: 220,
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
              icon: Icons.remove_rounded, color: habitColor,
              onPressed: () {
                double nouVal = (individual - 1).clamp(0.0, double.infinity);
                habitProvider.updateProgress(
                    habitId: habit.id,
                    valorProgres: nouVal,
                    completat: nouVal >= habit.valorObjectiu
                );
              },
            ),
          ),
          Positioned(
            right: 25,
            child: _CircleActionButton(
              icon: Icons.add_rounded, color: habitColor,
              onPressed: () {
                double nouVal = individual + 1;
                habitProvider.updateProgress(
                    habitId: habit.id,
                    valorProgres: nouVal,
                    completat: nouVal >= habit.valorObjectiu
                );
              },
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(HabitAssets.getIconByName(habit.icona), color: habitColor, size: 45),
              const SizedBox(height: 4),
              Text("${(percentatge * 100).toInt()}%", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              Text(
                  "${actualCercle % 1 == 0 ? actualCercle.toInt() : actualCercle} / ${habit.valorObjectiu % 1 == 0 ? habit.valorObjectiu.toInt() : habit.valorObjectiu}",
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14, fontWeight: FontWeight.w600)
              ),
              Text(habit.unitatMesura.getLocalizedString(context), style: TextStyle(color: theme.colorScheme.outline, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentButton(BuildContext context, HabitModel habit, ThemeData theme) {
    return Container(
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
    );
  }

  Widget _buildGroupSection(BuildContext context, HabitProvider prov, ThemeData theme, S strings) {
    final myId = context.read<AuthProvider>().currentUser?.id;

    final bool isToday = prov.selectedDate.day == DateTime.now().day &&
        prov.selectedDate.month == DateTime.now().month &&
        prov.selectedDate.year == DateTime.now().year;

    final String dateLabel = isToday ? strings.today : DateFormat.Md(Intl.getCurrentLocale()).format(prov.selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.invitationCode.toUpperCase(),
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.outline,
              letterSpacing: 1
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              const Icon(Icons.key_rounded, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  prov.currentInviteCode ?? "---",
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      fontFamily: 'monospace'
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded),
                onPressed: () {
                  if (prov.currentInviteCode != null) {
                    Clipboard.setData(ClipboardData(text: prov.currentInviteCode!));
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(strings.invitationCopied))
                    );
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        Text(
          strings.members.toUpperCase(),
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.outline,
              letterSpacing: 1
          ),
        ),
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
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => OtherProfileScreen(userData: targetUser)
                    ));
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMe ? theme.colorScheme.primary.withValues(alpha: 0.05) : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: isMe
                            ? theme.colorScheme.primary.withValues(alpha: 0.3)
                            : theme.colorScheme.outlineVariant.withValues(alpha: 0.5)
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text(member.nickname[0].toUpperCase()),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                member.nickname,
                                style: const TextStyle(fontWeight: FontWeight.bold)
                            ),
                            if (member.esAdministrador)
                              Text(
                                  strings.groupAdmin,
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold
                                  )
                              ),
                          ],
                        ),
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "${member.progresAcumulat.toInt()}",
                                  style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (member.progresAvui > 0)
                            Text(
                              "+${member.progresAvui.toInt()} $dateLabel",
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.bold
                              ),
                            )
                          else
                            Text(
                              strings.noActivityToday,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: theme.colorScheme.outline
                              ),
                            ),
                        ],
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

  void _handleMenuAction(BuildContext context, String action, HabitModel currentHabit, bool isAdmin) {
    final strings = S.of(context);
    final provider = context.read<HabitProvider>();
    if (action == 'edit') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => HabitFormScreen(habitToEdit: currentHabit)));
    } else if (action == 'archive') {
      _showConfirmDialog(context, title: strings.archiveHabitConfirm, message: strings.archiveHabitMessage, onConfirm: () async => await provider.archiveHabit(currentHabit.id, true));
    } else if (action == 'delete') {
      _showConfirmDialog(context, title: strings.deleteHabitConfirm, message: strings.deleteHabitMessage, isDestructive: true, onConfirm: () async => await provider.deleteHabit(currentHabit.id));
    } else if (action == 'leave') {
      _showConfirmDialog(context, title: strings.leaveHabitConfirm, message: strings.leaveHabitMessage, isDestructive: true, onConfirm: () async => await provider.leaveGroup(currentHabit.id));
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
            style: ElevatedButton.styleFrom(
                backgroundColor: isDestructive ? Colors.red : Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 0
            ),
            child: Text(isDestructive
                ? (title == strings.leaveHabitConfirm ? strings.leaveAction : strings.remove)
                : strings.confirm),
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
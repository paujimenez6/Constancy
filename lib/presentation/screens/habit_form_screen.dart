import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../domain/models/habit_model.dart';
import '../../domain/models/habit_assets.dart';
import '../providers/habit_provider.dart';
import '../providers/auth_provider.dart';
import '../../generated/l10n.dart';

class HabitFormScreen extends StatefulWidget {
  final HabitModel? habitToEdit;

  const HabitFormScreen({super.key, this.habitToEdit});

  @override
  State<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends State<HabitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController _titolController;
  late TextEditingController _descripcioController;
  late TextEditingController _grupController;
  late TextEditingController _valorObjectiuController;

  late DateTime _dataInici;
  DateTime? _dataFi;

  late String _selectedIcon;
  late String _selectedColor;
  late PeriodeObjectiu _selectedPeriode;
  late UnitatMesura _selectedUnitat;

  @override
  void initState() {
    super.initState();
    final h = widget.habitToEdit;

    _titolController = TextEditingController(text: h?.titol ?? '');
    _descripcioController = TextEditingController(text: h?.descripcio ?? '');
    _grupController = TextEditingController(text: h?.grup ?? '');
    _valorObjectiuController = TextEditingController(
        text: h != null ? (h.valorObjectiu % 1 == 0 ? h.valorObjectiu.toInt().toString() : h.valorObjectiu.toString()) : '1'
    );

    _dataInici = h?.dataInici ?? DateTime.now();
    _dataFi = h?.dataFi;

    _selectedIcon = h?.icona ?? 'star';
    _selectedColor = h?.color ?? HabitAssets.colors.first;
    _selectedPeriode = h?.periodeObjectiu ?? PeriodeObjectiu.diari;
    _selectedUnitat = h?.unitatMesura ?? UnitatMesura.vegades;
  }

  @override
  void dispose() {
    _titolController.dispose();
    _descripcioController.dispose();
    _grupController.dispose();
    _valorObjectiuController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataInici,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _dataInici) {
      setState(() {
        _dataInici = picked;
        if (_dataFi != null && _dataInici.isAfter(_dataFi!)) {
          _dataFi = null;
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataFi ?? _dataInici.add(const Duration(days: 1)),
      firstDate: _dataInici,
      lastDate: DateTime(2101),
      helpText: S.of(context).endDate,
    );
    if (picked != null) {
      setState(() => _dataFi = picked);
    }
  }

  Future<void> _guardarHabit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final strings = S.of(context);

    try {
      final userId = context.read<AuthProvider>().currentUser!.id;
      final habitProvider = context.read<HabitProvider>();
      final valorObj = double.tryParse(_valorObjectiuController.text) ?? 1.0;

      final habit = HabitModel(
        id: widget.habitToEdit?.id ?? '',
        userId: userId,
        titol: _titolController.text.trim(),
        descripcio: _descripcioController.text.trim(),
        grup: _grupController.text.trim(),
        icona: _selectedIcon,
        color: _selectedColor,
        periodeObjectiu: _selectedPeriode,
        valorObjectiu: valorObj,
        unitatMesura: _selectedUnitat,
        dataInici: _dataInici,
        dataFi: _dataFi,
        createdAt: widget.habitToEdit?.createdAt ?? DateTime.now(),
        arxivat: widget.habitToEdit?.arxivat ?? false,
      );

      if (widget.habitToEdit == null) {
        await habitProvider.createHabit(habit);
      } else {
        await habitProvider.updateHabit(habit);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.errorSavingHabit(e.toString())), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = S.of(context);
    final colorActual = HabitAssets.hexToColor(_selectedColor);
    final dateFormat = DateFormat.yMMMMd(Intl.getCurrentLocale());

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          title: Text(widget.habitToEdit == null ? strings.newHabitTitle : strings.editHabitTitle,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorActual.withValues(alpha:0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      HabitAssets.getIconByName(_selectedIcon),
                      size: 60,
                      color: colorActual,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                TextFormField(
                  controller: _titolController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: strings.habitTitleLabel,
                    hintText: strings.habitTitleHint,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.title),
                  ),
                  validator: (v) => v == null || v.isEmpty ? strings.habitTitleRequired : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descripcioController,
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                  minLines: 1,
                  maxLength: 100,
                  decoration: InputDecoration(
                    labelText: strings.habitDescLabel,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.notes),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _grupController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: strings.habitGroupLabel,
                    hintText: strings.habitGroupHint,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.category_outlined),
                  ),
                ),
                const SizedBox(height: 32),

                Text(strings.habitObjective, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _valorObjectiuController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textInputAction: TextInputAction.done,
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                        decoration: InputDecoration(
                          labelText: strings.habitQuantity,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (v) => v == null || v.isEmpty ? strings.requiredField : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<UnitatMesura>(
                        initialValue: _selectedUnitat,
                        decoration: InputDecoration(
                          labelText: strings.habitUnit,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: UnitatMesura.values.map((u) => DropdownMenuItem(
                          value: u,
                          child: Text(u.getLocalizedString(context).toUpperCase()),
                        )).toList(),
                        onChanged: (val) => setState(() => _selectedUnitat = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<PeriodeObjectiu>(
                  initialValue: _selectedPeriode,
                  decoration: InputDecoration(
                    labelText: strings.habitFrequency,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.calendar_today),
                    fillColor: widget.habitToEdit != null ? theme.colorScheme.surfaceContainerHighest.withValues(alpha:0.5) : null,
                    filled: widget.habitToEdit != null,
                  ),
                  items: PeriodeObjectiu.values.map((p) => DropdownMenuItem(
                    value: p,
                    enabled: widget.habitToEdit == null,
                    child: Text(p.getLocalizedString(context).toUpperCase()),
                  )).toList(),
                  onChanged: widget.habitToEdit == null
                      ? (val) => setState(() => _selectedPeriode = val!)
                      : null,
                ),
                const SizedBox(height: 16),

                InkWell(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    _selectStartDate(context);
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: strings.startDate,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                    child: Text(dateFormat.format(_dataInici)),
                  ),
                ),
                const SizedBox(height: 16),

                InkWell(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    _selectEndDate(context);
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: strings.endDate,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.event_busy),
                      suffixIcon: _dataFi != null
                          ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => setState(() => _dataFi = null),
                      )
                          : null,
                    ),
                    child: Text(_dataFi != null ? dateFormat.format(_dataFi!) : strings.none),
                  ),
                ),

                const SizedBox(height: 32),

                Text(strings.habitIcon, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: HabitAssets.icons.entries.map((entry) {
                    final isSelected = _selectedIcon == entry.key;
                    return InkWell(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        setState(() => _selectedIcon = entry.key);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? colorActual.withValues(alpha:0.2) : theme.colorScheme.surfaceContainerHighest.withValues(alpha:0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSelected ? colorActual : Colors.transparent, width: 2),
                        ),
                        child: Icon(entry.value, color: isSelected ? colorActual : theme.colorScheme.onSurfaceVariant),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),

                Text(strings.habitColor, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: HabitAssets.colors.map((hex) {
                    final color = HabitAssets.hexToColor(hex);
                    final isSelected = _selectedColor == hex;
                    return InkWell(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        setState(() => _selectedColor = hex);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected ? Border.all(color: theme.colorScheme.onSurface, width: 3) : null,
                          boxShadow: [
                            if (isSelected) BoxShadow(color: color.withValues(alpha:0.4), blurRadius: 8, offset: const Offset(0, 2))
                          ],
                        ),
                        child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 48),

                ElevatedButton(
                  onPressed: _isLoading ? null : _guardarHabit,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                  )
                      : Text(strings.saveHabit, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
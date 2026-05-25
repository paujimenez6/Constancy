import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:Constancy/domain/services/habit_service.dart';
import 'package:Constancy/persistence/repositories/habit_repository.dart';
import 'package:Constancy/domain/models/habit_model.dart';
import 'package:Constancy/domain/models/habit_record_model.dart';
import 'package:Constancy/domain/models/user_model.dart';

class MockHabitRepository extends Mock implements HabitRepository {}
class MockRealtimeChannel extends Mock implements RealtimeChannel {}
class MockBuildContext extends Mock implements BuildContext {}

void main() {
  late HabitService service;
  late MockHabitRepository mockRepository;

  setUpAll(() {
    initializeDateFormatting();
    registerFallbackValue(DateTime.now());
    registerFallbackValue(HabitModel(id: '1', userId: 'u', titol: 'T', icona: 'i', color: 'c', dataInici: DateTime.now(), createdAt: DateTime.now()));
    registerFallbackValue(TipusPrivacitat.public);
  });

  setUp(() {
    mockRepository = MockHabitRepository();
    service = HabitService(mockRepository);
  });

  group('HabitService 100% Coverage', () {
    final now = DateTime(2026, 5, 21);

    test('1. Mètodes delegats simples (CRUD i Grups)', () async {
      when(() => mockRepository.currentUserId).thenReturn('u1');
      when(() => mockRepository.getHabits()).thenAnswer((_) async => []);
      when(() => mockRepository.deleteHabit(any())).thenAnswer((_) async => {});
      when(() => mockRepository.getRecordsForDate(any())).thenAnswer((_) async => []);
      when(() => mockRepository.getRecordsForRange(any(), any())).thenAnswer((_) async => []);
      when(() => mockRepository.getAllRecords()).thenAnswer((_) async => []);
      when(() => mockRepository.joinByCode(any(), any())).thenAnswer((_) async => {});
      when(() => mockRepository.getHabitsByUserId(any())).thenAnswer((_) async => []);
      when(() => mockRepository.getGroupInviteCode(any())).thenAnswer((_) async => 'code');
      when(() => mockRepository.getGroupMembers(any(), any())).thenAnswer((_) async => []);
      when(() => mockRepository.getGroupTotalProgress(any(), any())).thenAnswer((_) async => 0.0);
      when(() => mockRepository.subscribeToGroupChanges(any(), any())).thenReturn(MockRealtimeChannel());
      when(() => mockRepository.leaveGroupHabit(any(), any())).thenAnswer((_) async => {});
      when(() => mockRepository.getGroupRecordsForRange(any(), any(), any())).thenAnswer((_) async => []);
      when(() => mockRepository.getAllRecordsForHabit(any())).thenAnswer((_) async => []);
      when(() => mockRepository.saveRecord(habitId: any(named: 'habitId'), date: any(named: 'date'), valorProgres: any(named: 'valorProgres'), completat: any(named: 'completat'), comentari: any(named: 'comentari'))).thenAnswer((_) async => {});

      expect(service.currentUserId, 'u1');
      await service.getHabits();
      await service.deleteHabit('h1');
      await service.getRecordsForDate(now);
      await service.getRecordsForRange(now, now);
      await service.getAllRecords();
      await service.joinGroup('u1', 'code');
      await service.getHabitsByUserId('u2');
      await service.getGroupInviteCode('h1');
      await service.getGroupMembers('h1', now);
      await service.getGroupTotalProgress('h1', now);
      service.subscribeToGroupChanges('h1', () {});
      await service.leaveGroupHabit('h1', 'u1');
      await service.getGroupRecordsForRange('h1', now, now);
      await service.getAllRecordsForHabit('h1');
      await service.processProgressUpdate(habitId: '1', date: now, valorProgres: 1.0, completat: true, comentari: 'test');
    });

    test('2. createHabit, updateHabit i _syncRecordsWithNewGoal', () async {
      final habitGrup = HabitModel(id: '1', userId: 'u', titol: 'T', icona: 'i', color: 'c', dataInici: now, createdAt: now, isGroup: true, valorObjectiu: 10);
      final habitNormal = habitGrup.copyWith(isGroup: false);
      final oldHabit = habitNormal.copyWith(valorObjectiu: 5);
      final record = HabitRecordModel(id: 'r1', habitId: '1', userId: 'u', dataRegistre: now, completat: true, valorProgres: 7, createdAt: now, updatedAt: now);

      when(() => mockRepository.createGroupHabit(any(), any())).thenAnswer((_) async => habitGrup);
      when(() => mockRepository.createHabit(any())).thenAnswer((_) async => habitNormal);
      when(() => mockRepository.getHabits()).thenAnswer((_) async => [oldHabit]);
      when(() => mockRepository.updateHabit(any())).thenAnswer((_) async => {});
      when(() => mockRepository.getAllRecordsForHabit('1')).thenAnswer((_) async => [record]);
      when(() => mockRepository.saveRecord(habitId: any(named: 'habitId'), date: any(named: 'date'), valorProgres: any(named: 'valorProgres'), completat: any(named: 'completat'), comentari: any(named: 'comentari'))).thenAnswer((_) async => {});
      when(() => mockRepository.updateHabitStreaks('1', any(), any())).thenAnswer((_) async => {});

      await service.createHabit(habitGrup);
      await service.createHabit(habitNormal);
      await service.updateHabit(habitNormal);

      expect(service.generateInviteCode(), startsWith('CONST-'));
    });

    test('3. filterHabitsForDate i getArchivedHabits', () {
      final habitDiari = HabitModel(id: '1', userId: 'u', titol: 'D', icona: 'i', color: 'c', dataInici: now, createdAt: now, periodeObjectiu: PeriodeObjectiu.diari, dataFi: now.add(const Duration(days: 10)), arxivat: true);
      final habitSetmanal = HabitModel(id: '2', userId: 'u', titol: 'S', icona: 'i', color: 'c', dataInici: now, createdAt: now, periodeObjectiu: PeriodeObjectiu.setmanal);
      final habitMensual = HabitModel(id: '3', userId: 'u', titol: 'M', icona: 'i', color: 'c', dataInici: now, createdAt: now, periodeObjectiu: PeriodeObjectiu.mensual);

      final list = [habitDiari, habitSetmanal, habitMensual];

      expect(service.getArchivedHabits(list).length, 1);

      final filtrats = service.filterHabitsForDate(list, now, includeArchived: true);
      expect(filtrats.length, 3);

      final foraDeData = service.filterHabitsForDate([habitDiari], now.add(const Duration(days: 20)));
      expect(foraDeData.isEmpty, isTrue);

      final extremMes = DateTime(2026, 2, 28);
      final habitMensualExtrem = HabitModel(id: '4', userId: 'u', titol: 'M2', icona: 'i', color: 'c', dataInici: DateTime(2026, 1, 31), createdAt: now, periodeObjectiu: PeriodeObjectiu.mensual);
      service.filterHabitsForDate([habitMensualExtrem], extremMes);
    });

    test('4. recalculateAndSaveStreaks i Helpers (diari, setmanal, mensual)', () async {
      final hDiari = HabitModel(id: '1', userId: 'u', titol: 'D', icona: 'i', color: 'c', dataInici: now, createdAt: now, periodeObjectiu: PeriodeObjectiu.diari);
      final hSetmanal = HabitModel(id: '2', userId: 'u', titol: 'S', icona: 'i', color: 'c', dataInici: now, createdAt: now, periodeObjectiu: PeriodeObjectiu.setmanal);
      final hMensual = HabitModel(id: '3', userId: 'u', titol: 'M', icona: 'i', color: 'c', dataInici: now, createdAt: now, periodeObjectiu: PeriodeObjectiu.mensual);

      final avui = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

      final recordsD = [
        HabitRecordModel(id: 'r1', habitId: '1', userId: 'u', dataRegistre: avui.subtract(const Duration(days: 1)), completat: true, createdAt: now, updatedAt: now),
        HabitRecordModel(id: 'r2', habitId: '1', userId: 'u', dataRegistre: avui, completat: true, createdAt: now, updatedAt: now),
      ];
      final recordsS = [
        HabitRecordModel(id: 'r3', habitId: '2', userId: 'u', dataRegistre: avui.subtract(const Duration(days: 7)), completat: true, createdAt: now, updatedAt: now),
        HabitRecordModel(id: 'r4', habitId: '2', userId: 'u', dataRegistre: avui, completat: true, createdAt: now, updatedAt: now),
      ];
      final recordsM = [
        HabitRecordModel(id: 'r5', habitId: '3', userId: 'u', dataRegistre: DateTime(avui.year, avui.month - 1, avui.day), completat: true, createdAt: now, updatedAt: now),
        HabitRecordModel(id: 'r6', habitId: '3', userId: 'u', dataRegistre: avui, completat: true, createdAt: now, updatedAt: now),
      ];

      when(() => mockRepository.getHabits()).thenAnswer((_) async => [hDiari, hSetmanal, hMensual]);
      when(() => mockRepository.getAllRecordsForHabit('1')).thenAnswer((_) async => recordsD);
      when(() => mockRepository.getAllRecordsForHabit('2')).thenAnswer((_) async => recordsS);
      when(() => mockRepository.getAllRecordsForHabit('3')).thenAnswer((_) async => recordsM);
      when(() => mockRepository.updateHabitStreaks(any(), any(), any())).thenAnswer((_) async => {});

      await service.recalculateAndSaveStreaks('1');
      await service.recalculateAndSaveStreaks('2');
      await service.recalculateAndSaveStreaks('3');

      when(() => mockRepository.getAllRecordsForHabit('1')).thenAnswer((_) async => []);
      await service.recalculateAndSaveStreaks('1');
    });

    test('5. calculateStats (Branques: amb ID, sense ID, perfect days)', () {
      final habit1 = HabitModel(id: '1', userId: 'u', titol: 'H1', icona: 'i', color: 'c', dataInici: now, createdAt: now, valorObjectiu: 1, periodeObjectiu: PeriodeObjectiu.diari);
      final habit2 = HabitModel(id: '2', userId: 'u', titol: 'H2', icona: 'i', color: 'c', dataInici: now, createdAt: now, valorObjectiu: 1, periodeObjectiu: PeriodeObjectiu.diari);

      final records = [
        HabitRecordModel(id: 'r1', habitId: '1', userId: 'u', dataRegistre: now, valorProgres: 1, completat: true, createdAt: now, updatedAt: now),
        HabitRecordModel(id: 'r2', habitId: '2', userId: 'u', dataRegistre: now, valorProgres: 0, completat: false, createdAt: now, updatedAt: now),
      ];

      final statsAll = service.calculateStats(allHabits: [habit1, habit2], records: records, startDate: now, endDate: now);
      expect(statsAll.totalExpected, 2);
      expect(statsAll.starHabit?.id, '1');

      final statsSingle = service.calculateStats(allHabits: [habit1, habit2], records: records, startDate: now, endDate: now, selectedHabitId: '1');
      expect(statsSingle.perfectDays, 1);
    });

    test('6. getChartData (Mensual vs Anual, Cumulative vs Non, Habit selected vs Null)', () {
      final habit = HabitModel(id: '1', userId: 'u', titol: 'H1', icona: 'i', color: 'c', dataInici: now, createdAt: now);
      final actualNow = DateTime.now();
      final record = HabitRecordModel(id: 'r1', habitId: '1', userId: 'u', dataRegistre: DateTime(actualNow.year, actualNow.month, 1), valorProgres: 5, completat: true, createdAt: now, updatedAt: now);

      service.getChartData(records: [record], isMensual: true, referenceDate: actualNow);
      service.getChartData(records: [record], isMensual: true, referenceDate: actualNow, selectedHabit: habit, isCumulative: true);
      service.getChartData(records: [record], isMensual: false, referenceDate: actualNow);
      service.getChartData(records: [record], isMensual: false, referenceDate: actualNow, selectedHabit: habit, isCumulative: true);
    });

    test('7. Shields i Helpers UI', () async {
      final habit = HabitModel(id: '1', userId: 'u', titol: 'H1', icona: 'i', color: 'c', dataInici: now, createdAt: now, arxivat: false);

      when(() => mockRepository.applyStreakShield(any(), any(), any())).thenAnswer((_) async => {});
      when(() => mockRepository.unshieldDate(any(), any())).thenAnswer((_) async => {});
      when(() => mockRepository.getHabits()).thenAnswer((_) async => [habit]);
      when(() => mockRepository.getAllRecordsForHabit(any())).thenAnswer((_) async => []);
      when(() => mockRepository.updateHabitStreaks(any(), any(), any())).thenAnswer((_) async => {});

      final recordShielded = HabitRecordModel(id: 'rs', habitId: '1', userId: 'u', dataRegistre: now, completat: false, isShielded: true, createdAt: now, updatedAt: now);
      when(() => mockRepository.getRecordsForDate(now)).thenAnswer((_) async => [recordShielded]);

      await service.applyShield('u1', now, 'i1');
      await service.removeShieldFromDate('u1', now);

      expect(await service.isDateShielded(now), isTrue);

      expect(service.canSeeHabits(currentUserId: '1', targetUserId: '2', privacitat: TipusPrivacitat.public, isFollowing: false), isTrue);
      expect(service.canSeeHabits(currentUserId: '1', targetUserId: '2', privacitat: TipusPrivacitat.amics, isFollowing: true), isTrue);
      expect(service.canSeeHabits(currentUserId: '1', targetUserId: '2', privacitat: TipusPrivacitat.amics, isFollowing: false), isFalse);
      expect(service.canSeeHabits(currentUserId: '1', targetUserId: '1', privacitat: TipusPrivacitat.privat, isFollowing: false), isTrue);

      expect(service.getLocalizedMonths(), isNotEmpty);
      expect(service.getMonthLabels(MockBuildContext()), isNotEmpty);
      expect(service.getUniqueCategories([habit.copyWith(grup: 'Salut')]), ['Salut']);
    });
  });
}
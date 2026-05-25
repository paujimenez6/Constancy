import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:Constancy/presentation/providers/habit_provider.dart';
import 'package:Constancy/domain/services/habit_service.dart';
import 'package:Constancy/domain/services/mission_service.dart';
import 'package:Constancy/domain/services/achievement_service.dart';
import 'package:Constancy/domain/models/habit_model.dart';
import 'package:Constancy/domain/models/habit_record_model.dart';
import 'package:Constancy/domain/models/stats_model.dart';
import 'package:Constancy/domain/models/chart_data_model.dart';

class MockHabitService extends Mock implements HabitService {}
class MockMissionService extends Mock implements MissionService {}
class MockAchievementService extends Mock implements AchievementService {}
class MockRealtimeChannel extends Mock implements RealtimeChannel {}

void main() {
  late HabitProvider provider;
  late MockHabitService mockHabitService;
  late MockMissionService mockMissionService;
  late MockAchievementService mockAchievementService;

  HabitModel createHabit(String id, bool isGroup, {String group = 'CatA'}) => HabitModel(
      id: id, userId: 'u1', titol: 'Test', icona: 'star', color: '#000',
      grup: group, dataInici: DateTime(2026), createdAt: DateTime.now(),
      isGroup: isGroup, millorRatxa: 5, valorObjectiu: 1.0, arxivat: false
  );

  HabitRecordModel createRecord(String habitId, double progress, {bool shielded = false}) => HabitRecordModel(
      id: 'r1', habitId: habitId, userId: 'u1', dataRegistre: DateTime.now(),
      valorProgres: progress, createdAt: DateTime.now(), updatedAt: DateTime.now(),
      isShielded: shielded, completat: progress >= 1.0
  );

  setUpAll(() {
    registerFallbackValue(createHabit('fallback', false));
    registerFallbackValue(DateTime.now());
  });

  setUp(() {
    mockHabitService = MockHabitService();
    mockMissionService = MockMissionService();
    mockAchievementService = MockAchievementService();
    provider = HabitProvider(mockHabitService, mockMissionService, mockAchievementService);

    when(() => mockHabitService.currentUserId).thenReturn('u1');
  });

  group('HabitProvider 100% Coverage', () {

    test('Cobertura de Getters Simples', () async {
      final tHabit = createHabit('h1', false);

      when(() => mockHabitService.getHabits()).thenAnswer((_) async => [tHabit]);
      when(() => mockHabitService.getRecordsForDate(any())).thenAnswer((_) async => []);
      await provider.loadDataForDate(DateTime.now());

      expect(provider.profileHabits, isEmpty);
      expect(provider.selectedDate.day, DateTime.now().day);
      expect(provider.isLoading, false);
      expect(provider.focusedMonth.month, DateTime.now().month);
      expect(provider.monthlyRecords, isEmpty);
      expect(provider.allTimeRecords, isEmpty);
      expect(provider.currentGroupMembers, isEmpty);
      expect(provider.currentInviteCode, isNull);
      expect(provider.currentGroupTotalProgress, 0.0);
      expect(provider.groupAggregatedMonthlyRecords, isEmpty);

      when(() => mockHabitService.getArchivedHabits(any())).thenReturn([]);
      expect(provider.archivedHabits, isEmpty);

      when(() => mockHabitService.getUniqueCategories(any())).thenReturn(['CatA']);
      expect(provider.availableCategories, ['CatA']);

      when(() => mockHabitService.getLocalizedMonths()).thenReturn(['Gen']);
      expect(provider.getMonthLabels(), ['Gen']);
    });

    test('loadDataForDate i listenToAllVisibleGroups', () async {
      final tHabitGrupal = createHabit('g1', true);

      when(() => mockHabitService.getHabits()).thenAnswer((_) async => [tHabitGrupal]);
      when(() => mockHabitService.getRecordsForDate(any())).thenAnswer((_) async => []);
      when(() => mockHabitService.getGroupTotalProgress('g1', any())).thenAnswer((_) async => 10.0);
      when(() => mockHabitService.filterHabitsForDate(any(), any(), includeArchived: any(named: 'includeArchived'))).thenReturn([tHabitGrupal]);

      await provider.loadDataForDate(DateTime.now());

      final mockChannel = MockRealtimeChannel();
      when(() => mockChannel.unsubscribe()).thenAnswer((_) async => 'ok');
      when(() => mockHabitService.subscribeToGroupChanges(any(), any())).thenReturn(mockChannel);

      provider.listenToAllVisibleGroups();

      final captured = verify(() => mockHabitService.subscribeToGroupChanges('g1', captureAny())).captured;
      final callback = captured.first as Function;
      await callback();

      provider.stopListeningToAllGroups();
    });

    test('updateProgress: lògica completa (escuts, missions, ratxa, dia perfecte, descompletar)', () async {
      final tHabitNormal = createHabit('h1', false);
      final tRecord = createRecord('h1', 0.0, shielded: true);

      when(() => mockHabitService.getHabits()).thenAnswer((_) async => [tHabitNormal]);
      when(() => mockHabitService.getRecordsForDate(any())).thenAnswer((_) async => [tRecord]);
      when(() => mockHabitService.filterHabitsForDate(any(), any(), includeArchived: any(named: 'includeArchived'))).thenReturn([tHabitNormal]);
      await provider.loadDataForDate(DateTime.now());

      when(() => mockHabitService.removeShieldFromDate('u1', any())).thenAnswer((_) async => {});
      when(() => mockHabitService.processProgressUpdate(habitId: any(named: 'habitId'), date: any(named: 'date'), valorProgres: any(named: 'valorProgres'), completat: any(named: 'completat'), comentari: any(named: 'comentari'))).thenAnswer((_) async => {});
      when(() => mockAchievementService.updateProgress('u1', 'completatHabits50', 1)).thenAnswer((_) async => {});
      when(() => mockAchievementService.updateProgress('u1', 'completatHabits50', -1)).thenAnswer((_) async => {});
      when(() => mockMissionService.updateProgress('u1', 'habits', 1.0, 'h1')).thenAnswer((_) async => {});
      when(() => mockMissionService.updateProgress('u1', 'perfect_day', 1.0, any())).thenAnswer((_) async => {});
      when(() => mockAchievementService.syncPerfectDay('u1', any(), any())).thenAnswer((_) async => {});
      when(() => mockAchievementService.setAbsoluteProgress('u1', 'ratxa50', 5)).thenAnswer((_) async => {});
      when(() => mockHabitService.getRecordsForRange(any(), any())).thenAnswer((_) async => []);
      when(() => mockHabitService.getAllRecords()).thenAnswer((_) async => []);

      await provider.updateProgress(habitId: 'h1', valorProgres: 1.0, completat: true);

      final tRecordCompletat = createRecord('h1', 1.0);
      when(() => mockHabitService.getRecordsForDate(any())).thenAnswer((_) async => [tRecordCompletat]);
      await provider.loadDataForDate(DateTime.now());

      await provider.updateProgress(habitId: 'h1', valorProgres: 0.0, completat: false);
      verify(() => mockAchievementService.updateProgress('u1', 'completatHabits50', -1)).called(1);
    });

    test('updateProgress: catch error', () async {
      when(() => mockHabitService.processProgressUpdate(habitId: any(named: 'habitId'), date: any(named: 'date'), valorProgres: any(named: 'valorProgres'), completat: any(named: 'completat'), comentari: any(named: 'comentari')))
          .thenThrow(Exception('Fail'));

      expect(() => provider.updateProgress(habitId: 'h1', valorProgres: 1.0, completat: true), throwsException);
    });

    test('CRUD Habits', () async {
      final tHabitNormal = createHabit('h1', false);
      final tHabitGrupal = createHabit('g1', true);

      when(() => mockHabitService.createHabit(any())).thenAnswer((_) async => tHabitGrupal);
      when(() => mockHabitService.updateHabit(any())).thenAnswer((_) async => tHabitNormal);
      when(() => mockHabitService.getHabits()).thenAnswer((_) async => [tHabitGrupal, tHabitNormal]);
      when(() => mockHabitService.getRecordsForDate(any())).thenAnswer((_) async => []);
      when(() => mockAchievementService.updateProgress(any(), any(), any())).thenAnswer((_) async => {});
      when(() => mockAchievementService.setAbsoluteProgress(any(), any(), any())).thenAnswer((_) async => {});
      when(() => mockHabitService.getGroupTotalProgress(any(), any())).thenAnswer((_) async => 0.0);
      when(() => mockHabitService.getAllRecords()).thenAnswer((_) async => []);
      when(() => mockHabitService.getRecordsForRange(any(), any())).thenAnswer((_) async => []);
      when(() => mockHabitService.filterHabitsForDate(any(), any(), includeArchived: any(named: 'includeArchived'))).thenReturn([tHabitGrupal]);

      final mockChannel = MockRealtimeChannel();
      when(() => mockChannel.unsubscribe()).thenAnswer((_) async => 'ok');
      when(() => mockHabitService.subscribeToGroupChanges(any(), any())).thenReturn(mockChannel);

      await provider.createHabit(tHabitGrupal);
      await provider.updateHabit(tHabitNormal);

      await provider.loadDataForDate(DateTime.now());
      await provider.archiveHabit('g1', true);
      await provider.deleteHabit('g1');
    });

    test('Grups: join, leave, listen i catch errors', () async {
      final tHabitGrupal = createHabit('g1', true);
      when(() => mockHabitService.joinGroup('u1', '123')).thenAnswer((_) async => {});
      when(() => mockHabitService.leaveGroupHabit('g1', 'u1')).thenAnswer((_) async => {});
      when(() => mockHabitService.getHabits()).thenAnswer((_) async => [tHabitGrupal]);
      when(() => mockHabitService.getRecordsForDate(any())).thenAnswer((_) async => []);
      when(() => mockHabitService.getAllRecords()).thenAnswer((_) async => []);
      when(() => mockAchievementService.setAbsoluteProgress(any(), any(), any())).thenAnswer((_) async => {});
      when(() => mockHabitService.filterHabitsForDate(any(), any(), includeArchived: any(named: 'includeArchived'))).thenReturn([]);
      when(() => mockHabitService.getGroupTotalProgress(any(), any())).thenAnswer((_) async => 0.0);

      await provider.loadDataForDate(DateTime.now());

      await provider.joinGroup('u1', '123');
      await provider.leaveGroup('g1');

      when(() => mockHabitService.joinGroup('u1', 'bad1')).thenThrow('invalid_code');
      expect(() => provider.joinGroup('u1', 'bad1'), throwsA('invalid_code'));
      when(() => mockHabitService.joinGroup('u1', 'bad2')).thenThrow(Exception('generic'));
      expect(() => provider.joinGroup('u1', 'bad2'), throwsA('error_generic'));

      when(() => mockHabitService.leaveGroupHabit('g1', 'u1')).thenThrow(Exception('Fail DB'));
      expect(() => provider.leaveGroup('g1'), throwsException);

      final mockChannel = MockRealtimeChannel();
      when(() => mockChannel.unsubscribe()).thenAnswer((_) async => 'ok');
      when(() => mockHabitService.subscribeToGroupChanges('g1', any())).thenReturn(mockChannel);
      when(() => mockHabitService.getGroupInviteCode('g1')).thenAnswer((_) async => 'CODE');
      when(() => mockHabitService.getGroupMembers('g1', any())).thenAnswer((_) async => []);

      provider.listenToGroupChanges('g1');
      final captured = verify(() => mockHabitService.subscribeToGroupChanges('g1', captureAny())).captured;
      final callback = captured.first as Function;
      callback();
    });

    test('loadGroupStatistics i _aggregateRecords', () async {
      final tHabitGrupal = createHabit('g1', true);
      final tRecordGroup1 = HabitRecordModel(id: 'r1', habitId: 'g1', userId: 'u1', dataRegistre: DateTime(2026,1,1), valorProgres: 0.5, createdAt: DateTime.now(), updatedAt: DateTime.now(), completat: false);
      final tRecordGroup2 = HabitRecordModel(id: 'r2', habitId: 'g1', userId: 'u1', dataRegistre: DateTime(2026,1,1), valorProgres: 0.6, createdAt: DateTime.now(), updatedAt: DateTime.now(), completat: false);

      when(() => mockHabitService.getGroupRecordsForRange('g1', any(), any())).thenAnswer((_) async => [tRecordGroup1, tRecordGroup2]);
      when(() => mockHabitService.getAllRecordsForHabit('g1')).thenAnswer((_) async => [tRecordGroup1]);
      when(() => mockHabitService.getHabits()).thenAnswer((_) async => [tHabitGrupal]);
      when(() => mockHabitService.getRecordsForDate(any())).thenAnswer((_) async => []);
      when(() => mockHabitService.getGroupTotalProgress('g1', any())).thenAnswer((_) async => 0.0);
      await provider.loadDataForDate(DateTime.now());

      await provider.loadGroupStatistics('g1', DateTime.now());

      expect(provider.groupAggregatedMonthlyRecords.isNotEmpty, isTrue);
      expect(provider.groupAggregatedMonthlyRecords.first.valorProgres, 1.1);
      expect(provider.groupAggregatedMonthlyRecords.first.completat, isTrue);
    });

    test('loadProfileHabits catch error', () async {
      when(() => mockHabitService.getHabitsByUserId('target')).thenThrow(Exception('Error Profile'));
      await provider.loadProfileHabits('target');
      expect(provider.isLoading, false);
    });

    test('Estadístiques i Gràfics', () async {
      final tHabitNormal = createHabit('h1', false, group: 'CatA');
      when(() => mockHabitService.getHabits()).thenAnswer((_) async => [tHabitNormal]);
      when(() => mockHabitService.getRecordsForDate(any())).thenAnswer((_) async => []);
      await provider.loadDataForDate(DateTime.now());

      when(() => mockHabitService.getChartData(records: any(named: 'records'), isMensual: any(named: 'isMensual'), referenceDate: any(named: 'referenceDate'), selectedHabit: any(named: 'selectedHabit'), isCumulative: any(named: 'isCumulative')))
          .thenReturn([ChartDataPoint(x: 1.0, y: 1.0, label: 'L')]);

      when(() => mockHabitService.calculateStats(allHabits: any(named: 'allHabits'), records: any(named: 'records'), startDate: any(named: 'startDate'), endDate: any(named: 'endDate'), selectedHabitId: any(named: 'selectedHabitId')))
          .thenReturn(HabitStats());

      provider.getStatisticsChartData(isMensual: true, selectedHabit: null, selectedCategory: 'CatA', viewDate: DateTime.now());
      provider.getStatisticsChartData(isMensual: false, selectedHabit: null, selectedCategory: null, viewDate: DateTime.now(), useGroupData: true);

      provider.getStats(isMensual: true);
      provider.getStats(isMensual: false, habitId: 'h1', useGroupData: true);

      when(() => mockHabitService.getHabits()).thenAnswer((_) async => []);
      await provider.loadDataForDate(DateTime.now());
      provider.getStats(isMensual: false, habitId: 'dummy');
    });

    test('Mètodes pass-through: getRecords, changeDate, updateComment, shield, dispose', () async {
      when(() => mockHabitService.getRecordsForRange(any(), any())).thenAnswer((_) async => []);
      when(() => mockHabitService.filterHabitsForDate(any(), any(), includeArchived: true)).thenReturn([]);
      when(() => mockHabitService.applyShield(any(), any(), any())).thenAnswer((_) async => {});
      when(() => mockHabitService.isDateShielded(any())).thenAnswer((_) async => true);
      when(() => mockHabitService.processProgressUpdate(habitId: any(named: 'habitId'), date: any(named: 'date'), valorProgres: any(named: 'valorProgres'), completat: any(named: 'completat'), comentari: any(named: 'comentari'))).thenAnswer((_) async => {});
      when(() => mockHabitService.getRecordsForDate(any())).thenAnswer((_) async => []);
      when(() => mockHabitService.getHabits()).thenAnswer((_) async => []);
      when(() => mockHabitService.getAllRecords()).thenAnswer((_) async => []);

      await provider.getRecordsForRange(DateTime.now(), DateTime.now());
      provider.getExpectedHabitsForDate(DateTime.now());

      await provider.changeDate(DateTime.now());

      await provider.updateComment(habitId: 'h1', comentari: 'Test');

      await provider.useStreakShield('u1', DateTime.now(), 'inv1');
      expect(await provider.isDateShielded(DateTime.now()), true);

      provider.dispose();
    });
  });
}
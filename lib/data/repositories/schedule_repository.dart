import '../../domain/models/models.dart';

class ScheduleRepository {
  final List<Schedule> _schedules = [];

  Future<List<Schedule>> getSchedules() async {
    return List.from(_schedules);
  }

  Future<List<Schedule>> getSchedulesByDate(DateTime date) async {
    return _schedules.where((s) => 
      s.date.year == date.year && 
      s.date.month == date.month && 
      s.date.day == date.day
    ).toList();
  }

  Future<bool> hasConflict(DateTime date, DateTime startTime, DateTime endTime, {String? excludeScheduleId}) async {
    final dailySchedules = await getSchedulesByDate(date);
    
    for (final schedule in dailySchedules) {
      if (excludeScheduleId != null && schedule.id == excludeScheduleId) continue;
      
      if (startTime.isBefore(schedule.endTime) && endTime.isAfter(schedule.startTime)) {
        return true;
      }
    }
    return false;
  }

  Future<void> addSchedule(Schedule schedule) async {
    if (await hasConflict(schedule.date, schedule.startTime, schedule.endTime)) {
      throw Exception('Schedule conflict detected');
    }
    _schedules.add(schedule);
  }

  Future<void> updateSchedule(Schedule schedule) async {
    if (await hasConflict(schedule.date, schedule.startTime, schedule.endTime, excludeScheduleId: schedule.id)) {
      throw Exception('Schedule conflict detected');
    }
    final index = _schedules.indexWhere((s) => s.id == schedule.id);
    if (index != -1) {
      _schedules[index] = schedule.copyWith(updatedAt: DateTime.now());
    }
  }

  Future<void> deleteSchedule(String id) async {
    _schedules.removeWhere((s) => s.id == id);
  }
}

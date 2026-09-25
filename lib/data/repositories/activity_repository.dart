import '../../domain/models/models.dart';

class ActivityRepository {
  final List<Activity> _activities = [];

  Future<List<Activity>> getActivities() async {
    return List.from(_activities);
  }

  Future<List<Activity>> getActivitiesByDate(DateTime date) async {
    return _activities.where((a) => 
      a.date.year == date.year && 
      a.date.month == date.month && 
      a.date.day == date.day
    ).toList();
  }

  Future<void> addActivity(Activity activity) async {
    _activities.add(activity);
  }

  Future<void> updateActivity(Activity activity) async {
    final index = _activities.indexWhere((a) => a.id == activity.id);
    if (index != -1) {
      _activities[index] = activity;
    }
  }

  Future<void> deleteActivity(String id) async {
    _activities.removeWhere((a) => a.id == id);
  }
}

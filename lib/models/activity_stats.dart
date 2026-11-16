import '../services/learning_records_api.dart';
import '../services/learning_upload_queue.dart';

/// 某一種練習（每日複習或小遊戲）的彙總。
class ActivitySnapshot {
  const ActivitySnapshot({
    required this.activityType,
    required this.contextKey,
    required this.bestCorrect,
    required this.bestQuestionCount,
    required this.attempts,
    this.bestPercent,
    this.bestDurationSeconds,
    this.lastRecordedAt,
  });

  final String activityType;
  final String contextKey;
  final int bestCorrect;
  final int bestQuestionCount;
  final int? bestPercent;
  final int? bestDurationSeconds;
  final int attempts;
  final DateTime? lastRecordedAt;

  String get key => '$activityType|$contextKey';

  Map<String, dynamic> toJson() => {
        'activityType': activityType,
        'contextKey': contextKey,
        'bestCorrect': bestCorrect,
        'bestQuestionCount': bestQuestionCount,
        'bestPercent': bestPercent,
        'bestDurationSeconds': bestDurationSeconds,
        'attempts': attempts,
        'lastRecordedAt': lastRecordedAt?.toIso8601String(),
      };

  factory ActivitySnapshot.fromJson(Map<String, dynamic> json) {
    return ActivitySnapshot(
      activityType: json['activityType'] as String? ?? '',
      contextKey: json['contextKey'] as String? ?? '',
      bestCorrect: (json['bestCorrect'] as num?)?.toInt() ?? 0,
      bestQuestionCount: (json['bestQuestionCount'] as num?)?.toInt() ?? 0,
      bestPercent: (json['bestPercent'] as num?)?.toInt(),
      bestDurationSeconds: (json['bestDurationSeconds'] as num?)?.toInt(),
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      lastRecordedAt: json['lastRecordedAt'] == null
          ? null
          : DateTime.tryParse(json['lastRecordedAt'] as String),
    );
  }

  factory ActivitySnapshot.fromCloud(CloudActivitySummary cloud) {
    return ActivitySnapshot(
      activityType: cloud.activityType,
      contextKey: cloud.contextKey ?? '',
      bestCorrect: cloud.bestCorrect,
      bestQuestionCount: cloud.bestQuestionCount,
      bestPercent: cloud.bestPercent,
      bestDurationSeconds: cloud.bestDurationSeconds,
      attempts: cloud.attempts,
      lastRecordedAt: cloud.lastRecordedAt,
    );
  }

  factory ActivitySnapshot.fromPending(PendingLearningRecord item) {
    final total = item.questionCount;
    final percent = total > 0
        ? ((item.correctCount / total) * 100).round().clamp(0, 100)
        : null;
    return ActivitySnapshot(
      activityType: item.activityType,
      contextKey: item.contextKey ?? '',
      bestCorrect: item.correctCount,
      bestQuestionCount: item.questionCount,
      bestPercent: percent,
      bestDurationSeconds: item.durationSeconds,
      attempts: 1,
      lastRecordedAt: item.recordedAt,
    );
  }
}

class ChildActivityStats {
  const ChildActivityStats({
    required this.studyDates,
    required this.activities,
  });

  static const empty = ChildActivityStats(studyDates: [], activities: []);

  /// `yyyy-MM-dd`，伺服器以台北日期、本機未上傳紀錄以裝置本地日期。
  final List<String> studyDates;
  final List<ActivitySnapshot> activities;

  Map<String, dynamic> toJson() => {
        'studyDates': studyDates,
        'activities': activities.map((e) => e.toJson()).toList(),
      };

  factory ChildActivityStats.fromJson(Map<String, dynamic> json) {
    final rawDates = json['studyDates'];
    final rawActivities = json['activities'];
    return ChildActivityStats(
      studyDates: rawDates is List
          ? rawDates.map((e) => e.toString()).toList()
          : const [],
      activities: rawActivities is List
          ? rawActivities
              .whereType<Map>()
              .map((e) => ActivitySnapshot.fromJson(
                    Map<String, dynamic>.from(e),
                  ))
              .toList()
          : const [],
    );
  }
}

String studyDayKey(DateTime local) {
  final m = local.month.toString().padLeft(2, '0');
  final d = local.day.toString().padLeft(2, '0');
  return '${local.year}-$m-$d';
}

/// 連續有學習紀錄的天數。今天還沒學習時，從昨天往回算。
int studyStreak(Set<String> days, DateTime today) {
  var cursor = DateTime(today.year, today.month, today.day);
  if (!days.contains(studyDayKey(cursor))) {
    cursor = cursor.subtract(const Duration(days: 1));
    if (!days.contains(studyDayKey(cursor))) return 0;
  }
  var count = 0;
  while (days.contains(studyDayKey(cursor)) && count < 3660) {
    count++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return count;
}

ActivitySnapshot _mergeSnapshots(ActivitySnapshot? current, ActivitySnapshot next) {
  if (current == null) return next;
  final later = next.lastRecordedAt != null &&
      (current.lastRecordedAt == null ||
          !next.lastRecordedAt!.isBefore(current.lastRecordedAt!));
  final useNextCounts = next.bestCorrect > current.bestCorrect ||
      (next.bestCorrect == current.bestCorrect && later);
  final durations = [current.bestDurationSeconds, next.bestDurationSeconds]
      .whereType<int>()
      .where((n) => n > 0);
  return ActivitySnapshot(
    activityType: next.activityType,
    contextKey: next.contextKey,
    bestCorrect: next.bestCorrect > current.bestCorrect
        ? next.bestCorrect
        : current.bestCorrect,
    bestQuestionCount:
        useNextCounts ? next.bestQuestionCount : current.bestQuestionCount,
    bestPercent: _maxNullable(current.bestPercent, next.bestPercent),
    bestDurationSeconds: durations.isEmpty
        ? null
        : durations.reduce((a, b) => a < b ? a : b),
    attempts: current.attempts + next.attempts,
    lastRecordedAt: later ? next.lastRecordedAt : current.lastRecordedAt,
  );
}

int? _maxNullable(int? a, int? b) {
  if (a == null) return b;
  if (b == null) return a;
  return a > b ? a : b;
}

/// 雲端彙總再加上尚未上傳成功的紀錄，避免補傳前成績從畫面上消失。
ChildActivityStats foldActivities(
  ChildActivityStats base,
  Iterable<PendingLearningRecord> pending,
) {
  final dates = {...base.studyDates};
  final map = <String, ActivitySnapshot>{
    for (final activity in base.activities)
      if (activity.activityType.isNotEmpty) activity.key: activity,
  };
  for (final item in pending) {
    dates.add(studyDayKey(item.recordedAt.toLocal()));
    final snap = ActivitySnapshot.fromPending(item);
    if (snap.activityType.isEmpty) continue;
    if (snap.activityType == LearningActivityTypes.lessonQuiz ||
        snap.activityType == LearningActivityTypes.lessonReview) {
      continue;
    }
    map[snap.key] = _mergeSnapshots(map[snap.key], snap);
  }
  final sortedDates = dates.toList()..sort();
  final activities = map.values.toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  return ChildActivityStats(studyDates: sortedDates, activities: activities);
}

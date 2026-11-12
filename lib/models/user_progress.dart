class LessonProgress {
  final String lessonId;
  final bool completed;
  final int stars;
  final int lastScore;
  final DateTime? lastStudiedAt;

  const LessonProgress({
    required this.lessonId,
    this.completed = false,
    this.stars = 0,
    this.lastScore = 0,
    this.lastStudiedAt,
  });

  LessonProgress copyWith({
    bool? completed,
    int? stars,
    int? lastScore,
    DateTime? lastStudiedAt,
  }) {
    return LessonProgress(
      lessonId: lessonId,
      completed: completed ?? this.completed,
      stars: stars ?? this.stars,
      lastScore: lastScore ?? this.lastScore,
      lastStudiedAt: lastStudiedAt ?? this.lastStudiedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'lessonId': lessonId,
        'completed': completed,
        'stars': stars,
        'lastScore': lastScore,
        'lastStudiedAt': lastStudiedAt?.toIso8601String(),
      };

  factory LessonProgress.fromJson(Map<String, dynamic> json) => LessonProgress(
        lessonId: json['lessonId'] as String,
        completed: json['completed'] as bool? ?? false,
        stars: json['stars'] as int? ?? 0,
        lastScore: json['lastScore'] as int? ?? 0,
        lastStudiedAt: json['lastStudiedAt'] != null
            ? DateTime.tryParse(json['lastStudiedAt'] as String)
            : null,
      );
}

/// 雲端一課的完成摘要。星星門檻與 [ProgressProvider] 相同，由後端計算。
class RemoteLessonSnapshot {
  const RemoteLessonSnapshot({
    required this.lessonId,
    required this.stars,
    required this.lastScore,
    this.lastStudiedAt,
  });

  final String lessonId;
  final int stars;
  final int lastScore;
  final DateTime? lastStudiedAt;
}

/// 本機與雲端合併：星星取較高，分數與時間取較新的一次。
LessonProgress mergeRemoteLesson(
  LessonProgress local,
  RemoteLessonSnapshot remote,
) {
  final remoteAt = remote.lastStudiedAt;
  final localAt = local.lastStudiedAt;
  final useRemoteScore = remoteAt != null &&
      (localAt == null || !remoteAt.isBefore(localAt));
  final stars = remote.stars > local.stars ? remote.stars : local.stars;

  return LessonProgress(
    lessonId: local.lessonId,
    completed: true,
    stars: stars < 0 ? 0 : (stars > 3 ? 3 : stars),
    lastScore: useRemoteScore ? remote.lastScore : local.lastScore,
    lastStudiedAt: useRemoteScore ? remoteAt : localAt,
  );
}

class UserProfile {
  final String id;
  final String name;
  final int grade;
  final String avatar;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.grade,
    this.avatar = '🦊',
    required this.createdAt,
  });

  UserProfile copyWith({
    String? name,
    int? grade,
    String? avatar,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      grade: grade ?? this.grade,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'grade': grade,
        'avatar': avatar,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        name: json['name'] as String? ?? '小朋友',
        grade: json['grade'] as int? ?? 1,
        avatar: json['avatar'] as String? ?? '🦊',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
      );
}

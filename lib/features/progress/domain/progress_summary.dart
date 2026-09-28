class ProgressPeriodSummary {
  const ProgressPeriodSummary({
    required this.newHifzAyahs,
    required this.revisionAyahs,
    required this.readingPages,
  });

  const ProgressPeriodSummary.empty()
    : newHifzAyahs = 0,
      revisionAyahs = 0,
      readingPages = 0;

  final int newHifzAyahs;
  final int revisionAyahs;
  final int readingPages;
}

class HifzStatusSummary {
  const HifzStatusSummary({
    required this.learning,
    required this.memorized,
    required this.needsRevision,
    required this.strong,
  });

  const HifzStatusSummary.empty()
    : learning = 0,
      memorized = 0,
      needsRevision = 0,
      strong = 0;

  final int learning;
  final int memorized;
  final int needsRevision;
  final int strong;
}

class DailyGoalSummary {
  const DailyGoalSummary({
    required this.newHifzAyahsTarget,
    required this.revisionAyahsTarget,
    required this.readingPagesTarget,
  });

  const DailyGoalSummary.empty()
    : newHifzAyahsTarget = 0,
      revisionAyahsTarget = 0,
      readingPagesTarget = 0;

  final int newHifzAyahsTarget;
  final int revisionAyahsTarget;
  final int readingPagesTarget;
}

class ProgressSummary {
  const ProgressSummary({
    required this.day,
    required this.hifz,
    required this.revisionDue,
    required this.today,
    required this.trailing7Days,
    required this.trailing30Days,
    required this.goals,
  });

  factory ProgressSummary.empty(DateTime day) {
    return ProgressSummary(
      day: day,
      hifz: const HifzStatusSummary.empty(),
      revisionDue: 0,
      today: const ProgressPeriodSummary.empty(),
      trailing7Days: const ProgressPeriodSummary.empty(),
      trailing30Days: const ProgressPeriodSummary.empty(),
      goals: const DailyGoalSummary.empty(),
    );
  }

  final DateTime day;
  final HifzStatusSummary hifz;
  final int revisionDue;
  final ProgressPeriodSummary today;
  final ProgressPeriodSummary trailing7Days;
  final ProgressPeriodSummary trailing30Days;
  final DailyGoalSummary goals;

  ProgressSummary copyWith({
    DateTime? day,
    HifzStatusSummary? hifz,
    int? revisionDue,
    ProgressPeriodSummary? today,
    ProgressPeriodSummary? trailing7Days,
    ProgressPeriodSummary? trailing30Days,
    DailyGoalSummary? goals,
  }) {
    return ProgressSummary(
      day: day ?? this.day,
      hifz: hifz ?? this.hifz,
      revisionDue: revisionDue ?? this.revisionDue,
      today: today ?? this.today,
      trailing7Days: trailing7Days ?? this.trailing7Days,
      trailing30Days: trailing30Days ?? this.trailing30Days,
      goals: goals ?? this.goals,
    );
  }
}

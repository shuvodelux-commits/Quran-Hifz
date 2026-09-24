import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../data/drift_hifz_plan_repository.dart';
import '../domain/hifz_plan.dart';

const defaultHifzPlanProfileKey = 'default';

final hifzPlanRepositoryProvider = Provider<HifzPlanRepository>((ref) {
  return DriftHifzPlanRepository(ref.watch(userDatabaseProvider));
});

final hifzPlansProvider = StreamProvider<List<HifzPlan>>((ref) {
  return ref
      .watch(hifzPlanRepositoryProvider)
      .watchPlans(defaultHifzPlanProfileKey);
});

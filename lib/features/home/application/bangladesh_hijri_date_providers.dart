import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/application/app_preferences_controller.dart';
import '../data/bangladesh_hijri_date.dart';

typedef BangladeshHijriDateRequest = ({
  DateTime baselineSourceDate,
  int correction,
  String? correctionScope,
});

typedef BangladeshHijriMonthRequest = ({
  int year,
  int month,
  int correction,
  String? correctionScope,
});

final bangladeshHijriDateRepositoryProvider =
    Provider<BangladeshHijriDateRepository>(
      (ref) => BangladeshHijriDateRepository(),
    );

final bangladeshHijriDateProvider =
    FutureProvider.autoDispose
        .family<ResolvedHijriDate, BangladeshHijriDateRequest>((ref, request) async {
          final repository = ref.watch(bangladeshHijriDateRepositoryProvider);
          final baseline = await repository.convert(request.baselineSourceDate);
          final correction = BangladeshHijriDateResolver.activeCorrection(
            correction: request.correction,
            correctionScope: request.correctionScope,
            baseline: baseline,
          );
          if (correction == 0) return baseline;
          return repository.convert(
            request.baselineSourceDate.add(Duration(days: correction)),
          );
        });

final currentBangladeshHijriDateProvider =
    FutureProvider.autoDispose.family<ResolvedHijriDate, DateTime>((
      ref,
      baselineSourceDate,
    ) {
      return ref.watch(
        bangladeshHijriDateProvider((
          baselineSourceDate: baselineSourceDate,
          correction: ref.watch(hijriDateCorrectionProvider),
          correctionScope: ref.watch(hijriCorrectionScopeProvider),
        )).future,
      );
    });

final bangladeshHijriMonthProvider =
    FutureProvider.autoDispose
        .family<List<ResolvedHijriDate>, BangladeshHijriMonthRequest>((
          ref,
          request,
        ) async {
          final repository = ref.watch(bangladeshHijriDateRepositoryProvider);
          final currentStart = DateTime(request.year, request.month, 1);
          final previousStart = DateTime(request.year, request.month - 1, 1);
          final previous = await repository.convertMonth(
            previousStart.year,
            previousStart.month,
          );
          final current = await repository.convertMonth(
            currentStart.year,
            currentStart.month,
          );

          ResolvedHijriDate lookup(DateTime date) {
            final normalized = DateTime(date.year, date.month, date.day);
            if (normalized.year == currentStart.year &&
                normalized.month == currentStart.month) {
              return current[normalized.day]!;
            }
            return previous[normalized.day]!;
          }

          final count = DateTime(request.year, request.month + 1, 0).day;
          return [
            for (var day = 1; day <= count; day++)
              (() {
                final civilDay = DateTime(request.year, request.month, day);
                final baselineSource = civilDay.subtract(const Duration(days: 1));
                final baseline = lookup(baselineSource);
                final correction =
                    BangladeshHijriDateResolver.activeCorrection(
                      correction: request.correction,
                      correctionScope: request.correctionScope,
                      baseline: baseline,
                    );
                return lookup(
                  baselineSource.add(Duration(days: correction)),
                );
              })(),
          ];
        });

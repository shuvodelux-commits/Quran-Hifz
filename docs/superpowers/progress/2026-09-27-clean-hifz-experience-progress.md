# SDD ledger — plan: docs/superpowers/plans/2026-09-27-clean-hifz-experience-implementation.md

Execution mode: Native fallback required because this ChatGPT harness exposes no subagent-dispatch tool.
Ruling: Store the SDD ledger as a temporary tracked docs file instead of the normal git-ignored .superpowers workspace — GitHub-only execution provides no local worktree/filesystem, and the ledger must survive compaction — cost if wrong: one temporary docs file to remove before merge.

## Pre-flight shared-interface scan

| Tasks | Producer → Consumer | Finding |
|---|---|---|
| 2 → 4 | Hifz repositories/domain → memorization engine | Compatible: Task 4 explicitly consumes Task 2 repository contracts. |
| 2 → 7 | Hifz plan persistence → Surah-first home | Compatible: Task 7 creates/resumes plans through Task 2. |
| 2 → 8 | Hifz progress/review tables → progress/revision services | Compatible. |
| 3 → 5 | QCF variant-based page-font infrastructure → renderer typography | Compatible: renderer keeps generic Quran infrastructure while Hifz owns selection. |
| 3 → 6 | Hifz appearance providers → Hifz reader | Compatible. |
| 4 → 6 | Hifz session controller → reader controls | Compatible. |
| 5 → 6 | Resizable strict QCF surface → Hifz reader | Compatible. |
| 6 → 7 | Hifz reader → home/setup navigation | Compatible; Task 7 also reuses picker from reader. |
| 2/3/4/5/6/7/8 → 9 | Completed Hifz stack → integration/QA | Compatible. |

Ruling: Execute each task on the isolated feature branch `fix/restore-hifz-skin`; never mutate `main` — matches the approved GitHub-first constraint — cost if wrong: branch cleanup/rebase only.

Task 1: complete (commits baae8dc..0fd2983; GitHub Actions run 36290028209 reached Analyze=success, Test=success; Android build remains a Task 9 full-suite gate).

Task 2: Ruling: Generate and commit Drift code in GitHub Actions because this GitHub-only harness has no local Dart/Flutter executable — build_runner remains the canonical generator — cost if wrong: one bot-generated commit may need cleanup.
Task 2: complete (RED run 36290789457 failed on missing hifz_progress_entries as expected; GREEN run 36291443841 Hifz focused regression passed after schema v13, repository, and migration restoration).

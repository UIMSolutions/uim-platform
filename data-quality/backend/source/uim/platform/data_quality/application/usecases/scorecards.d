/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Scorecards and quality trends of datasets.
module uim.platform.data_quality.application.usecases.scorecards;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

class ManageScorecardsUseCase : DqInteractor, IScorecards {
  protected QualityScorer scorer;

  this(DqRepositories repos, IClock clock, IDqEventPublisher events, IDqUnitOfWork unitOfWork, DqPolicy policy) {
    super(repos, clock, events, unitOfWork, policy);
    scorer = new QualityScorer;
  }

  /// The scorecard from the current records, violations, profile and open duplicates.
  Scorecard currentScorecard(TenantId t, DatasetId ds) {
    ScoreInput input;
    input.recordCount = repos.records.countByDataset(t, ds);
    auto violations = repos.violations.findByDataset(t, ds);
    input.violations = violations;
    input.columns = repos.columnProfiles.findByDataset(t, ds);
    RecordId[] duplicates;
    foreach (g; repos.matchGroups.findByDataset(t, ds))
      if (!g.resolved)
        duplicates ~= g.duplicates;
    input.duplicateRecords = duplicates;

    Scorecard c;
    c.datasetId = ds.value;
    c.scores = scorer.score(input);
    c.records = input.recordCount;
    c.violations = violations.length;
    c.openDuplicates = duplicates.length;
    c.computedAt = now;
    return c;
  }

  Scorecard computeScorecard(TenantId t, DatasetId ds, UserId actor) {
    auto d = datasetOf(t, ds);
    auto c = currentScorecard(t, ds);
    d.scores = c.scores;
    d.scoredAt = c.computedAt;
    stampUpdated(d, actor, c.computedAt);
    repos.datasets.save(d);
    return c;
  }

  QualitySnapshot takeSnapshot(TenantId t, DatasetId ds, UserId actor) {
    auto c = computeScorecard(t, ds, actor);
    QualitySnapshot s;
    stampCreated!(QualitySnapshot, SnapshotId)(s, t, actor, newResourceId(), c.computedAt);
    s.datasetId = ds;
    s.scores = c.scores;
    s.recordCount = c.records;
    s.violationCount = c.violations;
    s.takenAt = c.computedAt;
    batch(() {
      repos.snapshots.save(s);
      auto all = repos.snapshots.findByDataset(t, ds);
      if (policy.maxSnapshots > 0 && all.length > policy.maxSnapshots)
        foreach (old; all[0 .. all.length - policy.maxSnapshots])
          repos.snapshots.removeById(t, ds, old.id);
    });
    emit("dataset.scored", t, ds.value, Json(["overall": Json(c.scores.overall), "rating": Json(cast(string) c.scores.rating)]));
    return s;
  }

  QualitySnapshot[] listSnapshots(TenantId t, DatasetId ds) {
    return repos.snapshots.findByDataset(t, ds);
  }

  QualitySnapshot getSnapshot(TenantId t, DatasetId ds, SnapshotId id) {
    return required(repos.snapshots.findById(t, ds, id), "Snapshot '" ~ id.value ~ "'");
  }

  void deleteSnapshot(TenantId t, DatasetId ds, SnapshotId id) {
    getSnapshot(t, ds, id);
    repos.snapshots.removeById(t, ds, id);
  }
}

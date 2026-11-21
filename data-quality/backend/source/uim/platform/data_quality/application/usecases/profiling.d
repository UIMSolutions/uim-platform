/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_quality.application.usecases.profiling;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

class ProfileDataUseCase : DqInteractor, IProfileData {
  protected DataProfiler profiler;
  protected ManageScorecardsUseCase scorecards;

  this(DqRepositories repos, IClock clock, IDqEventPublisher events, IDqUnitOfWork unitOfWork, DqPolicy policy,
    ManageScorecardsUseCase scorecards) {
    super(repos, clock, events, unitOfWork, policy);
    this.scorecards = scorecards;
    profiler = new DataProfiler;
  }

  ProfileRunResult profileDataset(TenantId t, DatasetId ds, UserId actor) {
    auto started = now;
    datasetOf(t, ds);
    FieldValue[][] rows;
    foreach (r; repos.records.findByDataset(t, ds))
      rows ~= r.fields;
    auto stats = profiler.profile(rows);
    auto at = now;

    ProfileRunResult result;
    result.datasetId = ds.value;
    result.records = rows.length;
    result.columns = stats.length;
    double completeness = 0, uniqueness = 0;
    batch(() {
      repos.columnProfiles.removeByDataset(t, ds);
      foreach (i, s; stats) {
        ColumnProfile p;
        stampCreated!(ColumnProfile, ColumnProfileId)(p, t, actor, s.fieldName, at);
        p.datasetId = ds;
        p.position = cast(int) i;
        p.stats = s;
        p.profiledAt = at;
        repos.columnProfiles.save(p);
        completeness += s.completeness;
        uniqueness += s.uniqueness;
      }
      auto d = repos.datasets.findById(t, ds);
      d.profiledAt = at;
      repos.datasets.save(d);
    });
    if (stats.length) {
      result.completeness = roundScore(completeness / stats.length);
      result.uniqueness = roundScore(uniqueness / stats.length);
    }
    scorecards.computeScorecard(t, ds, actor);
    result.durationMillis = millisBetween(started, now);
    emit("dataset.profiled", t, ds.value, Json(["columns": Json(stats.length), "records": Json(rows.length)]));
    return result;
  }

  ColumnStats[] profileInline(const InlineRecord[] records) {
    FieldValue[][] rows;
    foreach (r; records)
      rows ~= checkedFields(r.fields);
    return profiler.profile(rows);
  }

  ColumnProfile[] listColumnProfiles(TenantId t, DatasetId ds) {
    auto columns = repos.columnProfiles.findByDataset(t, ds);
    columns.sort!((a, b) => a.datasetId.value != b.datasetId.value ? a.datasetId.value < b.datasetId.value : a.position < b.position);
    return columns;
  }

  ColumnProfile getColumnProfile(TenantId t, DatasetId ds, ColumnProfileId id) {
    return required(repos.columnProfiles.findById(t, ds, id), "Column profile '" ~ id.value ~ "'");
  }
}

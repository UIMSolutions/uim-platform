/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Tenant statistics (KPI header of the Fiori app, CLI "stats").
module uim.platform.data_quality.application.services.statistics;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

class DqStatisticsService : IDqStatisticsService {
  protected DqRepositories repos;
  protected IClock clock;

  this(DqRepositories repos, IClock clock) {
    this.repos = repos;
    this.clock = clock;
  }

  DqStatistics compute(TenantId t) {
    DqStatistics s;
    s.tenantId = t.value;
    auto datasets = repos.datasets.findAll(t);
    s.datasets = datasets.length;
    double sum = 0;
    foreach (d; datasets)
      if (d.isScored) {
        s.scoredDatasets++;
        sum += d.scores.overall;
      }
    s.averageScore = s.scoredDatasets ? roundScore(sum / s.scoredDatasets) : 100;
    s.rating = ratingOf(s.averageScore);

    foreach (r; repos.records.findAll(t)) {
      s.records++;
      if (r.isValidated) {
        s.validatedRecords++;
        if (r.violationCount > 0)
          s.invalidRecords++;
      }
    }
    foreach (r; repos.validationRules.findAll(t)) {
      s.validationRules++;
      if (r.isActive)
        s.activeValidationRules++;
    }
    foreach (v; repos.violations.findAll(t)) {
      s.violations++;
      if (v.severity == RuleSeverity.critical)
        s.criticalViolations++;
      else if (v.severity == RuleSeverity.error)
        s.errorViolations++;
      else if (v.severity == RuleSeverity.warning)
        s.warningViolations++;
    }
    foreach (r; repos.cleansingRules.findAll(t)) {
      s.cleansingRules++;
      if (r.isActive)
        s.activeCleansingRules++;
    }
    foreach (j; repos.cleansingJobs.findAll(t)) {
      s.cleansingJobs++;
      if (j.status == JobStatus.pending)
        s.pendingJobs++;
      else if (j.status == JobStatus.failed)
        s.failedJobs++;
    }
    foreach (g; repos.matchGroups.findAll(t)) {
      s.matchGroups++;
      if (!g.resolved) {
        s.openMatchGroups++;
        s.duplicateRecords += g.duplicates.length;
      }
    }
    foreach (a; repos.addresses.findAll(t)) {
      s.addresses++;
      if (a.output.quality == AddressQuality.verified || a.output.quality == AddressQuality.corrected)
        s.verifiedAddresses++;
      else if (a.output.quality == AddressQuality.invalid)
        s.invalidAddresses++;
    }
    s.computedAt = clock.now;
    return s;
  }
}

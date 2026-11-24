/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Tenant statistics in one pass over each collection (KPI header, CLI
/// "stats", monitoring).
module uim.platform.data_retention.application.services.statistics;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class DrStatisticsService : IDrStatisticsService {
  protected DrRepositories repos;
  protected IClock clock;

  this(DrRepositories repos, IClock clock) {
    this.repos = repos;
    this.clock = clock;
  }

  DrStatistics compute(TenantId t) {
    DrStatistics s;
    auto now = clock.now;
    s.tenantId = t.value;
    s.computedAt = now;
    s.applicationGroups = repos.applicationGroups.countAll(t);
    s.legalEntities = repos.legalEntities.countAll(t);
    s.dataSubjectRoles = repos.dataSubjectRoles.countAll(t);
    foreach (p; repos.businessPurposes.findAll(t)) {
      s.businessPurposes++;
      if (p.isActive)
        s.activeBusinessPurposes++;
    }
    s.legalGrounds = repos.legalGrounds.countAll(t);
    s.residenceRules = repos.residenceRules.countAll(t);
    s.retentionRules = repos.retentionRules.countAll(t);

    auto book = new RuleBook(repos, t);
    foreach (d; repos.dataSubjects.findAll(t)) {
      s.dataSubjects++;
      final switch (d.lifecycleStatus) {
      case LifecycleStatus.active:
        s.activeSubjects++;
        break;
      case LifecycleStatus.blocked:
        s.blockedSubjects++;
        break;
      case LifecycleStatus.archived:
        s.blockedSubjects++;
        s.archivedSubjects++;
        break;
      case LifecycleStatus.markedForDeletion:
        s.blockedSubjects++;
        s.markedForDeletion++;
        break;
      case LifecycleStatus.deleted:
        s.deletedSubjects++;
        break;
      }
      if (d.legalHold)
        s.legalHolds++;
      if (d.isDeleted)
        continue;
      auto e = book.evaluate(d, now);
      if (e.phase == RetentionPhase.noRule)
        s.noRuleSubjects++;
      if (e.dueForBlocking(d.lifecycleStatus))
        s.dueForBlocking++;
      if (e.dueForDestruction(d.lifecycleStatus, d.legalHold))
        s.dueForDestruction++;
      if (e.endOfRetention > now && (s.nextEndOfRetention == 0 || e.endOfRetention < s.nextEndOfRetention))
        s.nextEndOfRetention = e.endOfRetention;
    }
    foreach (r; repos.deletionRequests.findAll(t)) {
      if (r.status == DeletionRequestStatus.pending)
        s.pendingRequests++;
      else if (r.status == DeletionRequestStatus.rejected)
        s.rejectedRequests++;
    }
    foreach (j; repos.archivingJobs.findAll(t)) {
      if (j.status == JobStatus.scheduled)
        s.scheduledJobs++;
      else if (j.status == JobStatus.failed)
        s.failedJobs++;
    }
    return s;
  }
}

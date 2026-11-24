/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving port of the tenant statistics (KPI header of the Fiori app).
module uim.platform.data_retention.ports.services.statistics;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

struct DrStatistics {
  string tenantId;
  long applicationGroups;
  long legalEntities;
  long dataSubjectRoles;
  long businessPurposes;
  long activeBusinessPurposes;
  long legalGrounds;
  long residenceRules;
  long retentionRules;
  long dataSubjects;
  long activeSubjects;
  long blockedSubjects; /// blocked + archived + marked for deletion
  long archivedSubjects;
  long markedForDeletion;
  long deletedSubjects;
  long legalHolds;
  long dueForBlocking; /// active, past the end of purpose
  long dueForDestruction; /// past the end of retention, not destroyed, no legal hold
  long noRuleSubjects;
  long pendingRequests;
  long rejectedRequests;
  long scheduledJobs;
  long failedJobs;
  long nextEndOfRetention; /// earliest future end of retention (std time, 0 = none)
  long computedAt;
}

interface IDrStatisticsService {
  DrStatistics compute(TenantId t);
}

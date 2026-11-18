/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_provisioning.domain.entities.provisioning_job;

import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:

/// A provisioning job synchronises the identities of a source system into a
/// target system — on demand ("run") or every `intervalMinutes`.
struct ProvisioningJob {
  mixin TenantEntity!ProvisioningJobId;

  string name;
  string description;
  SourceSystemId sourceSystemId;
  string sourceSystemName; /// derived
  TargetSystemId targetSystemId;
  string targetSystemName; /// derived
  JobType jobType = JobType.delta;
  JobStatus status = JobStatus.scheduled;
  int intervalMinutes; /// 0 = on demand only
  long nextRunAt;
  int runCount;
  long startedAt;
  long completedAt;
  // ── figures of the last run ──
  int readCount;
  int createdCount;
  int updatedCount;
  int deletedCount;
  int skippedCount;
  int failedCount;
  string statusMessage;
}

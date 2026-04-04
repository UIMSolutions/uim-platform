/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.domain.entities.provisioning_job;

import uim.platform.identity.provisioning.domain.types;

/// A provisioning job that synchronises identities from a source
/// system to a target system.
struct ProvisioningJob {
  ProvisioningJobId id;
  TenantId tenantId;
  SourceSystemId sourceSystemId;
  TargetSystemId targetSystemId;
  JobType jobType = JobType.full;
  JobStatus status = JobStatus.scheduled;
  string schedule; // cron expression (empty = on-demand)
  long totalEntities;
  long processedEntities;
  long failedEntities;
  long startedAt;
  long completedAt;
  UserId createdBy;
  long createdAt;
}

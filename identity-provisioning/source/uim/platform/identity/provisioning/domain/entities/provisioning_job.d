module uim.platform.xyz.domain.entities.provisioning_job;

import domain.types;

/// A provisioning job that synchronises identities from a source
/// system to a target system.
struct ProvisioningJob
{
  ProvisioningJobId id;
  TenantId tenantId;
  SourceSystemId sourceSystemId;
  TargetSystemId targetSystemId;
  JobType jobType = JobType.full;
  JobStatus status = JobStatus.scheduled;
  string schedule;       // cron expression (empty = on-demand)
  long totalEntities;
  long processedEntities;
  long failedEntities;
  long startedAt;
  long completedAt;
  UserId createdBy;
  long createdAt;
}

module uim.platform.xyz.domain.entities.provisioning_log;

import uim.platform.xyz.domain.types;

/// An audit record for a single entity operation within a
/// provisioning job run.
struct ProvisioningLog
{
  ProvisioningLogId id;
  TenantId tenantId;
  ProvisioningJobId jobId;
  EntityType entityType = EntityType.user;
  string entityId;
  OperationType operation = OperationType.create;
  LogStatus status = LogStatus.success;
  string sourceSystem;
  string targetSystem;
  string details; // JSON: error message, attribute diff, etc.
  long createdAt;
}

module uim.platform.identity.provisioning.domain.types;

// --- Type Aliases ---
alias SourceSystemId = string;
alias TargetSystemId = string;
alias ProxySystemId = string;
alias TransformationId = string;
alias ProvisioningJobId = string;
alias ProvisioningLogId = string;
alias ProvisionedEntityId = string;
alias TenantId = string;
alias UserId = string;

// --- Enums ---

/// Type of connected system.
enum SystemType
{
  ias,
  ldap,
  sap_hr,
  scim,
  csv,
  azure_ad,
  custom
}

/// Operational status of a system connection.
enum SystemStatus
{
  active,
  inactive,
  error,
  configuring
}

/// Role of a system in the provisioning pipeline.
enum SystemRole
{
  source,
  target,
  proxy
}

/// Type of provisioning job.
enum JobType
{
  full,
  delta,
  simulate
}

/// Status of a provisioning job.
enum JobStatus
{
  scheduled,
  running,
  completed,
  failed,
  cancelled
}

/// Type of provisioning operation on a single entity.
enum OperationType
{
  create,
  update,
  delete_,
  skip
}

/// Outcome of a single provisioning operation.
enum LogStatus
{
  success,
  failed,
  skipped
}

/// Kind of identity entity being provisioned.
enum EntityType
{
  user,
  group
}

/// Status of a provisioned entity in a target system.
enum EntityStatus
{
  active,
  inactive,
  pending,
  error
}

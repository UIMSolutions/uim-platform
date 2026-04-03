module uim.platform.xyz.application.dto;

import uim.platform.xyz.domain.types;

// --- Source System ---

struct CreateSourceSystemRequest
{
  TenantId tenantId;
  string name;
  string description;
  SystemType systemType;
  string connectionConfig; // JSON
  UserId createdBy;
}

struct UpdateSourceSystemRequest
{
  SourceSystemId id;
  TenantId tenantId;
  string name;
  string description;
  string connectionConfig;
}

// --- Target System ---

struct CreateTargetSystemRequest
{
  TenantId tenantId;
  string name;
  string description;
  SystemType systemType;
  string connectionConfig; // JSON
  UserId createdBy;
}

struct UpdateTargetSystemRequest
{
  TargetSystemId id;
  TenantId tenantId;
  string name;
  string description;
  string connectionConfig;
}

// --- Proxy System ---

struct CreateProxySystemRequest
{
  TenantId tenantId;
  string name;
  string description;
  SystemType systemType;
  string connectionConfig;
  SourceSystemId sourceSystemId;
  TargetSystemId targetSystemId;
  UserId createdBy;
}

struct UpdateProxySystemRequest
{
  ProxySystemId id;
  TenantId tenantId;
  string name;
  string description;
  string connectionConfig;
}

// --- Transformation ---

struct CreateTransformationRequest
{
  TenantId tenantId;
  string systemId;
  SystemRole systemRole;
  string name;
  string mappingRules; // JSON
  string conditions;   // JSON
  UserId createdBy;
}

struct UpdateTransformationRequest
{
  TransformationId id;
  TenantId tenantId;
  string name;
  string mappingRules;
  string conditions;
}

// --- Provisioning Job ---

struct CreateProvisioningJobRequest
{
  TenantId tenantId;
  SourceSystemId sourceSystemId;
  TargetSystemId targetSystemId;
  JobType jobType;
  string schedule; // cron expression or empty for on-demand
  UserId createdBy;
}

// --- Command Result ---

struct CommandResult
{
  string id;
  string error;

  bool isSuccess() const
  {
    return error.length == 0;
  }
}

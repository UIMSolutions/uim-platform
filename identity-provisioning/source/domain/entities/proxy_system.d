module domain.entities.proxy_system;

import domain.types;

/// A proxy system that acts as an intermediary between a source
/// and target system, applying transformations and access control.
struct ProxySystem
{
  ProxySystemId id;
  TenantId tenantId;
  string name;
  string description;
  SystemType systemType = SystemType.scim;
  SystemStatus status = SystemStatus.configuring;
  string connectionConfig; // JSON: {url, authType, credentials...}
  SourceSystemId sourceSystemId;
  TargetSystemId targetSystemId;
  UserId createdBy;
  long createdAt;
  long updatedAt;
}

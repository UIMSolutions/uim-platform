module uim.platform.xyz.domain.entities.source_system;

import domain.types;

/// A source system from which identities (users/groups) are read
/// during provisioning runs.
struct SourceSystem
{
  SourceSystemId id;
  TenantId tenantId;
  string name;
  string description;
  SystemType systemType = SystemType.scim;
  SystemStatus status = SystemStatus.configuring;
  string connectionConfig; // JSON: {url, authType, credentials...}
  long lastSyncAt;
  UserId createdBy;
  long createdAt;
  long updatedAt;
}

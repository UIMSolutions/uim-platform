module uim.platform.xyz.domain.entities.target_system;

import domain.types;

/// A target system to which identities (users/groups) are written
/// during provisioning runs.
struct TargetSystem
{
  TargetSystemId id;
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

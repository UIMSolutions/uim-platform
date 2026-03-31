module domain.entities.provisioned_entity;

import domain.types;

/// A tracked identity entity (user or group) that has been
/// provisioned from a source to a target system.
struct ProvisionedEntity
{
  ProvisionedEntityId id;
  TenantId tenantId;
  string externalId;         // id in the external system
  EntityType entityType = EntityType.user;
  SourceSystemId sourceSystemId;
  TargetSystemId targetSystemId;
  string attributes;         // JSON: provisioned attribute snapshot
  EntityStatus status = EntityStatus.pending;
  long lastSyncAt;
  long createdAt;
  long updatedAt;
}

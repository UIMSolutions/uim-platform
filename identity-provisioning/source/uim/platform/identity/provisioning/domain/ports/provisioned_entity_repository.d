module uim.platform.xyz.domain.ports.provisioned_entity_repository;

import uim.platform.xyz.domain.types;
import uim.platform.xyz.domain.entities.provisioned_entity;

interface ProvisionedEntityRepository
{
  ProvisionedEntity[] findByTenant(TenantId tenantId);
  ProvisionedEntity* findById(ProvisionedEntityId id, TenantId tenantId);
  ProvisionedEntity* findByExternalId(string externalId, TargetSystemId targetId, TenantId tenantId);
  ProvisionedEntity[] findBySource(SourceSystemId sourceId, TenantId tenantId);
  ProvisionedEntity[] findByTarget(TargetSystemId targetId, TenantId tenantId);
  ProvisionedEntity[] findByStatus(TenantId tenantId, EntityStatus status);
  ProvisionedEntity[] findByType(TenantId tenantId, EntityType entityType);
  long countByTarget(TargetSystemId targetId, TenantId tenantId);
  void save(ProvisionedEntity entity);
  void update(ProvisionedEntity entity);
  void remove(ProvisionedEntityId id, TenantId tenantId);
}

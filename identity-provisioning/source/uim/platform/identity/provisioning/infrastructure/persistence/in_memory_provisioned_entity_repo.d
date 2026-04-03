module uim.platform.xyz.infrastructure.persistence.memory.provisioned_entity_repo;

import uim.platform.xyz.domain.types;
import uim.platform.xyz.domain.entities.provisioned_entity;
import uim.platform.xyz.domain.ports.provisioned_entity_repository;

class MemoryProvisionedEntityRepository : ProvisionedEntityRepository
{
  private ProvisionedEntity[string] store;

  void save(ProvisionedEntity entity)
  {
    store[entity.id] = entity;
  }

  void update(ProvisionedEntity entity)
  {
    store[entity.id] = entity;
  }

  void remove(ProvisionedEntityId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }

  ProvisionedEntity* findById(ProvisionedEntityId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  ProvisionedEntity* findByExternalId(string externalId, TargetSystemId targetId, TenantId tenantId)
  {
    foreach (ref e; store)
      if (e.externalId == externalId && e.targetSystemId == targetId && e.tenantId == tenantId)
        return &e;
    return null;
  }

  ProvisionedEntity[] findByTenant(TenantId tenantId)
  {
    ProvisionedEntity[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  ProvisionedEntity[] findBySource(SourceSystemId sourceId, TenantId tenantId)
  {
    ProvisionedEntity[] result;
    foreach (ref e; store)
      if (e.sourceSystemId == sourceId && e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  ProvisionedEntity[] findByTarget(TargetSystemId targetId, TenantId tenantId)
  {
    ProvisionedEntity[] result;
    foreach (ref e; store)
      if (e.targetSystemId == targetId && e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  ProvisionedEntity[] findByStatus(TenantId tenantId, EntityStatus status)
  {
    ProvisionedEntity[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.status == status)
        result ~= e;
    return result;
  }

  ProvisionedEntity[] findByType(TenantId tenantId, EntityType entityType)
  {
    ProvisionedEntity[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.entityType == entityType)
        result ~= e;
    return result;
  }

  long countByTarget(TargetSystemId targetId, TenantId tenantId)
  {
    long count;
    foreach (ref e; store)
      if (e.targetSystemId == targetId && e.tenantId == tenantId)
        count++;
    return count;
  }
}

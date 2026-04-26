/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.infrastructure.persistence.memory.provisioned_entity;

import uim.platform.identity.provisioning.domain.types;
import uim.platform.identity.provisioning.domain.entities.provisioned_entity;
import uim.platform.identity.provisioning.domain.ports.repositories.provisioned_entitys;

class MemoryProvisionedEntityRepository : TenantRepository!(ProvisionedEntity, ProvisionedEntityId), ProvisionedEntityRepository {

  bool existsByExternalId(string externalId, TargetSystemId targettenantId, id tenantId) {
    foreach (e; findAll)
      if (e.externalId == externalId && e.targetSystemId == targetId && e.tenantId == tenantId)
        return true;
    return false;
  }

  ProvisionedEntity findByExternalId(string externalId, TargetSystemId targettenantId, id tenantId) {
    foreach (e; findAll)
      if (e.externalId == externalId && e.targetSystemId == targetId && e.tenantId == tenantId)
        return e;
    return ProvisionedEntity.init;
  }

  size_t countBySource(TenantId tenantId, SourceSystemId sourceId) {
    return findBySource(tenantId, sourceId).length;
  }

  ProvisionedEntity[] filterBySource(ProvisionedEntity[] entities, SourceSystemId sourceId) {
    return entities.filter!(e => e.tenantId == tenantId && e.sourceSystemId == sourceId).array;
  }

  ProvisionedEntity[] findBySource(TenantId tenantId, SourceSystemId sourceId) {
    return filterBySource(findByTenant(tenantId), sourceId);
  }

  void removeBySource(TenantId tenantId, SourceSystemId sourceId) {
    findBySource(tenantId, sourceId).each!(e => remove(e));
  }

  size_t countByTarget(TenantId tenantId, TargetSystemId targetId) {
    return findByTarget(tenantId, targetId).length;
  }

  ProvisionedEntity[] filterByTarget(ProvisionedEntity[] entities, TargetSystemId targetId) {
    return entities.filter!(e => e.tenantId == tenantId && e.targetSystemId == targetId).array;
  }

  ProvisionedEntity[] findByTarget(TenantId tenantId, TargetSystemId targetId) {
    return filterByTarget(findByTenant(tenantId), targetId);
  }

  void removeByTarget(TenantId tenantId, TargetSystemId targetId) {
    findByTarget(tenantId, targetId).each!(e => remove(e));
  }

  size_t countByStatus(TenantId tenantId, EntityStatus status) {
    return findByStatus(tenantId, status).length;
  }

  ProvisionedEntity[] filterByStatus(ProvisionedEntity[] entities, EntityStatus status) {
    return entities.filter!(e => e.tenantId == tenantId && e.status == status).array;
  }

  ProvisionedEntity[] findByStatus(TenantId tenantId, EntityStatus status) {
    return filterByStatus(findByTenant(tenantId), status);
  }

  void removeByStatus(TenantId tenantId, EntityStatus status) {
    findByStatus(tenantId, status).each!(e => remove(e));
  }

  size_t countByType(TenantId tenantId, EntityType entityType) {
    return findByType(tenantId, entityType).length;
  }

  ProvisionedEntity[] filterByType(ProvisionedEntity[] entities, EntityType entityType) {
    return entities.filter!(e => e.tenantId == tenantId && e.entityType == entityType).array;
  }

  ProvisionedEntity[] findByType(TenantId tenantId, EntityType entityType) {
    return filterByType(findByTenant(tenantId), entityType);
  }

  void removeByType(TenantId tenantId, EntityType entityType) {
    findByType(tenantId, entityType).each!(e => remove(e));
  }

}

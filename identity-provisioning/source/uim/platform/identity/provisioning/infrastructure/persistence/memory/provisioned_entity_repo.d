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

  ProvisionedEntity* findByExternalId(string externalId, TargetSystemId targettenantId, id tenantId) {
    foreach (e; findAll)
      if (e.externalId == externalId && e.targetSystemId == targetId && e.tenantId == tenantId)
        return &e;
    return null;
  }

  ProvisionedEntity[] findByTenant(TenantId tenantId) {
    ProvisionedEntity[] result;
    foreach (e; findAll)
      if (e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  ProvisionedEntity[] findBySource(SourceSystemId sourcetenantId, id tenantId) {
    ProvisionedEntity[] result;
    foreach (e; findAll)
      if (e.sourceSystemId == sourceId && e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  ProvisionedEntity[] findByTarget(TargetSystemId targettenantId, id tenantId) {
    ProvisionedEntity[] result;
    foreach (e; findAll)
      if (e.targetSystemId == targetId && e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  ProvisionedEntity[] findByStatus(TenantId tenantId, EntityStatus status) {
    ProvisionedEntity[] result;
    foreach (e; findByTenant(tenantId))
      if (e.status == status)
        result ~= e;
    return result;
  }

  ProvisionedEntity[] findByType(TenantId tenantId, EntityType entityType) {
    ProvisionedEntity[] result;
    foreach (e; findByTenant(tenantId))
      if (e.entityType == entityType)
        result ~= e;
    return result;
  }

  size_t countByTarget(TargetSystemId targettenantId, id tenantId) {
    size_t count;
    foreach (e; findAll)
      if (e.targetSystemId == targetId && e.tenantId == tenantId)
        count++;
    return count;
  }
}

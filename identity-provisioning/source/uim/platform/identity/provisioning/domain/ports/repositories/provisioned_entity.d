/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.domain.ports.repositories.provisioned_entity;

import uim.platform.identity.provisioning.domain.types;
import uim.platform.identity.provisioning.domain.entities.provisioned_entity;

interface ProvisionedEntityRepository {
  ProvisionedEntity[] findByTenant(TenantId tenantId);
  ProvisionedEntity* findById(ProvisionedEntityId tenantId, id tenantId);
  ProvisionedEntity* findByExternalId(string externalId, TargetSystemId targettenantId, id tenantId);
  ProvisionedEntity[] findBySource(SourceSystemId sourcetenantId, id tenantId);
  ProvisionedEntity[] findByTarget(TargetSystemId targettenantId, id tenantId);
  ProvisionedEntity[] findByStatus(TenantId tenantId, EntityStatus status);
  ProvisionedEntity[] findByType(TenantId tenantId, EntityType entityType);
  size_t countByTarget(TargetSystemId targettenantId, id tenantId);
  void save(ProvisionedEntity entity);
  void update(ProvisionedEntity entity);
  void remove(ProvisionedEntityId tenantId, id tenantId);
}

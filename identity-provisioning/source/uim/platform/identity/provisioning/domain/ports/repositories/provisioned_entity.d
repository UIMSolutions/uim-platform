/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.domain.ports.repositories.provisioned_entity;

import uim.platform.identity.provisioning.domain.types;
import uim.platform.identity.provisioning.domain.entities.provisioned_entity;

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

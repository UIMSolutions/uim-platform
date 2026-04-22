/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.domain.ports.repositories.provisioned_entity;

import uim.platform.identity.provisioning.domain.types;
import uim.platform.identity.provisioning.domain.entities.provisioned_entity;

interface ProvisionedEntityRepository : ITenantRepository!(ProvisionedEntity, ProvisionedEntityId) {

  bool existsByExternalId(TenantId tenantId, string externalId, TargetSystemId targettenantId);
  ProvisionedEntity findByExternalId(TenantId tenantId, string externalId, TargetSystemId targettenantId);
  void removeByExternalId(TenantId tenantId, string externalId, TargetSystemId targettenantId);

  ProvisionedEntity[] findBySource(TenantId tenantId, SourceSystemId sourcetenantId);

  size_t countByTarget(TenantId tenantId, TargetSystemId targettenantId);
  ProvisionedEntity[] findByTarget(TenantId tenantId, TargetSystemId targettenantId);

  ProvisionedEntity[] findByStatus(TenantId tenantId, EntityStatus status);

  ProvisionedEntity[] findByType(TenantId tenantId, EntityType entityType);

}

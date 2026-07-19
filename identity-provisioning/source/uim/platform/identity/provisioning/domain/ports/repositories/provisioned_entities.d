/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.domain.ports.repositories.provisioned_entities;

// import uim.platform.identity.provisioning.domain.types;
// import uim.platform.identity.provisioning.domain.entities.provisioned_entity;
import uim.platform.identity.provisioning;
mixin(ShowModule!());

@safe:
interface ProvisionedEntityRepository : ITenantRepository!(ProvisionedEntity, ProvisionedEntityId) {

  bool existsByExternalId(TenantId tenantId, string externalId, TargetSystemId targettenantId);
  ProvisionedEntity findByExternalId(TenantId tenantId, string externalId, TargetSystemId targettenantId);
  void removeByExternalId(TenantId tenantId, string externalId, TargetSystemId targettenantId);

  size_t countBySource(TenantId tenantId, SourceSystemId id);
  ProvisionedEntity[] findBySource(TenantId tenantId, SourceSystemId id);
  void removeBySource(TenantId tenantId, SourceSystemId id);

  size_t countByStatus(TenantId tenantId, EntityStatus status);
  ProvisionedEntity[] findByStatus(TenantId tenantId, EntityStatus status);
  void removeByStatus(TenantId tenantId, EntityStatus status);

  size_t countByType(TenantId tenantId, EntityType entityType);
  ProvisionedEntity[] findByType(TenantId tenantId, EntityType entityType);
  void removeByType(TenantId tenantId, EntityType entityType);

}

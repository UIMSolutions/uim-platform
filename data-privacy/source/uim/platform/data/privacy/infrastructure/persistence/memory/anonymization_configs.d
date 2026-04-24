/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.infrastructure.persistence.memory.anonymization_configs;

// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.anonymization_config;
// import uim.platform.data.privacy.domain.ports.anonymization_config_repository;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class MemoryAnonymizationConfigRepository : AnonymizationConfigRepository {

  size_t countByStatus(TenantId tenantId, AnonymizationConfigStatus status) {
    return findByStatus(tenantId, status).length;
  }

  AnonymizationConfig[] findByStatus(TenantId tenantId, AnonymizationConfigStatus status) {
    return findByTenant(tenantId).filter!(config => config.status == status).array;
  }

  void removeByStatus(TenantId tenantId, AnonymizationConfigStatus status) {
    findByStatus(tenantId, status).each!(entity => remove(entity.id));
  }

}

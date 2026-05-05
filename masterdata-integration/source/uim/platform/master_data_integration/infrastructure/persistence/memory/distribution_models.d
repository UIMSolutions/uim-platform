/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.infrastructure.persistence.memory
  .distribution_model;

import uim.platform.master_data_integration.domain.types;
import uim.platform.master_data_integration.domain.entities.distribution_model;
import uim.platform.master_data_integration.domain.ports.repositories.distribution_models;

// import std.algorithm : filter;
// import std.array : array;

class MemoryDistributionModelRepository : TenantRepository!(DistributionModel, DistributionModelId), DistributionModelRepository {

  size_t countByStatus(TenantId tenantId, DistributionModelStatus status) {
    return findByStatus(tenantId, status).length;
  }
  DistributionModel[] filterByStatus(DistributionModel[] models, DistributionModelStatus status) {
    return models.filter!(e => e.status == status).array;
  }
  DistributionModel[] findByStatus(TenantId tenantId, DistributionModelStatus status) {
    return filterByStatus(findByTenant(tenantId), tenantId, status);
  }
  void removeByStatus(TenantId tenantId, DistributionModelStatus status) {
    findByStatus(tenantId, status).each!(entity => remove(entity));
  }

   size_t countBySourceClient(TenantId tenantId, ClientId sourceClientId) {
    return findBySourceClient(tenantId, sourceClientId).length;
  } 
  DistributionModel[] filterBySourceClient(DistributionModel[] models, ClientId sourceClientId) {
    return models.filter!(e => e.sourceClientId == sourceClientId).array;
  }
  DistributionModel[] findBySourceClient(TenantId tenantId, ClientId sourceClientId) {
    return filterBySourceClient(findByTenant(tenantId), sourceClientId);
  }
  void removeBySourceClient(TenantId tenantId, ClientId sourceClientId) {
    findBySourceClient(tenantId, sourceClientId).each!(entity => remove(entity));
  }
  
}

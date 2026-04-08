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

class MemoryDistributionModelRepository : DistributionModelRepository {
  private DistributionModel[DistributionModelId] store;

  DistributionModel findById(DistributionModelId id) {
    if (auto p = id in store)
      return *p;
    return DistributionModel.init;
  }

  DistributionModel[] findByTenant(TenantId tenantId) {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  DistributionModel[] findByStatus(TenantId tenantId, DistributionModelStatus status) {
    return store.byValue().filter!(e => e.tenantId == tenantId && e.status == status).array;
  }

  DistributionModel[] findBySourceClient(TenantId tenantId, ClientId sourceClientId) {
    return store.byValue().filter!(e => e.tenantId == tenantId
        && e.sourceClientId == sourceClientId).array;
  }

  void save(DistributionModel model) {
    store[model.id] = model;
  }

  void update(DistributionModel model) {
    store[model.id] = model;
  }

  void remove(DistributionModelId id) {
    store.remove(id);
  }
}

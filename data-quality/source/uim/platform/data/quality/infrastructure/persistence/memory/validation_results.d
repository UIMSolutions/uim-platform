/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.quality.infrastructure.persistence.memory.validation_results;

import uim.platform.data.quality.domain.types;
import uim.platform.data.quality.domain.entities.validation_result;
import uim.platform.data.quality.domain.ports.repositories.validation_results;

// import std.algorithm : filter;
// import std.array : array;

class MemoryValidationResultRepository : TenantRepository!(ValidationResult, ValidationResultId), ValidationResultRepository {

  size_t countByDataset(TenantId tenantId, DatasetId datasetId) {
    return findByDataset(tenantId, datasetId).length;
  }

  ValidationResult[] filterByDataset(ValidationResult[] results, DatasetId datasetId) {
    return results.filter!(r => r.datasetId == datasetId).array;
  }

  ValidationResult[] findByDataset(TenantId tenantId, DatasetId datasetId) {
    return filterByDataset(findByTenant(tenantId), datasetId);
  }

  void removeByDataset(TenantId tenantId, DatasetId datasetId) {
    findByDataset(tenantId, datasetId).removeAll;
  }

}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.quality.infrastructure.persistence.memory.validation_result_repo;

import uim.platform.data.quality.domain.types;
import uim.platform.data.quality.domain.entities.validation_result;
import uim.platform.data.quality.domain.ports.repositories.validation_results;

// import std.algorithm : filter;
// import std.array : array;

class MemoryValidationResultRepository : ValidationResultRepository
{
  private ValidationResult[RecordId] store;

  ValidationResult[] findByTenant(TenantId tenantId)
  {
    return store.byValue().filter!(r => r.tenantId == tenantId).array;
  }

  ValidationResult* findByRecord(RecordId recordId, TenantId tenantId)
  {
    if (auto p = recordId in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  ValidationResult[] findByDataset(TenantId tenantId, DatasetId datasetId)
  {
    return store.byValue().filter!(r => r.tenantId == tenantId && r.datasetId == datasetId).array;
  }

  void save(ValidationResult result)
  {
    store[result.recordId] = result;
  }

  void removeByDataset(TenantId tenantId, DatasetId datasetId)
  {
    RecordId[] toRemove;
    foreach (ref r; store.byValue())
      if (r.tenantId == tenantId && r.datasetId == datasetId)
        toRemove ~= r.recordId;
    foreach (id; toRemove)
      store.remove(id);
  }
}

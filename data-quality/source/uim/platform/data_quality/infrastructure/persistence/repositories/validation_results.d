/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_quality.infrastructure.persistence.repositories.validation_results;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:
class ValidationResultRepository : TenantRepository!(DqValidationResult, ValidationResultId), IValidationResultRepository {

  bool existsByRecord(TenantId tenantId, RecordId recordId) {
    return !findByRecord(tenantId, recordId).isNull;
  }

  DqValidationResult findByRecord(TenantId tenantId, RecordId recordId) {
    auto results = findByTenant(tenantId).filter!(result => result.recordId == recordId).array;
    if (results.length == 0) {
      return DqValidationResult.init;
    }
    return results[0];
  }

  void removeByRecord(TenantId tenantId, RecordId recordId) {
    auto result = findByRecord(tenantId, recordId);
    if (!result.isNull) {
      remove(result);
    }
  }

  size_t countByDataset(TenantId tenantId, DatasetId datasetId) {
    size_t count;
    foreach (result; findByTenant(tenantId)) {
      if (result.datasetId == datasetId) {
        count++;
      }
    }
    return count;
  }

  DqValidationResult[] filterByDataset(DqValidationResult[] results, DatasetId datasetId) {
    return results.filter!(r => r.datasetId == datasetId).array;
  }

  DqValidationResult[] findByDataset(TenantId tenantId, DatasetId datasetId) {
    return filterByDataset(findByTenant(tenantId), datasetId);
  }

  void removeByDataset(TenantId tenantId, DatasetId datasetId) {
    findByDataset(tenantId, datasetId).each!(entity => remove(entity));
  }

}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.quality.domain.ports.repositories.validation_results;

// import uim.platform.data.quality.domain.types;
// import uim.platform.data.quality.domain.entities.validation_result;
import uim.platform.data.quality;

mixin(ShowModule!());

@safe:
/// Port for persisting validation results.
interface ValidationResultRepository : ITenantRepository!(ValidationResult, ValidationResultId) {

  bool existsByRecord(TenantId tenantId, RecordId recordId);
  ValidationResult findByRecord(TenantId tenantId, RecordId recordId);
  void removeByRecord(TenantId tenantId, RecordId recordId);

  size_t countByDataset(TenantId tenantId, DatasetId datasetId);
  ValidationResult[] findByDataset(TenantId tenantId, DatasetId datasetId);
  void removeByDataset(TenantId tenantId, DatasetId datasetId);

}

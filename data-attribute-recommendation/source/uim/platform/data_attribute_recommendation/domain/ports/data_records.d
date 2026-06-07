/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_attribute_recommendation.domain.ports.data_records;

// import uim.platform.data_attribute_recommendation.domain.types;
// import uim.platform.data_attribute_recommendation.domain.entities.data_record;
import uim.platform.data_attribute_recommendation;

// mixin(ShowModule!());

@safe:
interface DataRecordRepository : ITenantRepository!(DataRecord, DataRecordId) {

  size_t countByDataset(TenantId tenantId, DatasetId datasetId);
  DataRecord[] findByDataset(TenantId tenantId, DatasetId datasetId);
  void removeByDataset(TenantId tenantId, DatasetId datasetId);

  size_t countByStatus(TenantId tenantId, DatasetId datasetId, RecordStatus status);
  DataRecord[] findByStatus(TenantId tenantId, DatasetId datasetId, RecordStatus status);
  void removeByStatus(TenantId tenantId, DatasetId datasetId, RecordStatus status);
}

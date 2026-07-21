/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_attribute_recommendation.infrastructure.persistence.repositories.data_records;


// import uim.platform.data_attribute_recommendation.domain.entities.data_record;

import uim.platform.data_attribute_recommendation;

mixin(ShowModule!());

@safe:
class MemoryDataRecordRepository : TenantRepository!(DataRecord, DataRecordId), DataRecordRepository {

  size_t countByDataset(TenantId tenantId, DatasetId datasetId) {
    return findByDataset(tenantId, datasetId).length;
  }

  DataRecord[] filterByDataset(DataRecord[] records, DatasetId datasetId) {
    return records.filter!(e => e.datasetId == datasetId).array;
  }
  DataRecord[] findByDataset(TenantId tenantId, DatasetId datasetId) {
    return filterByDataset(findByTenant(tenantId), datasetId);
  }

  void removeByDataset(TenantId tenantId, DatasetId datasetId) {
    findByDataset(tenantId, datasetId).each!(e => remove(e));
  }

  size_t countByStatus(TenantId tenantId, DatasetId datasetId, RecordStatus status) {
    return findByStatus(tenantId, datasetId, status).length;
  }
  DataRecord[] filterByStatus(DataRecord[] records, RecordStatus status) {
    return records.filter!(e => e.status == status).array;
  }
  DataRecord[] findByStatus(TenantId tenantId, DatasetId datasetId, RecordStatus status) {
    return filterByStatus(findByDataset(tenantId, datasetId), status);
  }
  void removeByStatus(TenantId tenantId, DatasetId datasetId, RecordStatus status) {
    findByStatus(tenantId, datasetId, status).each!(e => remove(e));
  }

}

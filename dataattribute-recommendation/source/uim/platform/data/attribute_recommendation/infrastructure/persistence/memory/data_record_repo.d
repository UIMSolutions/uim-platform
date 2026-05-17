/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.infrastructure.persistence.memory.data_records;

// import uim.platform.data.attribute_recommendation.domain.types;
// import uim.platform.data.attribute_recommendation.domain.entities.data_record;
// import uim.platform.data.attribute_recommendation.domain.ports.repositories.data_records;
import uim.platform.data.attribute_recommendation;

mixin(ShowModule!());

@safe:
class MemoryDataRecordRepository : DataRecordRepository {
  private DataRecord[string] store;

  void save(DataRecord entity) {
    store[entity.id] = entity;
  }

  void update(DataRecord entity) {
    store[entity.id] = entity;
  }

  void remove(TenantId tenantId, DataRecordId id) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        removeById(id);
  }

  void removeByDataset(TenantId tenantId, DatasetId datasetId) {
    string[] toRemove;
    foreach (e; findByTenant(tenantId))
      if (e.datasetId == datasetId)
        toRemove ~= e.id;
    foreach (id; toRemove)
      removeById(id);
  }

  DataRecord findById(TenantId tenantId, DataRecordId id) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  DataRecord[] findByDataset(TenantId tenantId, DatasetId datasetId) {
    DataRecord[] result;
    foreach (e; findByTenant(tenantId))
      if (e.datasetId == datasetId)
        result ~= e;
    return result;
  }

  DataRecord[] findByStatus(TenantId tenantId, DatasetId datasetId, RecordStatus status) {
    DataRecord[] result;
    foreach (e; findByTenant(tenantId))
      if (e.datasetId == datasetId && e.status == status)
        result ~= e;
    return result;
  }

  size_t countByDataset(TenantId tenantId, DatasetId datasetId) {
    size_t count;
    foreach (e; findByTenant(tenantId))
      if (e.datasetId == datasetId)
        count++;
    return count;
  }
}

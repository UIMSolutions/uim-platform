/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.infrastructure.persistence
  .memory.data_record_repo;

import uim.platform.data.attribute_recommendation.domain.types;
import uim.platform.data.attribute_recommendation.domain.entities.data_record;
import uim.platform.data.attribute_recommendation.domain.ports.repositories.data_records;

class MemoryDataRecordRepository : DataRecordRepository {
  private DataRecord[string] store;

  void save(DataRecord entity)
  {
    store[entity.id] = entity;
  }

  void update(DataRecord entity)
  {
    store[entity.id] = entity;
  }

  void remove(DataRecordId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }

  void removeByDataset(DatasetId datasetId, TenantId tenantId)
  {
    string[] toRemove;
    foreach (ref e; store)
      if (e.datasetId == datasetId && e.tenantId == tenantId)
        toRemove ~= e.id;
    foreach (id; toRemove)
      store.remove(id);
  }

  DataRecord* findById(DataRecordId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  DataRecord[] findByDataset(DatasetId datasetId, TenantId tenantId)
  {
    DataRecord[] result;
    foreach (ref e; store)
      if (e.datasetId == datasetId && e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  DataRecord[] findByStatus(DatasetId datasetId, TenantId tenantId, RecordStatus status)
  {
    DataRecord[] result;
    foreach (ref e; store)
      if (e.datasetId == datasetId && e.tenantId == tenantId && e.status == status)
        result ~= e;
    return result;
  }

  long countByDataset(DatasetId datasetId, TenantId tenantId)
  {
    long count;
    foreach (ref e; store)
      if (e.datasetId == datasetId && e.tenantId == tenantId)
        count++;
    return count;
  }
}

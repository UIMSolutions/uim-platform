module uim.platform.data_attribute_recommendation.infrastructure.persistence.memory.in_memory_data_record_repo;

import domain.types;
import domain.entities.data_record;
import domain.ports.data_record_repository;

class MemoryDataRecordRepository : DataRecordRepository
{
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

module uim.platform.data_attribute_recommendation.infrastructure.persistence.memory.dataset_repo;

import uim.platform.data_attribute_recommendation.domain.types;
import uim.platform.data_attribute_recommendation.domain.entities.dataset;
import uim.platform.data_attribute_recommendation.domain.ports.dataset_repository;

class MemoryDatasetRepository : DatasetRepository
{
  private Dataset[string] store;

  void save(Dataset entity)
  {
    store[entity.id] = entity;
  }

  void update(Dataset entity)
  {
    store[entity.id] = entity;
  }

  void remove(DatasetId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }

  Dataset* findById(DatasetId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  Dataset* findByName(TenantId tenantId, string name)
  {
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.name == name)
        return &e;
    return null;
  }

  Dataset[] findByTenant(TenantId tenantId)
  {
    Dataset[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  Dataset[] findByStatus(TenantId tenantId, DatasetStatus status)
  {
    Dataset[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.status == status)
        result ~= e;
    return result;
  }

  Dataset[] findByDataType(TenantId tenantId, DataType dataType)
  {
    Dataset[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.dataType == dataType)
        result ~= e;
    return result;
  }
}

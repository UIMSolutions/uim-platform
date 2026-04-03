module uim.platform.data_attribute_recommendation.infrastructure.persistence.memory.model_config_repo;

import domain.types;
import domain.entities.model_configuration;
import domain.ports.model_config_repository;

class MemoryModelConfigRepository : ModelConfigRepository
{
  private ModelConfiguration[string] store;

  void save(ModelConfiguration entity)
  {
    store[entity.id] = entity;
  }

  void update(ModelConfiguration entity)
  {
    store[entity.id] = entity;
  }

  void remove(ModelConfigId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }

  ModelConfiguration* findById(ModelConfigId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  ModelConfiguration* findByName(TenantId tenantId, string name)
  {
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.name == name)
        return &e;
    return null;
  }

  ModelConfiguration[] findByTenant(TenantId tenantId)
  {
    ModelConfiguration[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  ModelConfiguration[] findByDataset(DatasetId datasetId, TenantId tenantId)
  {
    ModelConfiguration[] result;
    foreach (ref e; store)
      if (e.datasetId == datasetId && e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  ModelConfiguration[] findByStatus(TenantId tenantId, ModelConfigStatus status)
  {
    ModelConfiguration[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.status == status)
        result ~= e;
    return result;
  }
}

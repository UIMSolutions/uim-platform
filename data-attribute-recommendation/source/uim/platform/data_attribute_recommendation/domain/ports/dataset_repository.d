module uim.platform.data_attribute_recommendation.domain.ports.dataset_repository;

import uim.platform.data_attribute_recommendation.domain.types;
import uim.platform.data_attribute_recommendation.domain.entities.dataset;

interface DatasetRepository
{
  Dataset[] findByTenant(TenantId tenantId);
  Dataset* findById(DatasetId id, TenantId tenantId);
  Dataset* findByName(TenantId tenantId, string name);
  Dataset[] findByStatus(TenantId tenantId, DatasetStatus status);
  Dataset[] findByDataType(TenantId tenantId, DataType dataType);
  void save(Dataset dataset);
  void update(Dataset dataset);
  void remove(DatasetId id, TenantId tenantId);
}

module uim.platform.data.attribute_recommendation.domain.ports.data_record_repository;

import uim.platform.data.attribute_recommendation.domain.types;
import uim.platform.data.attribute_recommendation.domain.entities.data_record;

interface DataRecordRepository
{
  DataRecord[] findByDataset(DatasetId datasetId, TenantId tenantId);
  DataRecord* findById(DataRecordId id, TenantId tenantId);
  DataRecord[] findByStatus(DatasetId datasetId, TenantId tenantId, RecordStatus status);
  long countByDataset(DatasetId datasetId, TenantId tenantId);
  void save(DataRecord record);
  void update(DataRecord record);
  void remove(DataRecordId id, TenantId tenantId);
  void removeByDataset(DatasetId datasetId, TenantId tenantId);
}

module domain.ports.data_record_repository;

import domain.types;
import domain.entities.data_record;

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

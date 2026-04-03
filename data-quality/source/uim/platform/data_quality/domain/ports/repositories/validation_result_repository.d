module uim.platform.xyz.domain.ports.validation_result_repository;

import uim.platform.xyz.domain.types;
import uim.platform.xyz.domain.entities.validation_result;

/// Port for persisting validation results.
interface ValidationResultRepository
{
    ValidationResult[] findByTenant(TenantId tenantId);
    ValidationResult* findByRecord(RecordId recordId, TenantId tenantId);
    ValidationResult[] findByDataset(TenantId tenantId, DatasetId datasetId);
    void save(ValidationResult result);
    void removeByDataset(TenantId tenantId, DatasetId datasetId);
}

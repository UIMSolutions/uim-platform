module uim.platform.data.quality.domain.ports.validation_result_repository;

import uim.platform.data.quality.domain.types;
import uim.platform.data.quality.domain.entities.validation_result;

/// Port for persisting validation results.
interface ValidationResultRepository
{
    ValidationResult[] findByTenant(TenantId tenantId);
    ValidationResult* findByRecord(RecordId recordId, TenantId tenantId);
    ValidationResult[] findByDataset(TenantId tenantId, DatasetId datasetId);
    void save(ValidationResult result);
    void removeByDataset(TenantId tenantId, DatasetId datasetId);
}

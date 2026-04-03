module uim.platform.xyz.domain.ports.cleansing_job_repository;

import uim.platform.xyz.domain.types;
import uim.platform.xyz.domain.entities.cleansing_job;

/// Port for persisting cleansing job records.
interface CleansingJobRepository
{
    CleansingJob[] findByTenant(TenantId tenantId);
    CleansingJob* findById(CleansingJobId id, TenantId tenantId);
    CleansingJob[] findByDataset(TenantId tenantId, DatasetId datasetId);
    CleansingJob[] findByStatus(TenantId tenantId, JobStatus status);
    void save(CleansingJob job);
    void update(CleansingJob job);
}

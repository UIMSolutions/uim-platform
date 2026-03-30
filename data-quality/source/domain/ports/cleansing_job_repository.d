module domain.ports.cleansing_job_repository;

import domain.types;
import domain.entities.cleansing_job;

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

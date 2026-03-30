module domain.ports.export_job_repository;

import domain.types;
import domain.entities.export_job;

/// Port for persisting export job records.
interface ExportJobRepository
{
    ExportJob[] findByTenant(TenantId tenantId);
    ExportJob* findById(ExportJobId id, TenantId tenantId);
    void save(ExportJob job);
    void update(ExportJob job);
    void remove(ExportJobId id, TenantId tenantId);
}

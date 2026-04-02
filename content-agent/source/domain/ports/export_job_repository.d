module uim.platform.content_agent.domain.ports.export_job_repository;

import domain.entities.export_job;
import domain.types;

/// Port: outgoing - export job persistence.
interface ExportJobRepository
{
    ExportJob findById(ExportJobId id);
    ExportJob[] findByTenant(TenantId tenantId);
    ExportJob[] findByPackage(ContentPackageId packageId);
    ExportJob[] findByStatus(TenantId tenantId, ExportStatus status);
    void save(ExportJob job);
    void update(ExportJob job);
    void remove(ExportJobId id);
}

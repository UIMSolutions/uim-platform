module uim.platform.content_agent.domain.ports.import_job_repository;

import domain.entities.import_job;
import domain.types;

/// Port: outgoing - import job persistence.
interface ImportJobRepository
{
    ImportJob findById(ImportJobId id);
    ImportJob[] findByTenant(TenantId tenantId);
    ImportJob[] findByPackage(ContentPackageId packageId);
    ImportJob[] findByStatus(TenantId tenantId, ImportStatus status);
    void save(ImportJob job);
    void update(ImportJob job);
    void remove(ImportJobId id);
}

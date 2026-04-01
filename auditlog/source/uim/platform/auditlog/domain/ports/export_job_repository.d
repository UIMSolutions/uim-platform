module uim.platform.auditlog.domain.ports.export_job_repository;

// import uim.platform.auditlog.domain.types;
// import uim.platform.auditlog.domain.entities.export_job;

import uim.platform.auditlog;
mixin(ShowModule!());

/// Port for persisting export job records.
@safe:
interface ExportJobRepository {
    ExportJob[] findByTenant(TenantId tenantId);

    bool existsById(ExportJobId id, TenantId tenantId);
    ExportJob findById(ExportJobId id, TenantId tenantId);

    void save(ExportJob job);
    void update(ExportJob job);
    void remove(ExportJobId id, TenantId tenantId);
}

module infrastructure.persistence.in_memory_export_repo;

import uim.platform.auditlog.domain.types;
import uim.platform.auditlog.domain.entities.export_job;
import uim.platform.auditlog.domain.ports.export_job_repository;

import std.algorithm : filter;
import std.array : array;

class InMemoryExportJobRepository : ExportJobRepository
{
    private ExportJob[ExportJobId] store;

    ExportJob[] findByTenant(TenantId tenantId)
    {
        return store.byValue().filter!(j => j.tenantId == tenantId).array;
    }

    ExportJob* findById(ExportJobId id, TenantId tenantId)
    {
        if (auto p = id in store)
            if (p.tenantId == tenantId)
                return p;
        return null;
    }

    void save(ExportJob job) { store[job.id] = job; }
    void update(ExportJob job) { store[job.id] = job; }
    void remove(ExportJobId id, TenantId tenantId)
    {
        if (auto p = id in store)
            if (p.tenantId == tenantId)
                store.remove(id);
    }
}

module infrastructure.persistence.in_memory_import_job_repo;

import domain.types;
import domain.entities.import_job;
import domain.ports.import_job_repository;

import std.algorithm : filter;
import std.array : array;

class InMemoryImportJobRepository : ImportJobRepository
{
    private ImportJob[ImportJobId] store;

    ImportJob findById(ImportJobId id)
    {
        if (auto p = id in store)
            return *p;
        return ImportJob.init;
    }

    ImportJob[] findByTenant(TenantId tenantId)
    {
        return store.byValue().filter!(e => e.tenantId == tenantId).array;
    }

    ImportJob[] findByPackage(ContentPackageId packageId)
    {
        return store.byValue().filter!(e => e.packageId == packageId).array;
    }

    ImportJob[] findByStatus(TenantId tenantId, ImportStatus status)
    {
        return store.byValue()
            .filter!(e => e.tenantId == tenantId && e.status == status)
            .array;
    }

    void save(ImportJob job) { store[job.id] = job; }
    void update(ImportJob job) { store[job.id] = job; }
    void remove(ImportJobId id) { store.remove(id); }
}

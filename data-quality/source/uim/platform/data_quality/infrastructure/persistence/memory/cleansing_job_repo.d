module uim.platform.xyz.infrastructure.persistence.memory.cleansing_job_repo;

import domain.types;
import domain.entities.cleansing_job;
import domain.ports.cleansing_job_repository;

import std.algorithm : filter;
import std.array : array;

class MemoryCleansingJobRepository : CleansingJobRepository
{
    private CleansingJob[CleansingJobId] store;

    CleansingJob[] findByTenant(TenantId tenantId)
    {
        return store.byValue().filter!(j => j.tenantId == tenantId).array;
    }

    CleansingJob* findById(CleansingJobId id, TenantId tenantId)
    {
        if (auto p = id in store)
            if (p.tenantId == tenantId)
                return p;
        return null;
    }

    CleansingJob[] findByDataset(TenantId tenantId, DatasetId datasetId)
    {
        return store.byValue()
            .filter!(j => j.tenantId == tenantId && j.datasetId == datasetId)
            .array;
    }

    CleansingJob[] findByStatus(TenantId tenantId, JobStatus status)
    {
        return store.byValue()
            .filter!(j => j.tenantId == tenantId && j.status == status)
            .array;
    }

    void save(CleansingJob job) { store[job.id] = job; }
    void update(CleansingJob job) { store[job.id] = job; }
}

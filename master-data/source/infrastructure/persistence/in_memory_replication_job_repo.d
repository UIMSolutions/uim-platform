module infrastructure.persistence.memory.replication_job_repo;

import domain.types;
import domain.entities.replication_job;
import domain.ports.replication_job_repository;

import std.algorithm : filter;
import std.array : array;

class InMemoryReplicationJobRepository : ReplicationJobRepository
{
    private ReplicationJob[ReplicationJobId] store;

    ReplicationJob findById(ReplicationJobId id)
    {
        if (auto p = id in store)
            return *p;
        return ReplicationJob.init;
    }

    ReplicationJob[] findByTenant(TenantId tenantId)
    {
        return store.byValue().filter!(e => e.tenantId == tenantId).array;
    }

    ReplicationJob[] findByStatus(TenantId tenantId, ReplicationJobStatus status)
    {
        return store.byValue()
            .filter!(e => e.tenantId == tenantId && e.status == status)
            .array;
    }

    ReplicationJob[] findByDistributionModel(TenantId tenantId, DistributionModelId modelId)
    {
        return store.byValue()
            .filter!(e => e.tenantId == tenantId && e.distributionModelId == modelId)
            .array;
    }

    void save(ReplicationJob job) { store[job.id] = job; }
    void update(ReplicationJob job) { store[job.id] = job; }
    void remove(ReplicationJobId id) { store.remove(id); }
}

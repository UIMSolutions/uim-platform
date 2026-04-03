module domain.ports.replication_job_repository;

import domain.entities.replication_job;
import domain.types;

/// Port: outgoing — replication job persistence.
interface ReplicationJobRepository
{
    ReplicationJob findById(ReplicationJobId id);
    ReplicationJob[] findByTenant(TenantId tenantId);
    ReplicationJob[] findByStatus(TenantId tenantId, ReplicationJobStatus status);
    ReplicationJob[] findByDistributionModel(TenantId tenantId, DistributionModelId modelId);
    void save(ReplicationJob job);
    void update(ReplicationJob job);
    void remove(ReplicationJobId id);
}

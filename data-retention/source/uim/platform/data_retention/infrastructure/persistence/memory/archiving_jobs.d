module uim.platform.data_retention.infrastructure.persistence.memory.archiving_jobs;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class MemoryArchivingJobRepository : ArchivingJobRepository {
    private ArchivingJob[ArchivingJobId] store;

    size_t countAll() { return store.length; }
    ArchivingJob[] findAll() { return store.byValue.array; }

    bool existsById(ArchivingJobId id) { return (id in store) ? true : false; }
    ArchivingJob findById(ArchivingJobId id) { return existsById(id) ? store[id] : ArchivingJob.init; }

    bool existsById(TenantId tenantId, ArchivingJobId id) { return (id in store) ? true : false; }
    ArchivingJob findById(TenantId tenantId, ArchivingJobId id) { return existsById(id) ? store[id] : ArchivingJob.init; }

    bool existsByTenant(TenantId tenantId) { return store.byValue.any!(a => a.tenantId == tenantId); }
    size_t countByTenant(TenantId tenantId) { return store.byValue.filter!(a => a.tenantId == tenantId).array.length; }
    ArchivingJob[] findByTenant(TenantId tenantId) { return store.byValue.filter!(a => a.tenantId == tenantId).array; }

    ArchivingJob[] findAll(TenantId tenantId) { return findByTenant(tenantId); }
    ArchivingJob[] findByApplicationGroup(TenantId tenantId, ApplicationGroupId groupId) {
        return findByTenant(tenantId).filter!(a => a.applicationGroupId == groupId).array;
    }
    ArchivingJob[] findByStatus(TenantId tenantId, ArchivingJobStatus status) {
        return findByTenant(tenantId).filter!(a => a.status == status).array;
    }

    void save(ArchivingJob a) { store[a.id] = a; }
    void save(TenantId tenantId, ArchivingJob a) { store[a.id] = a; }
    void update(ArchivingJob a) { store[a.id] = a; }
    void update(TenantId tenantId, ArchivingJob a) { store[a.id] = a; }
    void remove(ArchivingJobId id) { store.remove(id); }
    void remove(TenantId tenantId, ArchivingJobId id) { store.remove(id); }
}

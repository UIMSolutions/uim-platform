module uim.platform.data_retention.infrastructure.persistence.memory.archiving_jobs;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class MemoryArchivingJobRepository : TenantRepository!(ArchivingJob, ArchivingJobId), ArchivingJobRepository {

    // #region ByApplicationGroup
    size_t countByApplicationGroup(TenantId tenantId, ApplicationGroupId groupId) {
        return findByApplicationGroup(tenantId, groupId).length;
    }

    ArchivingJob[] filterByApplicationGroup(ArchivingJob[] jobs, ApplicationGroupId groupId) {
        return jobs.filter!(a => a.applicationGroupId == groupId).array;
    }

    ArchivingJob[] findByApplicationGroup(TenantId tenantId, ApplicationGroupId groupId) {
        return filterByApplicationGroup(findByTenant(tenantId), groupId);
    }

    void removeByApplicationGroup(TenantId tenantId, ApplicationGroupId groupId) {
        findByApplicationGroup(tenantId, groupId).each!(entity => remove(entity.id));
    }
    // #endregion ByApplicationGroup

    // #region ByStatus
    size_t countByStatus(TenantId tenantId, ArchivingJobStatus status) {
        return findByStatus(tenantId, status).length;
    }

    ArchivingJob[] filterByStatus(ArchivingJob[] jobs, ArchivingJobStatus status) {
        return jobs.filter!(a => a.status == status).array;
    }

    ArchivingJob[] findByStatus(TenantId tenantId, ArchivingJobStatus status) {
        return filterByStatus(findByTenant(tenantId), status);
    }

    void removeByStatus(TenantId tenantId, ArchivingJobStatus status) {
        findByStatus(tenantId, status).each!(entity => remove(entity.id));
    }
    // #endregion ByStatus

}

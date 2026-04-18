module uim.platform.data_retention.domain.ports.repositories.archiving_jobs;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

interface ArchivingJobRepository : ITenantRepository!(ArchivingJob, ArchivingJobId) {
    bool existsById(ArchivingJobId id);
    ArchivingJob findById(ArchivingJobId id);

    ArchivingJob[] findAll(TenantId tenantId);
    ArchivingJob[] findByApplicationGroup(TenantId tenantId, ApplicationGroupId groupId);
    ArchivingJob[] findByStatus(TenantId tenantId, ArchivingJobStatus status);

    void save(ArchivingJob a);
    void save(TenantId tenantId, ArchivingJob a);
    void update(ArchivingJob a);
    void update(TenantId tenantId, ArchivingJob a);
}

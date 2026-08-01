module uim.platform.data_retention.domain.ports.repositories.archiving_jobs;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

interface IArchivingJobRepository : ITenantRepository!(ArchivingJob, ArchivingJobId) {
    
    ArchivingJob[] findByApplicationGroup(TenantId tenantId, ApplicationGroupId groupId);
    ArchivingJob[] findByStatus(TenantId tenantId, ArchivingJobStatus status);

}

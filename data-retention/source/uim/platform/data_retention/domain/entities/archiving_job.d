module uim.platform.data_retention.domain.entities.archiving_job;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

struct ArchivingJob {
    ArchivingJobId id;
    TenantId tenantId;
    ApplicationGroupId applicationGroupId;
    ArchivingOperationType operationType = ArchivingOperationType.archive;
    ArchivingJobStatus status = ArchivingJobStatus.scheduled;
    string selectionCriteria;
    long scheduledAt;
    long startedAt;
    long completedAt;
    int recordsProcessed;
    int recordsFailed;
    string errorMessage;
    string createdBy;
    long createdAt;
    long updatedAt;
}

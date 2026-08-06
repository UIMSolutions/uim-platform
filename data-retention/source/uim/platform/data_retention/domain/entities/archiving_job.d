module uim.platform.data_retention.domain.entities.archiving_job;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

struct ArchivingJob {
    mixin TenantEntity!(ArchivingJobId);
    
    ApplicationGroupId groupId;
    ArchivingOperationType operationType = ArchivingOperationType.archive;
    ArchivingJobStatus status = ArchivingJobStatus.scheduled;
    string selectionCriteria;
    long scheduledAt;
    long startedAt;
    long completedAt;
    int recordsProcessed;
    int recordsFailed;
    string errorMessage;
    
    Json toJson() const {
        return entityToJson
            .set("applicationGroupId", groupId)
            .set("operationType", operationType.toString)
            .set("status", status.toString)
            .set("selectionCriteria", selectionCriteria)
            .set("scheduledAt", scheduledAt)
            .set("startedAt", startedAt)
            .set("completedAt", completedAt)
            .set("recordsProcessed", recordsProcessed)
            .set("recordsFailed", recordsFailed)
            .set("errorMessage", errorMessage);
    }
}

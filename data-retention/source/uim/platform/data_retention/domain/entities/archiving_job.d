module uim.platform.data_retention.domain.entities.archiving_job;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

struct ArchivingJob {
    mixin TenantEntity!(ArchivingJobId);
    
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
    
    Json toJson() const {
        return Json.entityToJson
            .set("applicationGroupId", applicationGroupId)
            .set("operationType", operationType.to!string)
            .set("status", status.to!string)
            .set("selectionCriteria", selectionCriteria)
            .set("scheduledAt", scheduledAt)
            .set("startedAt", startedAt)
            .set("completedAt", completedAt)
            .set("recordsProcessed", recordsProcessed)
            .set("recordsFailed", recordsFailed)
            .set("errorMessage", errorMessage);
    }
}

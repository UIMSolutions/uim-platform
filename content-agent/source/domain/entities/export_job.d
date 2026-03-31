module domain.entities.export_job;

import domain.types;

/// An export operation that packages and ships content to a transport queue or file.
struct ExportJob
{
    ExportJobId id;
    TenantId tenantId;
    ContentPackageId packageId;
    TransportRequestId transportRequestId;
    TransportQueueId queueId;
    ExportStatus status = ExportStatus.pending;
    string exportedFilePath;
    long exportedSizeBytes;
    string createdBy;
    long startedAt;
    long completedAt;
    string errorMessage;
}

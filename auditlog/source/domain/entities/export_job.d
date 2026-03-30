module domain.entities.export_job;

import domain.types;

/// An audit log export job.
struct ExportJob
{
    ExportJobId id;
    TenantId tenantId;
    UserId requestedBy;
    ExportFormat format_ = ExportFormat.json;
    ExportStatus status = ExportStatus.pending;
    AuditCategory[] categories;     // filter by category
    long timeFrom;
    long timeTo;
    string downloadUrl;             // set when completed
    long totalRecords;
    long createdAt;
    long completedAt;
    string errorMessage;
}

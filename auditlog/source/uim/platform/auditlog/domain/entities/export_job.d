module uim.platform.auditlog.domain.entities.export_job;

// import uim.platform.auditlog.domain.types;

import uim.platform.auditlog;
mixin(ShowModule!());

/// An audit log export job.
@safe:
struct ExportJob {
    ExportJobId id;
    TenantId tenantId;
    UserId requestedBy;
    ExportFormat format_ = ExportFormat.json;
    ExportStatus status = ExportStatus.pending;
    AuditCategory[] categories; // filter by category
    long timeFrom;
    long timeTo;
    string downloadUrl; // set when completed
    long totalRecords;
    long createdAt;
    long completedAt;
    string errorMessage;
}

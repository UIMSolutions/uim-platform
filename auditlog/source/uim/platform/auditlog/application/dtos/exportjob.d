module uim.platform.auditlog.application.dtos.exportjob;
import uim.platform.auditlog;

mixin(ShowModule!());

@safe:
struct CreateExportJobRequest {
  TenantId tenantId;
  UserId requestedBy;
  ExportFormat format_;
  AuditCategory[] categories;
  long timeFrom;
  long timeTo;
}

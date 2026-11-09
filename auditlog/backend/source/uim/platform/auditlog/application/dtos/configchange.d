module uim.platform.auditlog.application.dtos.configchange;
import uim.platform.auditlog;

mixin(ShowModule!());

@safe:
struct WriteConfigChangeLogRequest {
  TenantId tenantId;
  UserId changedBy;
  string configType;
  string configObjectId;
  AuditAttribute[] changes;
  string reason;
}
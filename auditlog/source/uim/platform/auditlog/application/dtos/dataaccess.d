module uim.platform.auditlog.application.dtos.dataaccess;
import uim.platform.auditlog;

mixin(ShowModule!());

@safe:
struct WriteDataAccessLogRequest {
  TenantId tenantId;
  
  UserId accessedBy;
  string dataSubject;
  string dataObjectType;
  string dataObjectId;
  string[] accessedFields;
  string purpose;
  string channel;
}
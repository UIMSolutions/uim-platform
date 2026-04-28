module uim.platform.auditlog.application.dtos.retentionpolicy;
import uim.platform.auditlog;

mixin(ShowModule!());

@safe:
struct CreateRetentionPolicyRequest {
  TenantId tenantId;
  string name;
  string description;
  int retentionDays;
  AuditCategory[] categories;
  bool isDefault;
}



struct UpdateRetentionPolicyRequest {
  RetentionPolicyId id;
  TenantId tenantId;
  string name;
  string description;
  int retentionDays;
  AuditCategory[] categories;
  RetentionStatus status;
}
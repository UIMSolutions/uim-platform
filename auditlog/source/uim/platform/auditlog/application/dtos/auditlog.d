module uim.platform.auditlog.application.dtos.auditlog;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

struct CreateAuditConfigRequest {
  TenantId tenantId;
  string name;
  bool logDataAccess;
  bool logDataModification;
  bool logSecurityEvents;
  bool logConfigurationChanges;
  bool enableDataMasking;
  string[] maskedFields;
  string[] excludedServices;
  AuditSeverity minimumSeverity;
  int rateLimitPerSecond;
}

@safe:
struct UpdateAuditConfigRequest {
  AuditConfigId id;
  TenantId tenantId;
  string name;
  ConfigStatus status;
  bool logDataAccess;
  bool logDataModification;
  bool logSecurityEvents;
  bool logConfigurationChanges;
  bool enableDataMasking;
  string[] maskedFields;
  string[] excludedServices;
  AuditSeverity minimumSeverity;
  int rateLimitPerSecond;
}
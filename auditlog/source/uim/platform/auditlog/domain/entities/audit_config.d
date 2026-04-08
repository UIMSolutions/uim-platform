/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.domain.entities.audit_config;

// import uim.platform.auditlog.domain.types;
import uim.platform.auditlog;

mixin(ShowModule!());

@safe:
/// Tenant-level audit logging configuration.
struct AuditConfig {
  AuditConfigId id;
  TenantId tenantId;
  string name;
  ConfigStatus status = ConfigStatus.enabled;
  bool logDataAccess = true;
  bool logDataModification = true;
  bool logSecurityEvents = true;
  bool logConfigurationChanges = true;
  bool enableDataMasking; // mask sensitive fields
  string[] maskedFields; // field names to mask
  string[] excludedServices; // services exempt from logging
  AuditSeverity minimumSeverity = AuditSeverity.info;
  int rateLimitPerSecond = 8; // per-tenant rate limit
  long createdAt;
  long updatedAt;

  Json toJson() const {
    return Json.emptyObject
      .set("id", id.toString)
      .set("tenantId", tenantId.toString)
      .set("name", name)
      .set("status", status.to!string)
      .set("logDataAccess", logDataAccess)
      .set("logDataModification", logDataModification)
      .set("logSecurityEvents", logSecurityEvents)
      .set("logConfigurationChanges", logConfigurationChanges)
      .set("enableDataMasking", enableDataMasking)
      .set("maskedFields", maskedFields.toJson)
      .set("excludedServices", excludedServices.toJson)
      .set("minimumSeverity", minimumSeverity.to!string)
      .set("rateLimitPerSecond", rateLimitPerSecond)
      .set("createdAt", createdAt)
      .set("updatedAt", updatedAt);
  }
}

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
  mixin TenantEntity!(AuditConfigId); // adds id, tenantId, createdAt, updatedAt

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

  void updateFromRequest(UpdateAuditConfigRequest req) {
    id = req.id;
    tenantId = req.tenantId;
    name = req.name.length > 0 ? req.name : name;
    status = req.status;
    logDataAccess = req.logDataAccess;
    logDataModification = req.logDataModification;
    logSecurityEvents = req.logSecurityEvents;
    logConfigurationChanges = req.logConfigurationChanges;
    enableDataMasking = req.enableDataMasking;
    maskedFields = req.maskedFields;
    excludedServices = req.excludedServices;
    minimumSeverity = req.minimumSeverity;
    rateLimitPerSecond = req.rateLimitPerSecond > 0 ? req.rateLimitPerSecond
      : rateLimitPerSecond;
    updatedAt = Clock.currStdTime();

  }

  Json toJson() const {
    return entityToJson()
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
      .set("rateLimitPerSecond", rateLimitPerSecond);
  }

  static AuditConfig createDefault(TenantId tenantId) {
    AuditConfig cfg;
    cfg.createEntity(tenantId);
    cfg.name = "Default";
    cfg.status = ConfigStatus.enabled;
    cfg.logDataAccess = true;
    cfg.logDataModification = true;
    cfg.logSecurityEvents = true;
    cfg.logConfigurationChanges = true;
    cfg.enableDataMasking = false;
    cfg.maskedFields = [];
    cfg.excludedServices = [];
    cfg.minimumSeverity = AuditSeverity.info;
    cfg.rateLimitPerSecond = 8;
    return cfg;
  }

  static createFromJson(Json json) {
    AuditConfig cfg;
    cfg.id = AuditConfigId(json.getString("id"));
    cfg.tenantId = TenantId(json.getString("tenantId"));
    cfg.name = json.getString("name");
    cfg.status = json.getString("status").to!ConfigStatus;
    cfg.logDataAccess = json.toBoolean("logDataAccess");
    cfg.logDataModification = json.toBoolean("logDataModification");
    cfg.logSecurityEvents = json.toBoolean("logSecurityEvents");
    cfg.logConfigurationChanges = json.toBoolean("logConfigurationChanges");
    cfg.enableDataMasking = json.toBoolean("enableDataMasking");
    cfg.maskedFields = json.getArray("maskedFields").map!(e => e.to!string).array;
    cfg.excludedServices = json.getArray("excludedServices").map!(e => e.to!string).array;
    cfg.minimumSeverity = json.getString("minimumSeverity").to!AuditSeverity;
    cfg.rateLimitPerSecond = json.getInteger("rateLimitPerSecond");
    return cfg;
  }

}
///
unittest {
  AuditConfig config;
  config.id = AuditConfigId("config1");
  config.tenantId = TenantId("tenant1");
  config.name = "config1";
  config.status = ConfigStatus.enabled;
  config.logDataAccess = true;
  config.maskedFields = ["password", "ssn"];
  config.excludedServices = ["AuthService"];
  config.minimumSeverity = AuditSeverity.warning;
  config.rateLimitPerSecond = 5;

  auto json = config.toJson();
  assert(json["id"] == "config1");
  assert(json["tenantId"] == "tenant1");
  assert(json["name"] == "config1");
  assert(json["status"] == "enabled");
  assert(json["logDataAccess"] == true);
  assert(json["maskedFields"] == ["password", "ssn"].toJson);
  assert(json["excludedServices"] == ["AuthService"].toJson);
  assert(json["minimumSeverity"] == "warning");
  assert(json["rateLimitPerSecond"] == 5);
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.application.usecases.manage.audit_config;

// // import std.uuid;
// // import std.datetime.systime : Clock;
// 
// import uim.platform.auditlog.domain.types;
// import uim.platform.auditlog.domain.entities.audit_config;
// import uim.platform.auditlog.domain.ports.repositories.audit_configs;
// import uim.platform.auditlog.application.dto;

import uim.platform.auditlog;

mixin(ShowModule!());
@safe:
class ManageAuditConfigUseCase { // } { // TODO: UIMUseCase {
  private AuditConfigRepository configRepo;

  this(AuditConfigRepository configRepo) {
    this.configRepo = configRepo;
  }

  CommandResult createConfig(CreateAuditConfigRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");

    // Only one config per tenant
    if (configRepo.existsByTenant(req.tenantId))
      return CommandResult(false, "", "Audit configuration already exists for this tenant");

    auto now = Clock.currStdTime();
    auto cfg = AuditConfig();
    cfg.id = randomUUID;
    cfg.tenantId = req.tenantId;
    cfg.name = req.name.length > 0 ? req.name : "Default";
    cfg.status = ConfigStatus.enabled;
    cfg.logDataAccess = req.logDataAccess;
    cfg.logDataModification = req.logDataModification;
    cfg.logSecurityEvents = req.logSecurityEvents;
    cfg.logConfigurationChanges = req.logConfigurationChanges;
    cfg.enableDataMasking = req.enableDataMasking;
    cfg.maskedFields = req.maskedFields;
    cfg.excludedServices = req.excludedServices;
    cfg.minimumSeverity = req.minimumSeverity;
    cfg.rateLimitPerSecond = req.rateLimitPerSecond > 0 ? req.rateLimitPerSecond : 8;
    cfg.createdAt = now;
    cfg.updatedAt = cfg.createdAt;

    configRepo.save(cfg);
    return CommandResult(true, cfg.id.toString, "");
  }

  bool existsConfig(TenantId tenantId) {
    return configRepo.existsByTenant(tenantId);
  }

  AuditConfig getConfig(TenantId tenantId) {
    return configRepo.getByTenant(tenantId);
  }

  AuditConfig[] listConfigs() {
    return configRepo.findAll();
  }

  CommandResult updateConfig(UpdateAuditConfigRequest req) {
    if (!configRepo.existsById(req.id))
      return CommandResult(false, "", "Audit config not found");

    auto cfg = configRepo.findById(req.id);
    if (req.name.length > 0)
      cfg.name = req.name;
    cfg.status = req.status;
    cfg.logDataAccess = req.logDataAccess;
    cfg.logDataModification = req.logDataModification;
    cfg.logSecurityEvents = req.logSecurityEvents;
    cfg.logConfigurationChanges = req.logConfigurationChanges;
    cfg.enableDataMasking = req.enableDataMasking;
    cfg.maskedFields = req.maskedFields;
    cfg.excludedServices = req.excludedServices;
    cfg.minimumSeverity = req.minimumSeverity;
    if (req.rateLimitPerSecond > 0)
      cfg.rateLimitPerSecond = req.rateLimitPerSecond;
    cfg.updatedAt = Clock.currStdTime();

    configRepo.update(cfg);
    return CommandResult(true, cfg.id.toString, "");
  }

  void deleteConfig(TenantId tenantId, AuditConfigId id) {
    configRepo.remove(tenantId, id);
  }
}

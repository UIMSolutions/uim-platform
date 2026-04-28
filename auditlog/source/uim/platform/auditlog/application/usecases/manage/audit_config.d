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
  private AuditConfigRepository configs;

  this(AuditConfigRepository configs) {
    this.configs = configs;
  }

  CommandResult createConfig(CreateAuditConfigRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");

    // Only one config per tenant
    if (configs.existsByTenant(req.tenantId))
      return CommandResult(false, "", "Audit configuration already exists for this tenant");

    AuditConfig config;
    config.initEntity(req.tenantId);
    
    config.name = req.name.length > 0 ? req.name : "Default";
    config.status = ConfigStatus.enabled;
    config.logDataAccess = req.logDataAccess;
    config.logDataModification = req.logDataModification;
    config.logSecurityEvents = req.logSecurityEvents;
    config.logConfigurationChanges = req.logConfigurationChanges;
    config.enableDataMasking = req.enableDataMasking;
    config.maskedFields = req.maskedFields;
    config.excludedServices = req.excludedServices;
    config.minimumSeverity = req.minimumSeverity;
    config.rateLimitPerSecond = req.rateLimitPerSecond > 0 ? req.rateLimitPerSecond : 8;
    
    configs.save(config);
    return CommandResult(true, config.id.toString, "");
  }

  bool existsConfig(TenantId tenantId) {
    return configs.existsByTenant(tenantId);
  }

  AuditConfig getConfig(TenantId tenantId) {
    return configs.getByTenant(tenantId);
  }

  AuditConfig[] listConfigs() {
    return configs.findAll();
  }

  CommandResult updateConfig(UpdateAuditConfigRequest req) {
    auto cfg = configs.findById(req.tenantId, req.id);
    if (cfg.isNull)
      return CommandResult(false, "", "Audit config not found");

    cfg.updateFromRequest(req);
    configs.update(cfg);
    return CommandResult(true, cfg.id.toString, "");
  }

  void deleteConfig(TenantId tenantId, AuditConfigId id) {
    configs.removeById(tenantId, id);
  }
}

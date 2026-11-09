/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.application.usecases.manage.audit_config;
 
import uim.platform.auditlog;

mixin(ShowModule!());
@safe:
/// Interactor: one audit configuration per tenant.
class ManageAuditConfigUseCase : IManageAuditConfigUseCase {
  protected IAuditConfigRepository configs;

  this(IAuditConfigRepository configs) {
    this.configs = configs;
  }

  UsecaseResult createAuditConfig(CreateAuditConfigRequest req) {
    if (req.tenantId.isEmpty)
      return UsecaseResult(false, "", "Tenant ID is required");

    // Only one config per tenant
    if (configs.countByTenant(req.tenantId) > 0)
      return UsecaseResult(false, "", "Audit configuration already exists for this tenant");

    auto config = AuditConfig(req.tenantId);
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
    return UsecaseResult(true, config.id.value, "");
  }

  bool existsAuditConfig(TenantId tenantId) {
    return configs.countByTenant(tenantId) > 0;
  }

  AuditConfig getAuditConfig(TenantId tenantId) {
    return configs.getByTenant(tenantId);
  }

  AuditConfig[] listAuditConfigs(TenantId tenantId) {
    return configs.findByTenant(tenantId);
  }

  UsecaseResult updateAuditConfig(UpdateAuditConfigRequest req) {
    auto cfg = configs.findById(req.tenantId, req.id);
    if (cfg.isNull)
      return UsecaseResult(false, "", "Audit config not found");

    cfg.updateFromRequest(req);
    configs.update(cfg);
    return UsecaseResult(true, cfg.id.value, "");
  }

  UsecaseResult deleteAuditConfig(TenantId tenantId, AuditConfigId id) {
    auto entity = configs.findById(tenantId, id);
    if (entity.isNull)
      return UsecaseResult(false, "", "Audit config not found");

    configs.remove(entity);
    return UsecaseResult(true, entity.id.value, ""); 
  }
}

///
unittest {
  mixin(ShowTest!("ManageAuditConfigUseCase"));

  auto uc = new ManageAuditConfigUseCase(new AuditConfigRepository());
  auto tenant = TenantId("t1");

  CreateAuditConfigRequest req;
  req.tenantId = tenant;
  req.logDataAccess = true;
  auto r = uc.createAuditConfig(req);
  assert(r.isSuccess);
  assert(uc.createAuditConfig(req).hasError); // only one per tenant
  assert(uc.existsAuditConfig(tenant));
  assert(uc.getAuditConfig(tenant).name == "Default");
  assert(uc.deleteAuditConfig(tenant, AuditConfigId(r.id)).isSuccess);
  assert(!uc.existsAuditConfig(tenant));
}

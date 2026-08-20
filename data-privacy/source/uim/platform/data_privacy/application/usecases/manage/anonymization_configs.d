/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_privacy.application.usecases.manage.anonymization_configs;

import uim.platform.data_privacy;

mixin(ShowModule!());

@safe:
class ManageAnonymizationConfigsUseCase {
  protected IAnonymizationConfigRepository repo;

  this(IAnonymizationConfigRepository repo) {
    this.repo = repo;
  }

  UsecaseResult createConfig(CreateAnonymizationConfigRequest req) {
    if (req.tenantId.isEmpty)
      return UsecaseResult(false, "", "Tenant ID is required");
      
    if (req.name.isEmpty)
      return UsecaseResult(false, "", "Name is required");

    auto c = AnonymizationConfig(req.tenantId);
    c.name = req.name;
    c.description = req.description;
    c.status = AnonymizationConfigStatus.draft;
    c.isReversible = req.isReversible;
    c.targetSystems = req.targetSystems;

    repo.save(c);
    return UsecaseResult(true, c.id.value, "");
  }

  AnonymizationConfig getConfig(TenantId tenantId, AnonymizationConfigId id) {
    return repo.findById(tenantId, id);
  }

  AnonymizationConfig[] listConfigs(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  UsecaseResult updateConfig(UpdateAnonymizationConfigRequest req) {
    auto c = repo.findById(req.tenantId, req.configId);
    if (c.isNull)
      return UsecaseResult(false, "", "Anonymization config not found");

    if (req.name.length > 0) c.name = req.name;
    if (req.description.length > 0) c.description = req.description;
    c.isReversible = req.isReversible;
    if (req.targetSystems.length > 0) c.targetSystems = req.targetSystems;
    c.updatedAt = currentTimestamp();

    repo.update(c);
    return UsecaseResult(true, c.id.value, "");
  }

  UsecaseResult activateConfig(TenantId tenantId, AnonymizationConfigId configId) {
    auto c = repo.findById(tenantId, configId);
    if (c.isNull)
      return UsecaseResult(false, "", "Anonymization config not found");

    c.status = AnonymizationConfigStatus.active;
    c.updatedAt = currentTimestamp();

    repo.update(c);
    return UsecaseResult(true, c.id.value, "");
  }

  UsecaseResult deleteConfig(TenantId tenantId, AnonymizationConfigId configId) {
    auto config = repo.findById(tenantId, configId);
    if (config.isNull)
      return UsecaseResult(false, "", "Anonymization config not found");

    repo.remove(config);
    return UsecaseResult(true, config.id.value, "");
  }
}

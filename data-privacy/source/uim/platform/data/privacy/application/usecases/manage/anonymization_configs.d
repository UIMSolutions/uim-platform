/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.application.usecases.manage.anonymization_configs;

import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class ManageAnonymizationConfigsUseCase : UIMUseCase {
  private AnonymizationConfigRepository repo;

  this(AnonymizationConfigRepository repo) {
    this.repo = repo;
  }

  CommandResult createConfig(CreateAnonymizationConfigRequest req) {
    if (req.tenantId.length == 0)
      return CommandResult("", "Tenant ID is required");
    if (req.name.length == 0)
      return CommandResult("", "Name is required");

    auto now = Clock.currStdTime();
    auto c = AnonymizationConfig();
    c.id = randomUUID().toString();
    c.tenantId = req.tenantId;
    c.name = req.name;
    c.description = req.description;
    c.status = AnonymizationConfigStatus.draft;
    c.isReversible = req.isReversible;
    c.targetSystems = req.targetSystems;
    c.createdAt = now;
    c.updatedAt = now;

    repo.save(c);
    return CommandResult(c.id, "");
  }

  AnonymizationConfig* getConfig(AnonymizationConfigId id, TenantId tenantId) {
    return repo.findById(id, tenantId);
  }

  AnonymizationConfig[] listConfigs(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult updateConfig(UpdateAnonymizationConfigRequest req) {
    auto c = repo.findById(req.id, req.tenantId);
    if (c is null)
      return CommandResult("", "Anonymization config not found");

    if (req.name.length > 0) c.name = req.name;
    if (req.description.length > 0) c.description = req.description;
    c.isReversible = req.isReversible;
    if (req.targetSystems.length > 0) c.targetSystems = req.targetSystems;
    c.updatedAt = Clock.currStdTime();

    repo.update(*c);
    return CommandResult(c.id, "");
  }

  CommandResult activateConfig(AnonymizationConfigId id, TenantId tenantId) {
    auto c = repo.findById(id, tenantId);
    if (c is null)
      return CommandResult("", "Anonymization config not found");

    c.status = AnonymizationConfigStatus.active;
    c.updatedAt = Clock.currStdTime();

    repo.update(*c);
    return CommandResult(c.id, "");
  }

  void deleteConfig(AnonymizationConfigId id, TenantId tenantId) {
    repo.remove(id, tenantId);
  }
}

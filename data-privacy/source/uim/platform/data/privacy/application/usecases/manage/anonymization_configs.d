/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.application.usecases.manage.anonymization_configs;

import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class ManageAnonymizationConfigsUseCase { // TODO: UIMUseCase {
  private AnonymizationConfigRepository repo;

  this(AnonymizationConfigRepository repo) {
    this.repo = repo;
  }

  CommandResult createConfig(CreateAnonymizationConfigRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.name.length == 0)
      return CommandResult(false, "", "Name is required");

    auto now = Clock.currStdTime();
    auto c = AnonymizationConfig();
    c.id = randomUUID();
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

  AnonymizationConfig* getConfig(TenantId tenantId, AnonymizationConfigId id) {
    return repo.findById(tenantId, id);
  }

  AnonymizationConfig[] listConfigs(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult updateConfig(UpdateAnonymizationConfigRequest req) {
    auto c = repo.findById(req.tenantId, req.id);
    if (c.isNull)
      return CommandResult(false, "", "Anonymization config not found");

    if (req.name.length > 0) c.name = req.name;
    if (req.description.length > 0) c.description = req.description;
    c.isReversible = req.isReversible;
    if (req.targetSystems.length > 0) c.targetSystems = req.targetSystems;
    c.updatedAt = Clock.currStdTime();

    repo.update(c);
    return CommandResult(c.id, "");
  }

  CommandResult activateConfig(TenantId tenantId, AnonymizationConfigId id) {
    auto c = repo.findById(tenantId, id);
    if (c.isNull)
      return CommandResult(false, "", "Anonymization config not found");

    c.status = AnonymizationConfigStatus.active;
    c.updatedAt = Clock.currStdTime();

    repo.update(c);
    return CommandResult(c.id, "");
  }

  void deleteConfig(TenantId tenantId, AnonymizationConfigId id) {
    repo.removeById(tenantId, id);
  }
}

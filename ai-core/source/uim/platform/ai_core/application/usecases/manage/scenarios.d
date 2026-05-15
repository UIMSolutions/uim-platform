/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.application.usecases.manage.scenarios;
// import uim.platform.ai_core.domain.types;
// import uim.platform.ai_core.domain.entities.scenario;
// import uim.platform.ai_core.domain.ports.repositories.scenarios;
// import uim.platform.ai_core.domain.services.scenario_validator;
// import uim.platform.ai_core.application.dto;


import uim.platform.ai_core;

mixin(ShowModule!()); 

@safe:
class ManageScenariosUseCase { // TODO: UIMUseCase {
  private ScenarioRepository repo;

  this(ScenarioRepository repo) {
    this.repo = repo;
  }

  CommandResult createScenario(CreateScenarioRequest r) {
    auto err = ScenarioValidator.validate(r.scenarioId, r.name);
    if (err.length > 0)
      return CommandResult(false, "", err);

    if (r.resourceGroupId.isEmpty)
      return CommandResult(false, "", "Resource group ID is required");

    auto existing = repo.findById(r.tenantId, r.resourceGroupId, r.scenarioId);
    if (!existing.isNull)
      return CommandResult(false, "", "Scenario already exists");

    Scenario s;
    s.id = r.scenarioId;
    s.tenantId = r.tenantId;
    s.resourceGroupId = r.resourceGroupId;
    s.name = r.name;
    s.description = r.description;
    s.labels = r.labels;

    import core.time : MonoTime;
    auto now = MonoTime.currTime.ticks;
    s.createdAt = now;
    s.updatedAt = now;

    repo.save(s);
    return CommandResult(true, s.id.value, "");
  }

  Scenario getScenario(TenantId tenantId, ResourceGroupId rgId, ScenarioId id) {
    return repo.findById(tenantId, rgId, id);
  }

  Scenario[] listScenarios(TenantId tenantId, ResourceGroupId rgId) {
    return repo.findByResourceGroup(tenantId, rgId);
  }

  CommandResult deleteScenario(TenantId tenantId, ResourceGroupId rgId, ScenarioId id) {
    auto entity = repo.findById(tenantId, rgId, id);
    if (entity.isNull)
      return CommandResult(false, "", "Scenario not found");

    repo.remove(entity);
    return CommandResult(true, entity.id.value, "");
  }

  size_t countScenarios(TenantId tenantId, ResourceGroupId rgId) {
    return repo.countByResourceGroup(tenantId, rgId);
  }
}

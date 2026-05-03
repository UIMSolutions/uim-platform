/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.application.usecases.manage.scenarios;

// import std.uuid;
// import std.datetime.systime : Clock;

// import uim.platform.integration.automation.domain.types;
// import uim.platform.integration.automation.domain.entities.integration_scenario;

// // import uim.platform.integration.automation.domain.ports.repositories.scenarios;
// import uim.platform.integration.automation.domain.ports;
// import uim.platform.integration.automation.application.dto;
import uim.platform.integration.automation;

mixin(ShowModule!());

@safe:
class ManageScenariosUseCase { // TODO: UIMUseCase {
  private ScenarioRepository repo;

  this(ScenarioRepository repo) {
    this.repo = repo;
  }

  CommandResult createScenario(CreateScenarioRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.name.length == 0)
      return CommandResult(false, "", "Scenario name is required");

    auto scenario = IntegrationScenario();
    scenario.id = randomUUID();
    scenario.tenantId = req.tenantId;
    scenario.name = req.name;
    scenario.description = req.description;
    scenario.category = req.category;
    scenario.version_ = req.version_.length > 0 ? req.version_ : "1.0";
    scenario.status = ScenarioStatus.draft;
    scenario.sourceSystemType = req.sourceSystemType;
    scenario.targetSystemType = req.targetSystemType;
    scenario.prerequisites = req.prerequisites;
    scenario.stepTemplates = req.stepTemplates;
    scenario.createdBy = req.createdBy;
    scenario.createdAt = Clock.currStdTime();
    scenario.updatedAt = scenario.createdAt;

    repo.save(scenario);
    return CommandResult(true, scenario.id.value, "");
  }

  IntegrationScenario getScenario(TenantId tenantId, ScenarioId id) {
    return repo.findById(tenantId, id);
  }

  IntegrationScenario[] listScenarios(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  IntegrationScenario[] listByCategory(TenantId tenantId, ScenarioCategory category) {
    return repo.findByCategory(tenantId, category);
  }

  IntegrationScenario[] listActive(TenantId tenantId) {
    return repo.findByStatus(tenantId, ScenarioStatus.active);
  }

  CommandResult updateScenario(UpdateScenarioRequest req) {
    if (req.isNull)
      return CommandResult(false, "", "Scenario ID is required");
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");

    auto existing = repo.findById(req.tenantId, req.id);
    if (existing.isNull)
      return CommandResult(false, "", "Scenario not found");

    auto updated = *existing;
    if (req.name.length > 0)
      updated.name = req.name;
    if (req.description.length > 0)
      updated.description = req.description;
    updated.category = req.category;
    if (req.version_.length > 0)
      updated.version_ = req.version_;
    updated.status = req.status;
    updated.sourceSystemType = req.sourceSystemType;
    updated.targetSystemType = req.targetSystemType;
    if (req.prerequisites.length > 0)
      updated.prerequisites = req.prerequisites;
    if (req.stepTemplates.length > 0)
      updated.stepTemplates = req.stepTemplates;
    updated.updatedAt = Clock.currStdTime();

    repo.update(updated);
    return CommandResult(true, updated.id.value, "");
  }

  CommandResult deleteScenario(TenantId tenantId, ScenarioId id) {
    auto existing = repo.findById(tenantId, id);
    if (existing.isNull)
      return CommandResult(false, "", "Scenario not found");

    repo.removeById(tenantId, id);
    return CommandResult(true, id.value, "");
  }
}

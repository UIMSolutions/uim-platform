module uim.platform.xyz.application.usecases.manage_scenarios;

import std.uuid;
import std.datetime.systime : Clock;

import uim.platform.xyz.domain.types;
import uim.platform.xyz.domain.entities.integration_scenario;
// import uim.platform.xyz.domain.ports.scenario_repository;
import uim.platform.xyz.domain.ports;
import uim.platform.xyz.application.dto;

class ManageScenariosUseCase {
  private ScenarioRepository repo;

  this(ScenarioRepository repo) {
    this.repo = repo;
  }

  CommandResult createScenario(CreateScenarioRequest req) {
    if (req.tenantId.length == 0)
      return CommandResult("", "Tenant ID is required");
    if (req.name.length == 0)
      return CommandResult("", "Scenario name is required");

    auto scenario = IntegrationScenario();
    scenario.id = randomUUID().toString();
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
    return CommandResult(scenario.id, "");
  }

  IntegrationScenario* getScenario(ScenarioId id, TenantId tenantId) {
    return repo.findById(id, tenantId);
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
    if (req.id.length == 0)
      return CommandResult("", "Scenario ID is required");
    if (req.tenantId.length == 0)
      return CommandResult("", "Tenant ID is required");

    auto existing = repo.findById(req.id, req.tenantId);
    if (existing is null)
      return CommandResult("", "Scenario not found");

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
    return CommandResult(updated.id, "");
  }

  CommandResult deleteScenario(ScenarioId id, TenantId tenantId) {
    auto existing = repo.findById(id, tenantId);
    if (existing is null)
      return CommandResult("", "Scenario not found");

    repo.remove(id, tenantId);
    return CommandResult(id, "");
  }
}

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



import uim.platform.ai_core;

mixin(ShowModule!()); 

@safe:
class ManageScenariosUseCase {
  protected IScenarioRepository repo;

  this(IScenarioRepository repo) {
    this.repo = repo;
  }

  UsecaseResult createScenario(CreateScenarioRequest r) {
    auto err = ScenarioValidator.validate(r.scenarioId.value, r.name);
    if (err.length > 0)
      return UsecaseResult(false, "", err);

    if (r.resourceGroupId.isEmpty)
      return UsecaseResult(false, "", "Resource group ID is required");

    auto existing = repo.findById(r.tenantId, r.resourceGroupId, r.scenarioId);
    if (!existing.isNull)
      return UsecaseResult(false, "", "Scenario already exists");

    auto s = Scenario(r.tenantId, r.scenarioId.isNull ? ScenarioId(createId()) : r.scenarioId); // , r.createdBy);
    s.resourceGroupId = r.resourceGroupId;
    s.name = r.name;
    s.description = r.description;
    s.labels = r.labels;

    repo.save(s);
    return UsecaseResult(true, s.id.value, "");
  }

  Scenario getScenario(TenantId tenantId, ResourceGroupId rgId, ScenarioId id) {
    return repo.findById(tenantId, rgId, id);
  }

  Scenario[] listScenarios(TenantId tenantId, ResourceGroupId rgId) {
    return repo.findByResourceGroup(tenantId, rgId);
  }

  UsecaseResult deleteScenario(TenantId tenantId, ResourceGroupId rgId, ScenarioId id) {
    auto entity = repo.findById(tenantId, rgId, id);
    if (entity.isNull)
      return UsecaseResult(false, "", "Scenario not found");

    repo.remove(entity);
    return UsecaseResult(true, entity.id.value, "");
  }

  size_t countScenarios(TenantId tenantId, ResourceGroupId rgId) {
    return repo.countByResourceGroup(tenantId, rgId);
  }
}

///
unittest {
//     auto repo = new ScenarioRepository();
//     auto usecase = new ManageScenariosUseCase(repo);
//     auto tenantId = TenantId("test-tenant");
// 
//     assert(usecase !is null);
}

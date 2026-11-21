/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.application.usecases.manage.scenarios;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

class ManageScenariosUseCase : AiCoreInteractor, IManageScenarios {
  this(AiCoreRepositories repos, IClock clock, IAiCoreEventPublisher events, LifecyclePolicy policy) {
    super(repos, clock, events, policy);
  }

  Scenario createScenario(CreateScenarioRequest r) {
    groupOf(r.tenantId, r.resourceGroupId);
    auto id = r.id.strip;
    requireResourceId(id, "scenario id");
    if (repos.scenarios.existsById(r.tenantId, r.resourceGroupId, ScenarioId(id)))
      throw AiCoreException.conflict("Scenario '" ~ id ~ "' already exists in resource group '" ~ r.resourceGroupId.value ~ "'");
    Scenario s;
    stampCreated!(Scenario, ScenarioId)(s, r.tenantId, r.actor, id, now);
    s.resourceGroupId = r.resourceGroupId;
    s.name = r.name.strip.length > 0 ? r.name.strip : id;
    s.description = r.description;
    s.labels = checkedLabels(r.labels);
    s.validate();
    repos.scenarios.save(s);
    emit("scenario.created", r.tenantId, resourceKey(r.resourceGroupId.value, id));
    return s;
  }

  Scenario updateScenario(UpdateScenarioRequest r) {
    auto s = getScenario(r.tenantId, r.resourceGroupId, ScenarioId(r.id));
    r.name.applyTo(s.name);
    r.description.applyTo(s.description);
    if (r.labels.isSet)
      s.labels = checkedLabels(r.labels.value);
    s.validate();
    stampUpdated(s, r.actor, now);
    repos.scenarios.save(s);
    return s;
  }

  Scenario getScenario(TenantId t, ResourceGroupId rg, ScenarioId id) {
    return scenarioOf(t, rg, id);
  }

  Scenario[] listScenarios(TenantId t, ResourceGroupId rg) {
    return repos.scenarios.findByGroup(t, rg);
  }

  void deleteScenario(TenantId t, ResourceGroupId rg, ScenarioId id) {
    scenarioOf(t, rg, id);
    auto executables = repos.executables.findByScenario(t, rg, id).length;
    auto configurations = repos.configurations.findByScenario(t, rg, id).length;
    auto artifacts = repos.artifacts.findByScenario(t, rg, id).length;
    if (executables + configurations + artifacts > 0)
      throw AiCoreException.ruleViolation(format("Scenario '%s' still has %d executable(s), %d configuration(s) and %d artifact(s)",
          id.value, executables, configurations, artifacts));
    repos.scenarios.removeById(t, rg, id);
    emit("scenario.deleted", t, resourceKey(rg.value, id.value));
  }
}

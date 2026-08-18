/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.application.usecases.manage.scenarios;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:
class ManageScenariosUseCase {
  protected IScenarioRepository scenarios;

  this(IScenarioRepository scenarios) {
    this.scenarios = scenarios;
  }

  CommandResult syncScenario(SyncScenarioRequest r) {
    auto s = Scenario(r.tenantId, r.scenarioId);
    s.connectionId = r.connectionId;
    s.name = r.name;
    s.description = r.description;
    s.labels = r.labels;
    
    scenarios.save(s);
    return CommandResult(true, s.id.value, "");
  }

  Scenario getScenario(TenantId tenantId, ConnectionId connectionId, ScenarioId id) {
    return scenarios.findById(tenantId, connectionId, id);
  }

  Scenario[] listScenarios(TenantId tenantId, ConnectionId connectionId) {
    return scenarios.findByConnection(tenantId, connectionId);
  }

  Scenario[] listScenarios(TenantId tenantId) {
    return scenarios.findByTenant(tenantId);
  }

  CommandResult deleteScenario(TenantId tenantId, ConnectionId connectionId, ScenarioId id) {
    auto scenario = scenarios.findById(tenantId, connectionId, id);
    if (scenario.isNull)
      return CommandResult(false, "", "Scenario not found");

    scenarios.remove(scenario);
    return CommandResult(true, scenario.id.value, "");
  }
}

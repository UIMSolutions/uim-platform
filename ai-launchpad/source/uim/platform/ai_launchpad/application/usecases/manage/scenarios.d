/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.application.usecases.manage.scenarios;
// import uim.platform.ai_launchpad.domain.ports.scenariossitories.scenarios;
// import uim.platform.ai_launchpad.domain.entities.scenario : Scenario;
// import uim.platform.ai_launchpad.domain.types;
// import uim.platform.ai_launchpad.application.dto;
import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:
class ManageScenariosUseCase { // TODO: UIMUseCase {
  private IScenarioRepository scenarios;

  this(IScenarioRepository scenarios) {
    this.scenarios = scenarios;
  }

  CommandResult sync(SyncScenarioRequest r) {
    Scenario s;
    s.initEntity();
    s.id = r.scenarioId;
    s.connectionId = r.connectionId;
    s.name = r.name;
    s.description = r.description;
    s.labels = r.labels;
    scenarios.save(s);
    return CommandResult(true, s.id.value, "");
  }

  Scenario getById(ConnectionId connectionId, ScenarioId id) {
    return scenarios.findById(connectionId, id);
  }

  Scenario[] listByConnection(ConnectionId connectionId) {
    return scenarios.findByConnection(connectionId);
  }

  Scenario[] listAll() {
    return scenarios.findAll();
  }

  CommandResult deleteScenario(ConnectionId connectionId, ScenarioId id) {
    auto scenario = scenarios.findById(connectionId, id);
    if (scenario.isNull)
      return CommandResult(false, "", "Scenario not found");

    scenarios.remove(scenario);
    return CommandResult(true, scenario.id.value, "");
  }
}

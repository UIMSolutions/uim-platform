/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving ports of integration scenarios and their task templates.
module uim.platform.integration_automation.ports.usecases.scenarios;

import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

interface IManageScenarios : IManageResource!(IntegrationScenario, ScenarioId, ScenarioInput) {
  IntegrationScenario activate(TenantId t, ScenarioId id, UserId actor);
  IntegrationScenario deprecate(TenantId t, ScenarioId id, UserId actor);
  IntegrationScenario archive(TenantId t, ScenarioId id, UserId actor);
  /// A draft copy with all task templates (newId "" = generated); the
  /// version is increased ("1.0" → "1.1").
  IntegrationScenario copy(TenantId t, ScenarioId id, string newId, UserId actor);
  /// Number of task templates per scenario id.
  long[string] templateCounts(TenantId t);
}

interface IManageScenarioTasks : IManageResource!(ScenarioTask, ScenarioTaskId, ScenarioTaskInput) {
  /// The templates of one scenario in sequence.
  ScenarioTask[] listOf(TenantId t, ScenarioId scenario);
}

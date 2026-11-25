/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Document collections. A record is a flat JSON object: the audit fields
/// (id, tenantId, createdAt/By, updatedAt/By — std time) plus the entity
/// attributes under their API names (references such as "workflowId" can
/// therefore be filtered without mapping).
module uim.platform.integration_automation.persistence.records.collections;

import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

enum Collections : string {
  systems = "ia.systems",
  destinations = "ia.destinations",
  scenarios = "ia.scenarios",
  scenarioTasks = "ia.scenarioTasks",
  workflows = "ia.workflows",
  workflowTasks = "ia.workflowTasks",
  executionLogs = "ia.executionLogs",
  users = "ia.users"
}

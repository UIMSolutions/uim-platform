/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Document collections. A record is a flat JSON object: the audit fields
/// (id, tenantId, createdAt/By, updatedAt/By — std time) plus the entity
/// attributes under their API names (references such as "connectionId" can
/// therefore be filtered without mapping).
module uim.platform.ai_launchpad.persistence.records.collections;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

enum Collections : string {
  workspaces = "ailp.workspaces",
  connections = "ailp.connections",
  resourceGroups = "ailp.resourceGroups",
  scenarios = "ailp.scenarios",
  configurations = "ailp.configurations",
  executions = "ailp.executions",
  deployments = "ailp.deployments",
  models = "ailp.models",
  datasets = "ailp.datasets",
  promptCollections = "ailp.promptCollections",
  prompts = "ailp.prompts",
  tiles = "ailp.tiles",
  roles = "ailp.roles",
  users = "ailp.users",
  logs = "ailp.logs"
}

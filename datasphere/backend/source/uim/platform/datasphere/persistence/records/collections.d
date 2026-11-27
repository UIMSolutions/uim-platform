/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Document collections. A record is a flat JSON object: the audit fields
/// (id, tenantId, createdAt/By, updatedAt/By — std time) plus the entity
/// attributes under their API names (references such as "spaceId" can
/// therefore be filtered without mapping).
module uim.platform.datasphere.persistence.records.collections;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

enum Collections : string {
  spaces = "dsp.spaces",
  members = "dsp.members",
  connections = "dsp.connections",
  remoteTables = "dsp.remoteTables",
  views = "dsp.views",
  dataFlows = "dsp.dataFlows",
  tasks = "dsp.tasks",
  taskChains = "dsp.taskChains",
  runs = "dsp.runs",
  accessControls = "dsp.accessControls",
  catalog = "dsp.catalog",
  users = "dsp.users"
}

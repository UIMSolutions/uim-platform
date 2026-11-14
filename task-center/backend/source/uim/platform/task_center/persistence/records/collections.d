/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Document collections. A record is a flat JSON object: the audit fields
/// (id, tenantId, createdAt/By, updatedAt/By — timestamps as std time) plus
/// the entity fields under their D names.
module uim.platform.task_center.persistence.records.collections;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

enum Collections : string {
  tasks = "taskcenter.tasks",
  definitions = "taskcenter.definitions",
  providers = "taskcenter.providers",
  comments = "taskcenter.comments",
  attachments = "taskcenter.attachments",
  actions = "taskcenter.actions",
  substitutions = "taskcenter.substitutions",
  filters = "taskcenter.filters"
}

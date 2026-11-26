/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Document collections. A record is a flat JSON object: the audit fields
/// (id, tenantId, createdAt/By, updatedAt/By — std time) plus the entity
/// attributes under their API names (references such as "bindingId" can
/// therefore be filtered without mapping).
module uim.platform.application_autoscaler.persistence.records.collections;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

enum Collections : string {
  bindings = "aas.bindings",
  policies = "aas.policies",
  rules = "aas.rules",
  schedules = "aas.schedules",
  metrics = "aas.metricSamples",
  events = "aas.scalingEvents",
  users = "aas.users"
}

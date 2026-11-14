/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Document collections. A record is a flat JSON object: the audit fields
/// (id, tenantId, createdAt/By, updatedAt/By — timestamps as std time) plus
/// the entity fields under their D names (shared_ is stored as "shared").
module uim.platform.service_manager.persistence.records.collections;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

enum Collections : string {
  platforms = "sm.platforms",
  serviceBrokers = "sm.serviceBrokers",
  serviceOfferings = "sm.serviceOfferings",
  servicePlans = "sm.servicePlans",
  serviceInstances = "sm.serviceInstances",
  serviceBindings = "sm.serviceBindings",
  operations = "sm.operations",
  labels = "sm.labels"
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Document collections. A record is a flat JSON object: the audit fields
/// (id, tenantId, createdAt/By, updatedAt/By — std time) plus the entity
/// attributes under their API names (references such as "subscriptionId"
/// can therefore be filtered without mapping).
module uim.platform.application_events.persistence.records.collections;

import uim.platform.application_events;

mixin(ShowModule!());

@safe:

enum Collections : string {
  formations = "aeh.formations",
  systems = "aeh.systems",
  topics = "aeh.topics",
  channels = "aeh.channels",
  subscriptions = "aeh.subscriptions",
  filters = "aeh.filters",
  messages = "aeh.messages",
  deadLetters = "aeh.deadLetters",
  users = "aeh.users"
}

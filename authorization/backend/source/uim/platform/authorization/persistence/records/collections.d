/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Document collections. A record is a flat JSON object: the audit fields
/// (id, tenantId, createdAt/By, updatedAt/By — timestamps as std time) plus
/// the entity fields; conditions are stored as an array of
/// {attribute, operator, value} objects.
module uim.platform.authorization.persistence.records.collections;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

enum AuthorizationCollections : string {
  applications = "ams.applications",
  applicationApis = "ams.applicationApis",
  policies = "ams.policies",
  assignments = "ams.assignments",
  decisions = "ams.decisions",
}

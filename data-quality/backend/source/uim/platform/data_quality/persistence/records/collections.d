/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Document collections. A record is a flat JSON object: the audit fields
/// (id, tenantId, createdAt/By, updatedAt/By — std time) plus the entity
/// fields. Resources inside a dataset are stored under the key
/// "<datasetId>~<id>" and carry "datasetId" for fast filtering.
module uim.platform.data_quality.persistence.records.collections;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

enum Collections : string {
  datasets = "dq.datasets",
  records = "dq.records",
  validationRules = "dq.validationRules",
  violations = "dq.violations",
  cleansingRules = "dq.cleansingRules",
  cleansingJobs = "dq.cleansingJobs",
  matchGroups = "dq.matchGroups",
  columnProfiles = "dq.columnProfiles",
  addresses = "dq.addresses",
  snapshots = "dq.snapshots",
  users = "dq.users"
}

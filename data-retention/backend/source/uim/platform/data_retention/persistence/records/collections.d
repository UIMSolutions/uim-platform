/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Document collections. A record is a flat JSON object: the audit fields
/// (id, tenantId, createdAt/By, updatedAt/By — std time) plus the entity
/// attributes under their API names (references such as
/// "businessPurposeId" can therefore be filtered without mapping).
module uim.platform.data_retention.persistence.records.collections;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

enum Collections : string {
  applicationGroups = "dr.applicationGroups",
  legalEntities = "dr.legalEntities",
  dataSubjectRoles = "dr.dataSubjectRoles",
  businessPurposes = "dr.businessPurposes",
  legalGrounds = "dr.legalGrounds",
  residenceRules = "dr.residenceRules",
  retentionRules = "dr.retentionRules",
  dataSubjects = "dr.dataSubjects",
  deletionRequests = "dr.deletionRequests",
  archivingJobs = "dr.archivingJobs",
  users = "dr.users"
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The complete set of driving ports — what every adapter (REST, OData,
/// CLI, GUI, workers) may call.
module uim.platform.data_retention.ports.driving;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

struct DrPorts {
  IManageApplicationGroups applicationGroups;
  IManageLegalEntities legalEntities;
  IManageDataSubjectRoles dataSubjectRoles;
  IManageBusinessPurposes businessPurposes;
  IManageLegalGrounds legalGrounds;
  IManageResidenceRules residenceRules;
  IManageRetentionRules retentionRules;
  IManageDataSubjects dataSubjects;
  IRetentionChecks checks;
  IManageDeletionRequests deletionRequests;
  IManageArchivingJobs archivingJobs;
  IDrStatisticsService statistics;
  IDrLookups lookups;
  IAuthenticate authentication;
  IManageUsers users;
}

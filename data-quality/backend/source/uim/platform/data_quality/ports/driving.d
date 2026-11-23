/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The complete set of driving ports — what every adapter (REST, OData,
/// CLI, GUI, workers) may call.
module uim.platform.data_quality.ports.driving;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

struct DqPorts {
  IManageDatasets datasets;
  IManageRecords records;
  IManageValidationRules validationRules;
  IManageCleansingRules cleansingRules;
  IValidateData validation;
  IProfileData profiling;
  IDetectDuplicates duplicates;
  IScorecards scorecards;
  IManageCleansingJobs cleansingJobs;
  ICleanseAddresses addresses;
  IDqStatisticsService statistics;
  IAuthenticate authentication;
  IManageUsers users;
}

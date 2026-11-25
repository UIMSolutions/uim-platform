/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The complete set of driving ports — what every adapter (REST, OData,
/// CLI, GUI, workers) may call.
module uim.platform.job_scheduling.ports.driving;

import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:

struct JsPorts {
  IManageJobs jobs;
  IManageSchedules schedules;
  IManageRunLogs runLogs;
  IRunScheduler scheduler;
  IManageConfiguration configuration;
  IJsStatisticsService statistics;
  IJsLookups lookups;
  IAuthenticate authentication;
  IManageUsers users;
}

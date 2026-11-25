/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driven ports of the aggregates.
module uim.platform.job_scheduling.ports.repositories.repositories;

import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:

interface IJobRepository : IJsRepository!(Job, JobId) {
}

interface IScheduleRepository : IJsRepository!(Schedule, ScheduleId) {
}

interface IRunLogRepository : IJsRepository!(RunLog, RunLogId) {
}

interface IConfigurationRepository : IJsRepository!(SchedulerConfiguration, ConfigurationId) {
}

interface IUserAccountRepository : IJsRepository!(UserAccount, UserAccountId) {
}

/// All repositories (passed to the interactors as one bundle).
struct JsRepositories {
  IJobRepository jobs;
  IScheduleRepository schedules;
  IRunLogRepository runLogs;
  IConfigurationRepository configurations;
  IUserAccountRepository users;
}

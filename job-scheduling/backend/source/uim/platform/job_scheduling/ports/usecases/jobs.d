/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving port of the jobs.
module uim.platform.job_scheduling.ports.usecases.jobs;

import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:

interface IManageJobs : IManageResource!(Job, JobId, JobInput) {
  Job activate(TenantId t, JobId id, UserId actor);
  Job deactivate(TenantId t, JobId id, UserId actor);
  /// Start a run now, independent of the schedules (also for inactive jobs).
  RunLog runNow(RunJobRequest r);
}

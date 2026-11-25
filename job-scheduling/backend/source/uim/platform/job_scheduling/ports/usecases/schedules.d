/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving port of the schedules.
module uim.platform.job_scheduling.ports.usecases.schedules;

import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:

interface IManageSchedules : IManageResource!(Schedule, ScheduleId, ScheduleInput) {
  Schedule activate(TenantId t, ScheduleId id, UserId actor);
  Schedule deactivate(TenantId t, ScheduleId id, UserId actor);
  /// Activate or deactivate every schedule of a job; returns the number changed.
  long activateAll(TenantId t, JobId job, bool active, UserId actor);
  Schedule[] listByJob(TenantId t, JobId job);
  /// Normalize an expression and compute its next runs (nothing is stored).
  SchedulePreview preview(PreviewRequest r);
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.enumerations.jobs;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// Recurrence of an application job.
enum JobFrequency {
  once,
  hourly,
  daily,
  weekly,
  monthly,
}

/// Status of an application job (and of a single run).
///
///   scheduled → running → completed | failed     (recurring jobs return to scheduled)
///   scheduled | running → canceled
enum JobStatus {
  scheduled,
  running,
  completed,
  failed,
  canceled,
}

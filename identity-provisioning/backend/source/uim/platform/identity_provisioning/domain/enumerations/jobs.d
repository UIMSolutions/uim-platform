/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_provisioning.domain.enumerations.jobs;

import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:

/// Kind of provisioning run.
enum JobType {
  full, /// rewrite every entity, delete entities that vanished from the source
  delta, /// write only new and changed entities, delete vanished ones
  simulate, /// plan and log the operations, change nothing
}

/// Lifecycle of a provisioning job.
enum JobStatus {
  scheduled, /// ready (runs on demand or every intervalMinutes)
  running,
  completed, /// last run finished without failed entities
  failed, /// last run had failed entities or the connector failed
  cancelled, /// switched off; resume to schedule again
}

/// Operation on one entity in the target system.
enum OperationType {
  create,
  update,
  delete_,
  skip,
}

/// Outcome of one logged operation.
enum LogStatus {
  success,
  failed,
  skipped,
  simulated,
}

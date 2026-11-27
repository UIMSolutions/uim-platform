/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The log entry of one run (data integration monitor): a replication, a
/// data flow run, a view persistence or a task chain run with its steps.
module uim.platform.datasphere.domain.entities.task_run;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

struct TaskRun {
  mixin TenantEntity!TaskRunId;

  SpaceId spaceId;
  RunObjectType objectType = RunObjectType.replication;
  string objectId; /// remote table, data flow, view or task chain id
  string objectName;
  string taskId; /// the task that ran ("" for direct runs)
  string chainRunId; /// the task chain run of a step ("" otherwise)
  RunTrigger trigger = RunTrigger.manual;
  RunStatus status = RunStatus.running;
  int attempts = 1;
  long startedAt;
  long finishedAt;
  long durationMs;
  long rowsProcessed;
  long sizeBytes;
  string message;

  bool isFinished() const {
    return status != RunStatus.running && status != RunStatus.notRun;
  }

  bool succeeded() const {
    return status == RunStatus.completed;
  }

  void finish(RunStatus result, long at, string text) {
    status = result;
    finishedAt = at;
    durationMs = startedAt > 0 ? millisBetween(startedAt, at) : 0;
    message = text;
  }

  void validate() const {
    requireId(id.value, "Run ID");
    if (spaceId.isNull)
      throw DspException.invalid("The space of the run is required");
    requireText(objectId, "Object");
    requireRange(attempts, 1, maxTaskRetries + 1, "Attempts");
  }
}

///
unittest {
  TaskRun r;
  r.id = TaskRunId("r");
  r.spaceId = SpaceId("SALES");
  r.objectId = "orders";
  r.startedAt = parseIsoTime("2026-02-01T10:00:00Z");
  r.validate();
  assert(!r.isFinished);
  r.finish(RunStatus.completed, plusSeconds(r.startedAt, 3), "ok");
  assert(r.isFinished && r.succeeded && r.durationMs == 3000);
}

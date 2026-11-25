/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// One run of a job (from a schedule or started manually) with its
/// attempts. The action URL and method are copied at creation, so the log
/// shows what was actually called even if the job changes later.
module uim.platform.job_scheduling.domain.entities.run_log;

import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:

enum size_t maxRunMessageLength = 2000;

struct RunLog {
  mixin TenantEntity!RunLogId;

  JobId jobId;
  ScheduleId scheduleId; /// empty for manual runs
  RunTrigger trigger = RunTrigger.schedule;
  RunStatus status = RunStatus.scheduled;
  string actionUrl;
  JobHttpMethod httpMethod = JobHttpMethod.post;
  bool asyncMode;
  string data; /// JSON payload sent with every attempt ("" = none)
  int attempt; /// invocations so far
  int maxAttempts = 1; /// 1 + retries
  int httpStatus; /// of the last invocation (0 = no answer)
  string statusMessage;
  long scheduledAt; /// when the run was due
  long triggeredAt; /// last invocation
  long completedAt; /// end of the last attempt
  long nextAttemptAt; /// retry of a failed run (0 = none)
  long deadlineAt; /// asynchronous runs fail if not reported by then
  long durationMs; /// of the last attempt

  /// Start an attempt (first call or retry).
  void start(long now) {
    RunTracker.require(status, RunStatus.triggered, id.value);
    status = RunStatus.triggered;
    attempt++;
    triggeredAt = now;
    completedAt = 0;
    nextAttemptAt = 0;
    deadlineAt = 0;
    httpStatus = 0;
    durationMs = 0;
  }

  /// The endpoint accepted the run (202) and reports the result later.
  void accept(long now, int http, long deadline) {
    RunTracker.require(status, RunStatus.running, id.value);
    status = RunStatus.running;
    httpStatus = http;
    deadlineAt = deadline;
    statusMessage = "Accepted, waiting for the result";
  }

  void complete(long now, int http, string message) {
    RunTracker.require(status, RunStatus.completed, id.value);
    status = RunStatus.completed;
    finish(now, http, message);
  }

  /// A failed attempt: retried at retryAt while attempts are left,
  /// otherwise dead lettered.
  void fail(long now, int http, string message, long retryAt) {
    RunTracker.require(status, RunStatus.failed, id.value);
    status = RunStatus.failed;
    finish(now, http, message);
    if (attempt < maxAttempts)
      nextAttemptAt = retryAt;
    else {
      status = RunStatus.deadLettered;
      statusMessage = clip(format("%s (gave up after %d attempt%s)", message, attempt, attempt == 1 ? "" : "s"));
    }
  }

  bool isRetryDue(long now) const {
    return status == RunStatus.failed && nextAttemptAt > 0 && nextAttemptAt <= now;
  }

  bool isTimedOut(long now) const {
    return status == RunStatus.running && deadlineAt > 0 && deadlineAt <= now;
  }

  bool isFinal() const {
    return RunTracker.isFinal(status);
  }

  protected void finish(long now, int http, string message) {
    completedAt = now;
    httpStatus = http;
    statusMessage = clip(message);
    durationMs = millisBetween(triggeredAt, now);
    deadlineAt = 0;
  }

  void validate() const {
    requireId(id.value, "Run log ID");
    if (jobId.isNull)
      throw JobSchedulingException.invalid("The job of a run log is required");
    requireRange(maxAttempts, 1, maxJobRetries + 1, "Attempts");
  }
}

/// Cut a message to maxRunMessageLength characters.
string clip(string message) {
  return message.length <= maxRunMessageLength ? message : message[0 .. maxRunMessageLength - 1] ~ "…";
}

///
unittest {
  RunLog r;
  r.id = RunLogId("r1");
  r.jobId = JobId("j1");
  r.maxAttempts = 2;
  r.validate();
  r.start(100);
  r.fail(plusSeconds(100, 1), 500, "Internal Server Error", 900);
  assert(r.status == RunStatus.failed && r.nextAttemptAt == 900 && r.durationMs == 1000);
  assert(!r.isRetryDue(899) && r.isRetryDue(900));
  r.start(900);
  assert(r.attempt == 2 && r.nextAttemptAt == 0);
  r.fail(901, 503, "Unavailable", 2000);
  assert(r.status == RunStatus.deadLettered && r.nextAttemptAt == 0 && r.isFinal && r.statusMessage.canFind("2 attempts"));

  RunLog a;
  a.id = RunLogId("r2");
  a.start(10);
  a.accept(11, 202, 50);
  assert(a.status == RunStatus.running && !a.isTimedOut(49) && a.isTimedOut(50));
  a.complete(20, 200, "done");
  assert(a.status == RunStatus.completed && a.deadlineAt == 0);
  assert(failsWith(JsErrorKind.ruleViolation, () { a.complete(30, 200, "again"); }));
  assert(clip("x".replicate(3000)).length < 3000);
}

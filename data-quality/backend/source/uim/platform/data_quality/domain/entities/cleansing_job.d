/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A batch cleansing run over a dataset.
///
///   pending ──start──▶ running ──complete──▶ completed
///      │                  └──────fail──────▶ failed
///      └──cancel──▶ cancelled
///
/// Without ruleIds the job applies every active cleansing rule matching the
/// dataset. A dry run computes the changes without saving them.
module uim.platform.data_quality.domain.entities.cleansing_job;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

enum size_t maxChangeLogEntries = 200;

struct CleansingJob {
  mixin TenantEntity!CleansingJobId;

  DatasetId datasetId;
  CleansingRuleId[] ruleIds;
  bool dryRun;
  bool revalidate = true; /// validate the dataset after a run that changed records
  JobStatus status = JobStatus.pending;

  long totalRecords;
  long processedRecords;
  long changedRecords;
  long changedFields;
  long rulesApplied;
  string errorMessage;
  string[] changeLog; /// "recordId: change" (first maxChangeLogEntries)
  long startedAt;
  long completedAt;

  void start(long now) {
    if (status != JobStatus.pending)
      throw DataQualityException.ruleViolation("Cleansing job '" ~ id.value ~ "' is " ~ cast(string) status ~ ", not pending");
    status = JobStatus.running;
    startedAt = now;
    errorMessage = "";
  }

  void complete(long now) {
    if (status != JobStatus.running)
      throw DataQualityException.ruleViolation("Cleansing job '" ~ id.value ~ "' is not running");
    status = JobStatus.completed;
    completedAt = now;
  }

  void fail(string message, long now) {
    status = JobStatus.failed;
    errorMessage = message;
    completedAt = now;
  }

  void cancel(long now) {
    if (status != JobStatus.pending)
      throw DataQualityException.ruleViolation("Only pending cleansing jobs can be cancelled ('" ~ id.value ~ "' is "
          ~ cast(string) status ~ ")");
    status = JobStatus.cancelled;
    completedAt = now;
  }

  void log(string entry) {
    if (changeLog.length < maxChangeLogEntries)
      changeLog ~= entry;
  }

  long durationMillis() const {
    return startedAt > 0 && completedAt >= startedAt ? millisBetween(startedAt, completedAt) : 0;
  }
}

///
unittest {
  CleansingJob j;
  j.id = CleansingJobId("j1");
  j.start(10);
  assert(j.status == JobStatus.running);
  assert(failsWith(DqErrorKind.ruleViolation, () { j.cancel(11); }));
  j.complete(10 + 3 * hnsecsPerMilliL);
  assert(j.status == JobStatus.completed && j.durationMillis == 3);
  assert(failsWith(DqErrorKind.ruleViolation, () { j.start(12); }));
}

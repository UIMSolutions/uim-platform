/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// An archiving and/or destruction run over the data subjects of an
/// application group. Scheduled jobs are run by the background worker when
/// they are due, or explicitly ("run now"). A dry run only counts.
module uim.platform.data_retention.domain.entities.archiving_job;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

enum size_t maxJobLogLines = 200;

struct ArchivingJob {
  mixin TenantEntity!ArchivingJobId;

  ApplicationGroupId applicationGroupId;
  ArchivingOperation operation = ArchivingOperation.archive;
  JobStatus status = JobStatus.scheduled;
  bool dryRun;
  long referenceBefore; /// only data subjects whose reference date is before; 0 = all
  long scheduledAt;
  long startedAt;
  long completedAt;
  long selected; /// data subjects of the group that were looked at
  long archived;
  long destroyed;
  long skipped; /// e.g. legal hold
  long failed;
  string errorMessage;
  string[] log; /// "<subject> archived", … (at most maxJobLogLines)

  bool isDue(long now) const {
    return status == JobStatus.scheduled && scheduledAt <= now;
  }

  bool archives() const {
    return operation != ArchivingOperation.destruct;
  }

  bool destructs() const {
    return operation != ArchivingOperation.archive;
  }

  /// Scheduled or failed jobs can be (re)started.
  void start(long now) {
    if (status != JobStatus.scheduled && status != JobStatus.failed)
      throw DataRetentionException.ruleViolation("Archiving job '" ~ id.value ~ "' is " ~ cast(string) status
          ~ " and cannot be started");
    status = JobStatus.running;
    startedAt = now;
    completedAt = 0;
    selected = archived = destroyed = skipped = failed = 0;
    errorMessage = "";
    log = null;
  }

  void note(string line) {
    if (log.length < maxJobLogLines)
      log ~= line;
    else if (log.length == maxJobLogLines)
      log ~= "…";
  }

  void finish(long now) {
    status = JobStatus.completed;
    completedAt = now;
  }

  void fail(long now, string message) {
    status = JobStatus.failed;
    completedAt = now;
    errorMessage = message;
  }

  void cancel(long now) {
    if (status != JobStatus.scheduled)
      throw DataRetentionException.ruleViolation("Only scheduled archiving jobs can be cancelled ('" ~ id.value ~ "' is "
          ~ cast(string) status ~ ")");
    status = JobStatus.cancelled;
    completedAt = now;
  }

  void validate() const {
    requireId(id.value, "Archiving job ID");
    if (applicationGroupId.isNull)
      throw DataRetentionException.invalid("The application group of an archiving job is required");
  }
}

///
unittest {
  ArchivingJob j;
  j.id = ArchivingJobId("j1");
  j.applicationGroupId = ApplicationGroupId("erp");
  j.scheduledAt = 10;
  j.validate();
  assert(!j.isDue(9) && j.isDue(10) && j.archives && !j.destructs);
  j.start(11);
  assert(failsWith(DrErrorKind.ruleViolation, () { j.cancel(12); }));
  foreach (i; 0 .. maxJobLogLines + 5)
    j.note("x");
  assert(j.log.length == maxJobLogLines + 1);
  j.fail(12, "boom");
  j.start(13); // failed jobs can be retried
  assert(j.status == JobStatus.running && j.log.length == 0);
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Archiving and destruction jobs over the data subjects of an
/// application group.
///
///   archive   data subjects past their end of purpose (active ones are
///             blocked first) → archived
///   destruct  data subjects past their end of retention → destroyed with
///             the action of their retention rule (delete / anonymize);
///             legal holds are skipped
///   archiveAndDestruct  both (destruction first)
///
/// referenceBefore restricts the selection to data subjects whose
/// reference date lies before it. A dry run changes nothing.
module uim.platform.data_retention.application.usecases.archiving_jobs;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class ManageArchivingJobsUseCase : DrInteractor, IManageArchivingJobs {
  this(DrRepositories repos, IClock clock, IDrEventPublisher events, IDrUnitOfWork unitOfWork, DrPolicy policy) {
    super(repos, clock, events, unitOfWork, policy);
  }

  ArchivingJob create(CreateArchivingJobCommand c) {
    auto id = idOrNew(c.id, "Archiving job ID");
    if (repos.archivingJobs.existsById(c.tenantId, ArchivingJobId(id)))
      throw DataRetentionException.conflict("Archiving job '" ~ id ~ "' already exists");
    ArchivingJob j;
    auto at = now;
    stampCreated!(ArchivingJob, ArchivingJobId)(j, c.tenantId, c.actor, id, at);
    j.applicationGroupId = applicationGroupOf(c.tenantId, c.applicationGroupId.value).id;
    j.operation = parseDomainEnumOr!ArchivingOperation(c.operation, ArchivingOperation.archive, "operation");
    j.dryRun = c.dryRun;
    j.referenceBefore = c.referenceBefore;
    j.scheduledAt = c.scheduledAt > 0 ? c.scheduledAt : at;
    j.validate();
    repos.archivingJobs.save(j);
    emit("archivingJob.scheduled", c.tenantId, id, Json(["operation": Json(cast(string) j.operation),
        "dryRun": Json(j.dryRun)]));
    return policy.runJobsImmediately && j.isDue(at) ? run(c.tenantId, j.id, c.actor) : j;
  }

  ArchivingJob run(TenantId t, ArchivingJobId id, UserId actor) {
    auto j = get(t, id);
    auto at = now;
    j.start(at);
    repos.archivingJobs.save(j);
    try {
      auto book = new RuleBook(repos, t);
      batch(() {
        foreach (s; repos.dataSubjects.findByReference(t, "applicationGroupId", j.applicationGroupId.value))
          processSubject(j, s, book, at, actor);
      });
      j.finish(now);
    } catch (Exception e) {
      j.fail(now, e.msg);
    }
    stampUpdated(j, actor, now);
    repos.archivingJobs.save(j);
    emit("archivingJob." ~ cast(string) j.status, t, id.value, Json([
        "selected": Json(j.selected), "archived": Json(j.archived), "destroyed": Json(j.destroyed),
        "skipped": Json(j.skipped), "dryRun": Json(j.dryRun)
      ]));
    return j;
  }

  protected void processSubject(ref ArchivingJob j, DataSubject s, RuleBook book, long at, UserId actor) {
    if (s.isDeleted)
      return;
    if (j.referenceBefore > 0 && (s.referenceDate <= 0 || s.referenceDate >= j.referenceBefore))
      return;
    auto e = book.evaluate(s, at);
    auto pastPurpose = phaseRank(e.phase) >= phaseRank(RetentionPhase.withinRetention);
    if (!pastPurpose)
      return;
    j.selected++;
    auto prefix = j.dryRun ? "would be " : "";
    try {
      if (j.destructs && e.phase == RetentionPhase.endOfRetention) {
        if (s.legalHold) {
          j.skipped++;
          j.note(s.id.value ~ " skipped (legal hold)");
          return;
        }
        if (!j.dryRun) {
          s.destroy(at, e.actionOnExpiry);
          save(s, actor, at);
        }
        j.destroyed++;
        j.note(s.id.value ~ " " ~ prefix ~ (e.actionOnExpiry == DeletionAction.anonymize ? "anonymized" : "deleted"));
        return;
      }
      if (j.archives && s.lifecycleStatus != LifecycleStatus.archived && s.lifecycleStatus != LifecycleStatus.markedForDeletion) {
        if (!j.dryRun) {
          s.archive(at);
          save(s, actor, at);
        }
        j.archived++;
        j.note(s.id.value ~ " " ~ prefix ~ "archived");
        return;
      }
      j.skipped++;
    } catch (DataRetentionException ex) {
      j.failed++;
      j.note(s.id.value ~ " failed: " ~ ex.msg);
    }
  }

  protected void save(ref DataSubject s, UserId actor, long at) {
    stampUpdated(s, actor, at);
    repos.dataSubjects.save(s);
  }

  ArchivingJob cancel(TenantId t, ArchivingJobId id, UserId actor) {
    auto j = get(t, id);
    j.cancel(now);
    stampUpdated(j, actor, now);
    repos.archivingJobs.save(j);
    emit("archivingJob.cancelled", t, id.value);
    return j;
  }

  ArchivingJob get(TenantId t, ArchivingJobId id) {
    return required(repos.archivingJobs.findById(t, id), "Archiving job '" ~ id.value ~ "'");
  }

  ArchivingJob[] list(TenantId t) {
    return repos.archivingJobs.findAll(t);
  }

  void remove(TenantId t, ArchivingJobId id, UserId actor) {
    auto j = get(t, id);
    if (j.status == JobStatus.running)
      throw DataRetentionException.ruleViolation("Archiving job '" ~ id.value ~ "' is running");
    repos.archivingJobs.removeById(t, id);
    emit("archivingJob.deleted", t, id.value, Json(["by": Json(actor.value)]));
  }

  RunSummary runDue(TenantId t, UserId actor) {
    RunSummary summary;
    auto at = now;
    foreach (j; repos.archivingJobs.findAll(t)) {
      if (!j.isDue(at))
        continue;
      summary.started++;
      auto done = run(t, j.id, actor);
      if (done.status == JobStatus.completed)
        summary.completed++;
      else
        summary.failed++;
    }
    return summary;
  }
}

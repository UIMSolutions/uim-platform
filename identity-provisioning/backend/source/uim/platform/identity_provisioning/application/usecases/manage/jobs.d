/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_provisioning.application.usecases.manage.jobs;

import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:

/// Interactor: provisioning jobs (configuration, run, schedule, delta reset).
class ManageProvisioningJobsUseCase
  : ResourceUseCase!(ProvisioningJob, ProvisioningJobId, CreateJobRequest, UpdateJobRequest),
  IManageProvisioningJobsUseCase {

  protected ProvisioningRunner runner;

  this(ProvisioningRepositories repos, EventRecorder events, ProvisioningRunner runner) {
    super(repos, repos.jobs, events, "Job", "provisioning.job");
    this.runner = runner;
  }

  override protected ProvisioningJob build(CreateJobRequest r) {
    auto j = ProvisioningJob(r.tenantId);
    assignMatching(j, r.spec);
    check(j);
    j.nextRunAt = nextRunAfter(nowStdTime(), j.intervalMinutes);
    return j;
  }

  override protected void apply(ref ProvisioningJob j, JobSpec spec) {
    ensureIdle(j);
    auto interval = j.intervalMinutes;
    auto pair = [j.sourceSystemId.value, j.targetSystemId.value, enumText(j.jobType)];
    auto oldName = jobName(j.sourceSystemName, j.targetSystemName, j.jobType);
    assignMatching(j, spec);
    // a derived name follows the systems and the type
    if (j.name == oldName && [j.sourceSystemId.value, j.targetSystemId.value, enumText(j.jobType)] != pair)
      j.name = "";
    check(j);
    if (j.intervalMinutes != interval && j.status != JobStatus.cancelled)
      j.nextRunAt = nextRunAfter(nowStdTime(), j.intervalMinutes);
  }

  protected void check(ref ProvisioningJob j) {
    validate(!j.sourceSystemId.isEmpty, "sourceSystemId is required");
    validate(!j.targetSystemId.isEmpty, "targetSystemId is required");
    auto source = repos.sourceSystems.findById(j.tenantId, j.sourceSystemId);
    if (source.isNull)
      throw new ProvisioningNotFoundException("Source system '" ~ j.sourceSystemId.value ~ "' not found");
    auto target = repos.targetSystems.findById(j.tenantId, j.targetSystemId);
    if (target.isNull)
      throw new ProvisioningNotFoundException("Target system '" ~ j.targetSystemId.value ~ "' not found");
    j.sourceSystemName = source.name;
    j.targetSystemName = target.name;
    validate(j.intervalMinutes >= 0 && j.intervalMinutes <= 10_080, "intervalMinutes must be between 0 and 10080 (one week)");
    if (j.name.strip.length == 0)
      j.name = jobName(source.name, target.name, j.jobType);
    validateDisplayName(kindLabel, j.name);
    ensureUnique(repos.jobs.findByName(j.tenantId, j.name), j, "this tenant");
  }

  override protected void beforeRemove(ProvisioningJob j) {
    ensureIdle(j);
  }

  // ── actions ────────────────────────────────────────────────────────────

  UsecaseResult run(TenantId tenantId, ProvisioningJobId id, UserId actor) {
    return guarded(() {
      auto job = require(tenantId, id);
      ensureRunnable(job);
      job = runner.execute(job, actor);
      return succeeded(job.id.value, "Job '" ~ job.name ~ "' " ~ enumText(job.status) ~ ": " ~ job.statusMessage);
    });
  }

  UsecaseResult cancel(TenantId tenantId, ProvisioningJobId id, UserId actor) {
    return transition(tenantId, id, actor, "cancelled", (ref j) {
      ensureCancellable(j);
      ensureIdle(j);
      j.status = JobStatus.cancelled;
      j.nextRunAt = 0;
    });
  }

  UsecaseResult resume(TenantId tenantId, ProvisioningJobId id, UserId actor) {
    return transition(tenantId, id, actor, "resumed", (ref j) {
      ensureResumable(j);
      j.status = JobStatus.scheduled;
      j.nextRunAt = nextRunAfter(nowStdTime(), j.intervalMinutes);
    });
  }

  UsecaseResult reset(TenantId tenantId, ProvisioningJobId id, UserId actor) {
    return guarded(() {
      auto job = require(tenantId, id);
      ensureIdle(job);
      auto state = repos.entities.findByPair(tenantId, job.sourceSystemId, job.targetSystemId);
      if (state.length)
        repos.entities.remove(state);
      job.statusMessage = "Delta state reset (" ~ state.length.to!string ~ " entities forgotten)";
      job.update(actor);
      repo.update(job);
      publish(job, "reset");
      return succeeded(job.id.value, "Job '" ~ job.name ~ "': " ~ job.statusMessage);
    });
  }

  JobRunReport runDue(TenantId tenantId, long now = 0, int limit = 0) {
    JobRunReport report;
    report.tenantId = tenantId;
    report.ranAt = now > 0 ? now : nowStdTime();
    foreach (job; repos.jobs.findByTenant(tenantId)) {
      if (limit > 0 && report.processed >= limit)
        break;
      if (!isDue(job, report.ranAt))
        continue;
      report.processed++;
      try {
        auto done = runner.execute(job, UserId("scheduler"));
        if (done.status == JobStatus.completed)
          report.completed++;
        else
          report.failed++;
        report.messages ~= done.name ~ ": " ~ enumText(done.status) ~ " — " ~ done.statusMessage;
      } catch (ProvisioningException e) {
        // e.g. an inactive system: postpone to the next interval
        job.statusMessage = e.msg;
        job.nextRunAt = nextRunAfter(report.ranAt, job.intervalMinutes);
        repo.update(job);
        report.failed++;
        report.messages ~= job.name ~ ": skipped — " ~ e.msg;
      }
    }
    return report;
  }

  ProvisioningJob findByName(TenantId tenantId, string name) {
    return repos.jobs.findByName(tenantId, name);
  }
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.application.usecases.manage.application_jobs;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// Interactor: application jobs. The reconciler starts due jobs and finishes
/// running ones; recurring jobs are rescheduled by their frequency.
class ManageApplicationJobsUseCase
  : ResourceUseCase!(ApplicationJob, ApplicationJobId, CreateApplicationJobRequest, UpdateApplicationJobRequest),
  IManageApplicationJobsUseCase {

  this(AbapRepositories repos, IAbapEventPublisher publisher) {
    super(repos, repos.applicationJobs, publisher, "Application job", "abap.application-job");
  }

  override protected ApplicationJob build(CreateApplicationJobRequest r) {
    auto system = requireActiveSystem(r.tenantId, r.parentId, "schedule jobs");
    auto job = ApplicationJob(r.tenantId);
    job.systemInstanceId = system.id;
    job.systemName = system.name;
    assignMatching(job, r.spec);
    check(job);
    ensureUnique(repos.applicationJobs.findByName(r.tenantId, system.id, job.name), job, "system '" ~ system.name ~ "'");
    job.status = job.active ? JobStatus.scheduled : JobStatus.canceled;
    if (job.scheduledAt == 0)
      job.scheduledAt = nowStdTime();
    return job;
  }

  override protected void apply(ref ApplicationJob job, ApplicationJobSpec spec) {
    ensureState(job.status != JobStatus.running, "Application job '" ~ job.name ~ "' is running");
    assignMatching(job, spec, ["name", "active"]);
    check(job);
  }

  protected static void check(ref ApplicationJob job) {
    validateDisplayName("Application job", job.name);
    job.jobTemplateName = job.jobTemplateName.strip.toUpper;
    validateAbapName("Job template", job.jobTemplateName, 40);
    validateCron(job.cronExpression);
    string[] keys;
    foreach (p; job.parameters) {
      validate(p.key.length > 0, "Job parameters need a name");
      validate(!keys.canFind(p.key), "Duplicate job parameter '" ~ p.key ~ "'");
      keys ~= p.key;
    }
  }

  override protected void beforeRemove(ApplicationJob job) {
    ensureState(job.status != JobStatus.running, "Application job '" ~ job.name ~ "' is running — cancel it first");
  }

  UsecaseResult run(TenantId tenantId, ApplicationJobId id, UserId actor) {
    return transition(tenantId, id, actor, "started", (ref ApplicationJob job) {
      requireActive(requireSystem(tenantId, job.systemInstanceId), "run jobs");
      ensureState(job.status != JobStatus.running, "Application job '" ~ job.name ~ "' is already running");
      startRun(job, nowStdTime());
    });
  }

  UsecaseResult cancel(TenantId tenantId, ApplicationJobId id, UserId actor) {
    return transition(tenantId, id, actor, "canceled", (ref ApplicationJob job) {
      ensureState(job.status == JobStatus.scheduled || job.status == JobStatus.running,
        "Application job '" ~ job.name ~ "' can only be canceled when scheduled or running");
      if (job.status == JobStatus.running && job.executionHistory.length > 0) {
        job.executionHistory[$ - 1].status = JobStatus.canceled;
        job.executionHistory[$ - 1].finishedAt = nowStdTime();
        job.executionHistory[$ - 1].message = "Canceled";
      }
      job.status = JobStatus.canceled;
      job.active = false;
    });
  }

  UsecaseResult reactivate(TenantId tenantId, ApplicationJobId id, UserId actor) {
    return transition(tenantId, id, actor, "rescheduled", (ref ApplicationJob job) {
      ensureState(job.status == JobStatus.canceled || job.status == JobStatus.completed || job.status == JobStatus.failed,
        "Application job '" ~ job.name ~ "' is already scheduled or running");
      job.active = true;
      job.status = JobStatus.scheduled;
      auto now = nowStdTime();
      if (job.scheduledAt < now)
        job.scheduledAt = now;
    });
  }
}

/// Begin a run: running status plus an open execution log entry.
void startRun(ref ApplicationJob job, long now) {
  job.status = JobStatus.running;
  JobExecutionLog log;
  log.runId = format("%s-%04d", job.id.value.length >= 8 ? job.id.value[0 .. 8] : job.id.value, job.runCount + 1);
  log.status = JobStatus.running;
  log.startedAt = now;
  recordRun(job, log);
}

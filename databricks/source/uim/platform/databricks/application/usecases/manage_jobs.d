module uim.platform.databricks.application.usecases.manage_jobs;
import uim.platform.databricks;

// mixin(ShowModule!());

@safe:

class ManageJobsUseCase {
private:
  JobRepository _repo;

public:
  this(JobRepository repo) { _repo = repo; }

  UseCaseResult!Job create(CreateJobRequest r) {
    auto j = Job();
    j.id                 = r.id;
    j.tenantId           = r.tenantId;
    j.workspaceId        = r.workspaceId;
    j.name               = r.name;
    j.description        = r.description;
    j.status             = JobStatus.active;
    j.creatorId          = r.creatorId;
    j.schedule           = r.schedule;
    j.taskType           = r.taskType;
    j.taskSettings       = r.taskSettings;
    j.maxRetries         = r.maxRetries;
    j.minRetryIntervalMs = r.minRetryIntervalMs;
    j.maxConcurrentRuns  = r.maxConcurrentRuns > 0 ? r.maxConcurrentRuns : 1;
    j.clusterId          = r.clusterId;
    import std.datetime : Clock;
    j.createdTime = Clock.currTime().toUnixTime() * 1000;
    _repo.save(j);
    return UseCaseResult!Job(true, "Job created", j);
  }

  UseCaseResult!(Job[]) list(TenantId tenantId) {
    return UseCaseResult!(Job[])(true, "", _repo.findByTenant(tenantId));
  }

  UseCaseResult!Job get(TenantId tenantId, JobId id) {
    auto j = _repo.find(tenantId, id);
    if (j.isNull)
      return UseCaseResult!Job(false, "Job not found", Job.init);
    return UseCaseResult!Job(true, "", j);
  }

  UseCaseResult!Job update(UpdateJobRequest r) {
    auto j = _repo.find(r.tenantId, r.id);
    if (j == Job.init)
      return UseCaseResult!Job(false, "Job not found", Job.init);
    if (r.name.length         > 0) j.name         = r.name;
    if (r.description.length  > 0) j.description  = r.description;
    if (r.schedule.length     > 0) j.schedule      = r.schedule;
    if (r.taskSettings.length > 0) j.taskSettings  = r.taskSettings;
    j.maxRetries        = r.maxRetries;
    j.maxConcurrentRuns = r.maxConcurrentRuns;
    _repo.save(j);
    return UseCaseResult!Job(true, "Job updated", j);
  }

  UseCaseResult!bool remove(TenantId tenantId, JobId id) {
    auto j = _repo.find(tenantId, id);
    if (j == Job.init)
      return UseCaseResult!bool(false, "Job not found", false);
    j.status = JobStatus.deleted;
    _repo.save(j);
    return UseCaseResult!bool(true, "Job deleted", true);
  }
}

module uim.platform.databricks.application.usecases.manage_job_runs;
import uim.platform.databricks;

// mixin(ShowModule!());

@safe:

class ManageJobRunsUseCase {
private:
  JobRunRepository _repo;

public:
  this(JobRunRepository repo) { _repo = repo; }

  UseCaseResult!JobRun create(CreateJobRunRequest r) {
    auto run = JobRun();
    run.id          = r.id;
    run.tenantId    = r.tenantId;
    run.jobId       = r.jobId;
    run.workspaceId = r.workspaceId;
    run.state       = RunState.running;
    run.triggerType = r.triggerType;
    run.runType     = r.runType;
    run.clusterId   = r.clusterId;
    import std.datetime : Clock;
    run.startTime = Clock.currTime().toUnixTime() * 1000;
    _repo.save(run);
    return UseCaseResult!JobRun(true, "Job run started", run);
  }

  UseCaseResult!(JobRun[]) list(TenantId tenantId) {
    return UseCaseResult!(JobRun[])(true, "", _repo.findByTenant(tenantId));
  }

  UseCaseResult!JobRun get(TenantId tenantId, JobRunId id) {
    auto run = _repo.find(tenantId, id);
    if (run.isNull)
      return UseCaseResult!JobRun(false, "Job run not found", JobRun.init);
    return UseCaseResult!JobRun(true, "", run);
  }

  UseCaseResult!JobRun update(UpdateJobRunRequest r) {
    auto run = _repo.find(r.tenantId, r.id);
    if (run.isNull)
      return UseCaseResult!JobRun(false, "Job run not found", JobRun.init);
    run.state        = r.state;
    run.stateMessage = r.stateMessage;
    run.resultState  = r.resultState;
    run.endTime      = r.endTime;
    _repo.save(run);
    return UseCaseResult!JobRun(true, "Job run updated", run);
  }

  UseCaseResult!bool remove(TenantId tenantId, JobRunId id) {
    auto run = _repo.find(tenantId, id);
    if (run.isNull)
      return UseCaseResult!bool(false, "Job run not found", false);
    _repo.remove(run);
    return UseCaseResult!bool(true, "Job run deleted", true);
  }
}

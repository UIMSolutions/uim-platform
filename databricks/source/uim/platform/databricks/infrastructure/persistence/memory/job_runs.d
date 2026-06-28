module uim.platform.databricks.infrastructure.persistence.memory.job_runs;
import uim.platform.databricks;

// mixin(ShowModule!());

@safe:

class MemoryJobRunRepository : TenantRepository!(JobRun, JobRunId), JobRunRepository {
  JobRun[] findByJob(TenantId tenantId, JobId jobId) {
    import std.algorithm : filter;
    import std.array : array;
    return find(tenantId).filter!(r => r.jobId == jobId).array;
  }

  JobRun[] findByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    import std.algorithm : filter;
    import std.array : array;
    return find(tenantId).filter!(r => r.workspaceId == workspaceId).array;
  }

  JobRun[] findByState(TenantId tenantId, RunState state) {
    import std.algorithm : filter;
    import std.array : array;
    return find(tenantId).filter!(r => r.state == state).array;
  }

  JobRun[] findActiveRuns(TenantId tenantId) {
    return findByState(tenantId, RunState.running);
  }
}

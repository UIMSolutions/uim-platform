module uim.platform.databricks.domain.ports.repositories.job_runs;
import uim.platform.databricks;

// mixin(ShowModule!());

@safe:

interface JobRunRepository : TentRepository!(JobRun, JobRunId) {
  JobRun[] findByJob(TenantId tenantId, JobId jobId);
  JobRun[] findByWorkspace(TenantId tenantId, WorkspaceId workspaceId);
  JobRun[] findByState(TenantId tenantId, RunState state);
  JobRun[] findActiveRuns(TenantId tenantId);
}

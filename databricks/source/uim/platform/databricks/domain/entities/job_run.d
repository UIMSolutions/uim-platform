module uim.platform.databricks.domain.entities.job_run;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

/// A single execution of a Databricks job.
struct JobRun {
  mixin TenantEntity!(JobRunId);

  JobId       jobId;
  WorkspaceId workspaceId;
  RunState    state;
  RunTrigger  triggerType;
  string      runType;       // JOB_RUN, WORKFLOW_RUN, SUBMIT_RUN
  string      taskKey;
  string      clusterId;
  long        startTime;     // Unix epoch ms
  long        endTime;       // Unix epoch ms, 0 if still running
  string      stateMessage;
  string      resultState;   // SUCCESS, FAILED, TIMEDOUT, CANCELLED
  int         runPageUrl;    // relative page URL index
}

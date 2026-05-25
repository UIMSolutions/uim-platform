module uim.platform.databricks.domain.entities.job;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

/// A Databricks job — a configurable scheduled or triggered workflow.
struct Job {
  mixin TenantEntity!(JobId);

  WorkspaceId workspaceId;
  string      name;
  string      description;
  JobStatus   status;
  string      creatorId;
  long        createdTime;   // Unix epoch ms
  string      schedule;      // Cron expression or empty
  string      taskType;      // notebook, spark_jar, spark_python, pipeline, sql
  string      taskSettings;  // JSON blob of task-specific settings
  int         maxRetries;
  int         minRetryIntervalMs;
  int         maxConcurrentRuns;
  string      clusterId;     // existing cluster or "" for new job cluster
}

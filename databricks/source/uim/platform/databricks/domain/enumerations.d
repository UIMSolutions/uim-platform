module uim.platform.databricks.domain.enumerations;
import uim.platform.databricks;

// mixin(ShowModule!());

@safe:

/// Lifecycle state of a Databricks workspace.
enum WorkspaceStatus : string {
  provisioning = "provisioning",
  running      = "running",
  stopped      = "stopped",
  failed       = "failed",
  deleted      = "deleted"
}

/// Workspace service tier.
enum WorkspaceTier : string {
  standard   = "standard",
  premium    = "premium",
  enterprise = "enterprise"
}

/// Compute cluster runtime state.
enum ClusterState : string {
  pending     = "pending",
  running     = "running",
  restarting  = "restarting",
  resizing    = "resizing",
  terminating = "terminating",
  terminated  = "terminated",
  error_      = "error",
  unknown     = "unknown"
}

/// Cluster usage type.
enum ClusterType : string {
  interactive = "interactive",
  job         = "job",
  pipeline    = "pipeline"
}

/// Notebook programming language.
enum NotebookLanguage : string {
  python = "python",
  scala  = "scala",
  r      = "r",
  sql    = "sql"
}

/// Notebook lifecycle state.
enum NotebookStatus : string {
  active  = "active",
  deleted = "deleted"
}

/// Job configuration state.
enum JobStatus : string {
  active  = "active",
  deleted = "deleted"
}

/// State of a job run execution.
enum RunState : string {
  running          = "running",
  succeeded        = "succeeded",
  failed           = "failed",
  timedOut         = "timedOut",
  cancelled        = "cancelled",
  waitingForRetry  = "waitingForRetry",
  blocked          = "blocked",
  skipped          = "skipped"
}

/// What triggered a job run.
enum RunTrigger : string {
  periodic   = "periodic",
  oneTime    = "oneTime",
  retry      = "retry",
  runJobTask = "runJobTask"
}

/// Delta table storage type.
enum TableType : string {
  managed  = "managed",
  external = "external",
  view     = "view"
}

/// Delta table lifecycle status.
enum TableStatus : string {
  active  = "active",
  deleted = "deleted"
}

/// Data product availability.
enum DataProductStatus : string {
  available   = "available",
  unavailable = "unavailable",
  pending     = "pending"
}

/// Bidirectional sharing mode for data products.
enum ShareMode : string {
  readOnly  = "readOnly",
  readWrite = "readWrite"
}

/// ML model registry stage.
enum ModelStage : string {
  staging    = "staging",
  production = "production",
  archived   = "archived",
  none_      = "none"
}

/// SQL warehouse type (Photon-optimized or classic).
enum WarehouseType : string {
  classic    = "classic",
  pro        = "pro",
  serverless = "serverless"
}

/// SQL warehouse cluster size.
enum WarehouseSize : string {
  xxSmall   = "2X-Small",
  xSmall    = "X-Small",
  small     = "Small",
  medium    = "Medium",
  large     = "Large",
  xLarge    = "X-Large",
  xxLarge   = "2X-Large",
  xxxLarge  = "3X-Large"
}

/// SQL warehouse runtime state.
enum WarehouseState : string {
  starting  = "starting",
  running   = "running",
  stopping  = "stopping",
  stopped   = "stopped",
  deleting  = "deleting",
  deleted   = "deleted"
}

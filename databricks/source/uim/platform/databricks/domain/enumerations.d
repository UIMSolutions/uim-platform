module uim.platform.databricks.domain.enumerations;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

/// Lifecycle state of a Databricks workspace.
enum WorkspaceStatus : string {
  provisioning = "provisioning",
  running      = "running",
  stopped      = "stopped",
  failed       = "failed",
  deleted      = "deleted"
}
WorkspaceStatus toWorkspaceStatus(string value) {
  mixin(EnumSwitch("WorkspaceStatus", "provisioning"));
}
WorkspaceStatus[] toWorkspaceStatuses(string[] values) {
  return values.map!(toWorkspaceStatus).array;
}
string toString(WorkspaceStatus status) {
  return status.to!string;
}
string[] toStrings(WorkspaceStatus[] statuses) {
  return statuses.map!(toString).array;
}
/// 
unittest {
  mixin(ShowTest!("WorkspaceStatus"));

  assert(WorkspaceStatus.provisioning.to!string == "provisioning");
  assert(WorkspaceStatus.running.to!string == "running");
  assert(WorkspaceStatus.stopped.to!string == "stopped");
  assert(WorkspaceStatus.failed.to!string == "failed");
  assert(WorkspaceStatus.deleted.to!string == "deleted");

  assert("provisioning".to!WorkspaceStatus == WorkspaceStatus.provisioning);
  assert("running".to!WorkspaceStatus == WorkspaceStatus.running);
  assert("stopped".to!WorkspaceStatus == WorkspaceStatus.stopped);
  assert("failed".to!WorkspaceStatus == WorkspaceStatus.failed);
  assert("deleted".to!WorkspaceStatus == WorkspaceStatus.deleted);

  assert("provisioning".toWorkspaceStatus == WorkspaceStatus.provisioning);
  assert("running".toWorkspaceStatus == WorkspaceStatus.running);
  assert("stopped".toWorkspaceStatus == WorkspaceStatus.stopped);
  assert("failed".toWorkspaceStatus == WorkspaceStatus.failed);
  assert("deleted".toWorkspaceStatus == WorkspaceStatus.deleted);
  
  assert("noexists".toWorkspaceStatus == WorkspaceStatus.provisioning); // Default case
  assert("".toWorkspaceStatus == WorkspaceStatus.provisioning); // Default case

  assert(WorkspaceStatus.provisioning.toString == "provisioning");
  assert(WorkspaceStatus.running.toString == "running");
  assert(WorkspaceStatus.stopped.toString == "stopped");
  assert(WorkspaceStatus.failed.toString == "failed");
  assert(WorkspaceStatus.deleted.toString == "deleted");

  assert(["provisioning", "running", "stopped", "failed", "deleted"].toWorkspaceStatuses ==
         [WorkspaceStatus.provisioning, WorkspaceStatus.running, WorkspaceStatus.stopped, WorkspaceStatus.failed, WorkspaceStatus.deleted]);
  assert(toString([WorkspaceStatus.provisioning, WorkspaceStatus.running, WorkspaceStatus.stopped, WorkspaceStatus.failed, WorkspaceStatus.deleted]) ==
         ["provisioning", "running", "stopped", "failed", "deleted"]);
}

/// Workspace service tier.
enum WorkspaceTier : string {
  standard   = "standard",
  premium    = "premium",
  enterprise = "enterprise"
}
WorkspaceTier toWorkspaceTier(string value) {
  mixin(EnumSwitch("WorkspaceTier", "standard"));
}
WorkspaceTier[] toWorkspaceTiers(string[] values) {
  return values.map!(toWorkspaceTier).array;
}
string toString(WorkspaceTier tier) {
  return tier.to!string;
}
string[] toStrings(WorkspaceTier[] tiers) {
  return tiers.map!(toString).array;
}
/// 
unittest {
  mixin(ShowTest!("WorkspaceTier"));

  assert(WorkspaceTier.standard.to!string == "standard");
  assert(WorkspaceTier.premium.to!string == "premium");
  assert(WorkspaceTier.enterprise.to!string == "enterprise");

  assert("standard".to!WorkspaceTier == WorkspaceTier.standard);
  assert("premium".to!WorkspaceTier == WorkspaceTier.premium);
  assert("enterprise".to!WorkspaceTier == WorkspaceTier.enterprise);

  assert("standard".toWorkspaceTier == WorkspaceTier.standard);
  assert("premium".toWorkspaceTier == WorkspaceTier.premium);
  assert("enterprise".toWorkspaceTier == WorkspaceTier.enterprise);
  
  assert("noexists".toWorkspaceTier == WorkspaceTier.standard); // Default case
  assert("".toWorkspaceTier == WorkspaceTier.standard); // Default case

  assert(WorkspaceTier.standard.toString == "standard");
  assert(WorkspaceTier.premium.toString == "premium");
  assert(WorkspaceTier.enterprise.toString == "enterprise");

  assert(["standard", "premium", "enterprise"].toWorkspaceTiers ==
         [WorkspaceTier.standard, WorkspaceTier.premium, WorkspaceTier.enterprise]);
  assert(toString([WorkspaceTier.standard, WorkspaceTier.premium, WorkspaceTier.enterprise]) ==
         ["standard", "premium", "enterprise"]);
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

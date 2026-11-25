/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Business enumerations and status values. All enumerations are string
/// valued: the value is what the APIs accept and return.
module uim.platform.integration_automation.domain.enumerations.automation;

import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

/// Lifecycle of an integration scenario (the template of workflows).
enum ScenarioStatus : string {
  draft = "draft", /// being defined; task templates can change
  active = "active", /// workflows can be created; templates are frozen
  deprecated_ = "deprecated", /// no new workflows; running ones continue
  archived = "archived" /// kept for reference only
}

/// Business process area of a scenario.
enum ScenarioCategory : string {
  leadToCash = "leadToCash",
  sourceToPay = "sourceToPay",
  recruitToRetire = "recruitToRetire",
  designToOperate = "designToOperate",
  btpServices = "btpServices",
  s4HanaIntegration = "s4HanaIntegration",
  communicationManagement = "communicationManagement",
  custom = "custom"
}

/// Kind of system in the landscape ("any" on scenarios: no restriction).
enum SystemType : string {
  any_ = "any",
  s4Hana = "sapS4Hana",
  s4HanaCloud = "sapS4HanaCloud",
  btp = "sapBtp",
  successFactors = "sapSuccessFactors",
  ariba = "sapAriba",
  concur = "sapConcur",
  fieldglass = "sapFieldglass",
  integratedBusinessPlanning = "sapIntegratedBusinessPlanning",
  buildWorkZone = "sapBuildWorkZone",
  onPremise = "onPremise",
  thirdParty = "thirdParty"
}

/// Tier of a system in the landscape.
enum SystemEnvironment : string {
  development = "development",
  test = "test",
  quality = "quality",
  production = "production"
}

/// Result of the last connection test of a system.
enum ConnectionStatus : string {
  inactive = "inactive", /// not tested yet
  active = "active", /// reachable at the last test
  error = "error" /// unreachable at the last test
}

/// Protocol of a destination.
enum DestinationType : string {
  http = "http",
  odata = "odata",
  soap = "soap",
  restApi = "restApi",
  rfc = "rfc"
}

/// Authentication of a destination (credentials are kept in a credential
/// store, never in this service).
enum AuthenticationType : string {
  noAuthentication = "noAuthentication",
  basic = "basic",
  oauth2ClientCredentials = "oauth2ClientCredentials",
  oauth2Saml = "oauth2SamlBearerAssertion",
  certificate = "clientCertificate",
  principalPropagation = "principalPropagation"
}

/// Network route of a destination.
enum ProxyType : string {
  internet = "internet",
  onPremise = "onPremise", /// through the Cloud Connector (location id)
  privateLink = "privateLink"
}

/// Kind of task.
enum TaskType : string {
  manual = "manual", /// a person follows the instructions and confirms
  approval = "approval", /// a person approves (complete) or rejects (fail); cannot be skipped
  automated = "automated", /// executed by the automation gateway (destination + endpoint)
  notification = "notification" /// informs the assigned role; completes automatically
}

enum TaskPriority : string {
  low = "low",
  medium = "medium",
  high = "high",
  critical = "critical"
}

/// Status of a task of a workflow. Whether a pending task can start
/// (all dependencies done) is derived, not stored.
enum TaskStatus : string {
  pending = "pending",
  inProgress = "inProgress",
  completed = "completed",
  skipped = "skipped",
  failed = "failed"
}

/// Status of a workflow (an instance of a scenario).
enum WorkflowStatus : string {
  planned = "planned", /// created, not started
  inProgress = "inProgress",
  suspended = "suspended", /// paused; tasks cannot change
  completed = "completed", /// every task completed or skipped
  failed = "failed", /// a task failed; retry or skip it to continue
  terminated = "terminated" /// stopped for good
}

/// Outcome recorded in an execution log entry.
enum ExecutionOutcome : string {
  info = "info",
  success = "success",
  failure = "failure",
  skipped = "skipped",
  timeout = "timeout"
}

/// True for workflows that count against the active workflow limit.
bool isOpen(WorkflowStatus s) pure {
  return s == WorkflowStatus.planned || s == WorkflowStatus.inProgress || s == WorkflowStatus.suspended
    || s == WorkflowStatus.failed;
}

/// True for completed or skipped tasks (dependencies are satisfied).
bool isDone(TaskStatus s) pure {
  return s == TaskStatus.completed || s == TaskStatus.skipped;
}

/// True for tasks run by the automation gateway instead of a person.
bool isMachineTask(TaskType t) pure {
  return t == TaskType.automated || t == TaskType.notification;
}

///
unittest {
  assert(isOpen(WorkflowStatus.suspended) && !isOpen(WorkflowStatus.completed));
  assert(isDone(TaskStatus.skipped) && !isDone(TaskStatus.failed));
  assert(isMachineTask(TaskType.notification) && !isMachineTask(TaskType.approval));
}

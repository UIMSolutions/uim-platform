/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.domain.enumerations;

import uim.platform.integration.automation;

mixin(ShowModule!());

@safe:


/// Integration scenario lifecycle status.
enum ScenarioStatus {
  draft,
  active,
  deprecated_,
  archived,
}
ScenarioStatus toScenarioStatus(string s) {
  switch (s) {
    case "draft":
      return ScenarioStatus.draft;
    case "active":
      return ScenarioStatus.active;
    case "deprecated":
      return ScenarioStatus.deprecated_;
    case "archived":
      return ScenarioStatus.archived;
    default:
    return ScenarioStatus.draft; // default to draft if unknown
  }
}
ScenarioStatus[] toScenarioStatuses(string[] values) {
  return values.map!(v => v.toScenarioStatus).array;
}
string toString(ScenarioStatus value) {
  return value.to!string();
}
string[] toStrings(ScenarioStatus[] values) {
  return values.map!(v => v.toString).array;
}
///
unittest {
  mixin(ShowTest!("ScenarioStatus"));

  assert("draft".toScenarioStatus == ScenarioStatus.draft);
  assert("active".toScenarioStatus == ScenarioStatus.active);
  assert("deprecated".toScenarioStatus == ScenarioStatus.deprecated_);
  assert("archived".toScenarioStatus == ScenarioStatus.archived);

  assert(ScenarioStatus.draft.toString == "draft");
  assert(ScenarioStatus.active.toString == "active");
  assert(ScenarioStatus.deprecated_.toString == "deprecated_");
  assert(ScenarioStatus.archived.toString == "archived");

  assert(["draft", "active"].toScenarioStatus == [ScenarioStatus.draft, ScenarioStatus.active]);
  assert([ScenarioStatus.draft, ScenarioStatus.active].toStrings == ["draft", "active"]);
}

/// Workflow instance execution status.
enum WorkflowStatus {
  planned,
  inProgress,
  completed,
  terminated,
  failed,
  suspended,
}
WorkflowStatus toWorkflowStatus(string value) {
  mixin(EnumSwitch("WorkflowStatus", "WorkflowStatus.planned"));
}
WorkflowStatus[] toWorkflowStatuses(string[] values) {
  return values.map!(v => v.toWorkflowStatus).array;
}
string toString(WorkflowStatus value) {
  return value.to!string();
}
string[] toStrings(WorkflowStatus[] values) {
  return values.map!(v => v.toString()).array;
}
///
unittest {
  mixin(ShowTest!("WorkflowStatus"));

  assert("planned".toWorkflowStatus == WorkflowStatus.planned);
  assert("inProgress".toWorkflowStatus == WorkflowStatus.inProgress);
  assert("completed".toWorkflowStatus == WorkflowStatus.completed);
  assert("terminated".toWorkflowStatus == WorkflowStatus.terminated);
  assert("failed".toWorkflowStatus == WorkflowStatus.failed);
  assert("suspended".toWorkflowStatus == WorkflowStatus.suspended);

  assert(WorkflowStatus.planned.toString == "planned");
  assert(WorkflowStatus.inProgress.toString == "inProgress");
  assert(WorkflowStatus.completed.toString == "completed");
  assert(WorkflowStatus.terminated.toString == "terminated");
  assert(WorkflowStatus.failed.toString == "failed");
  assert(WorkflowStatus.suspended.toString == "suspended");

  assert(["planned", "completed"].toWorkflowStatus == [WorkflowStatus.planned, WorkflowStatus.completed]);
  assert([WorkflowStatus.planned, WorkflowStatus.completed].toStrings == ["planned", "completed"]);
}

/// Type of workflow step / task.
enum StepType {
  manual,
  automated,
  approval,
  notification,
}
StepType toStepType(string value) {
  mixin(EnumSwitch("StepType", "StepType.manual"));
}
StepType[] toStepType(string[] values) {
  return values.map!(v => v.toStepType).array;
}
string toString(StepType value) {
  return value.to!string();
}
string[] toStrings(StepType[] values) {
  return values.map!(v => v.toString()).array;
}
///
unittest {
  mixin(ShowTest!("StepType"));

  assert("manual".toStepType == StepType.manual);
  assert("automated".toStepType == StepType.automated);
  assert("approval".toStepType == StepType.approval);
  assert("notification".toStepType == StepType.notification);
  assert("unknown".toStepType == StepType.manual); // default

  assert(StepType.manual.toString == "manual");
  assert(StepType.automated.toString == "automated");
  assert(StepType.approval.toString == "approval");
  assert(StepType.notification.toString == "notification");

  assert(["manual", "approval"].toStepType == [StepType.manual, StepType.approval]);
  assert([StepType.manual, StepType.approval].toStrings == ["manual", "approval"]);
} 

/// Status of an individual workflow step.
enum StepStatus {
  pending,
  inProgress,
  completed,
  skipped,
  failed,
  blocked,
}
StepStatus toStepStatus(string value) {
  mixin(EnumSwitch("StepStatus", "StepStatus.pending"));
}
StepStatus[] toStepStatuses(string[] values) {
  return values.map!(v => v.toStepStatus).array;
}
string toString(StepStatus value) {
  return value.to!string();
}
string[] toStrings(StepStatus[] values) {
  return values.map!(v => v.toString()).array;
}
///
unittest {
  mixin(ShowTest!("StepStatus"));

  assert("pending".toStepStatus == StepStatus.pending);
  assert("inProgress".toStepStatus == StepStatus.inProgress);
  assert("completed".toStepStatus == StepStatus.completed);
  assert("skipped".toStepStatus == StepStatus.skipped);
  assert("failed".toStepStatus == StepStatus.failed);
  assert("blocked".toStepStatus == StepStatus.blocked);
  assert("unknown".toStepStatus == StepStatus.pending); // default

  assert(StepStatus.pending.toString == "pending");
  assert(StepStatus.inProgress.toString == "inProgress");
  assert(StepStatus.completed.toString == "completed");
  assert(StepStatus.skipped.toString == "skipped");
  assert(StepStatus.failed.toString == "failed");
  assert(StepStatus.blocked.toString == "blocked");

  assert(["pending", "completed"].toStepStatus == [StepStatus.pending, StepStatus.completed]);
  assert([StepStatus.pending, StepStatus.completed].toStrings == ["pending", "completed"]);
}

/// Priority level for tasks.
enum StepPriority {
  low,
  medium,
  high,
  critical,
}
StepPriority toStepPriority(string value) {
  mixin(EnumSwitch("StepPriority", "StepPriority.low"));
}
StepPriority[] toStepPriority(string[] values) {
  return values.map!(v => v.toStepPriority).array;
}
string toString(StepPriority value) {
  return value.to!string();
}
string[] toStrings(StepPriority[] values) {
  return values.map!(v => v.toString()).array;
}
///
unittest {
  mixin(ShowTest!("StepPriority"));

  assert("low".toStepPriority == StepPriority.low);
  assert("medium".toStepPriority == StepPriority.medium);
  assert("high".toStepPriority == StepPriority.high);
  assert("critical".toStepPriority == StepPriority.critical);
  assert("unknown".toStepPriority == StepPriority.low); // default

  assert(StepPriority.low.toString == "low");
  assert(StepPriority.medium.toString == "medium");
  assert(StepPriority.high.toString == "high");
  assert(StepPriority.critical.toString == "critical");

  assert(["low", "high"].toStepPriority == [StepPriority.low, StepPriority.high]);
  assert([StepPriority.low, StepPriority.high].toStrings == ["low", "high"]);
}

/// SAP system types supported in the landscape.
enum SystemType {
  sapS4Hana,
  sapS4HanaCloud,
  sapBtp,
  sapSuccessFactors,
  sapAriba,
  sapConcur,
  sapFieldglass,
  sapIntegratedBusinessPlanning,
  sapBuildWorkZone,
  onPremise,
  thirdParty,
}
SystemType toSystemType(string value) {
  mixin(EnumSwitch("SystemType", "SystemType.sapS4Hana"));
}
SystemType[] toSystemType(string[] values) {
  return values.map!(v => v.toSystemType).array;
}
string toString(SystemType value) {
  return value.to!string();
}
string[] toStrings(SystemType[] values) {
  return values.map!(v => v.toString()).array;
}
///
unittest {
  mixin(ShowTest!("SystemType"));

  assert("sapS4Hana".toSystemType == SystemType.sapS4Hana);
  assert("sapS4HanaCloud".toSystemType == SystemType.sapS4HanaCloud);
  assert("sapBtp".toSystemType == SystemType.sapBtp);
  assert("sapSuccessFactors".toSystemType == SystemType.sapSuccessFactors);
  assert("sapAriba".toSystemType == SystemType.sapAriba);
  assert("sapConcur".toSystemType == SystemType.sapConcur);
  assert("sapFieldglass".toSystemType == SystemType.sapFieldglass);
  assert("sapIntegratedBusinessPlanning".toSystemType == SystemType.sapIntegratedBusinessPlanning);
  assert("sapBuildWorkZone".toSystemType == SystemType.sapBuildWorkZone);
  assert("onPremise".toSystemType == SystemType.onPremise);
  assert("thirdParty".toSystemType == SystemType.thirdParty); 
  assert("unknown".toSystemType == SystemType.sapS4Hana); // default

  assert(SystemType.sapS4Hana.toString == "sapS4Hana");
  assert(SystemType.sapS4HanaCloud.toString == "sapS4HanaCloud");
  assert(SystemType.sapBtp.toString == "sapBtp");
  assert(SystemType.sapSuccessFactors.toString == "sapSuccessFactors");
  assert(SystemType.sapAriba.toString == "sapAriba");
  assert(SystemType.sapConcur.toString == "sapConcur");
  assert(SystemType.sapFieldglass.toString == "sapFieldglass");
  assert(SystemType.sapIntegratedBusinessPlanning.toString == "sapIntegratedBusinessPlanning");
  assert(SystemType.sapBuildWorkZone.toString == "sapBuildWorkZone");
  assert(SystemType.onPremise.toString == "onPremise");
  assert(SystemType.thirdParty.toString == "thirdParty");

  assert(["sapS4Hana", "sapBtp"].toSystemType == [SystemType.sapS4Hana, SystemType.sapBtp]);
  assert([SystemType.sapS4Hana, SystemType.sapBtp].toStrings == ["sapS4Hana", "sapBtp"]);
}

/// Connection status of a system in the landscape.
enum ConnectionStatus {
  active,
  inactive,
  error,
  testing,
}
ConnectionStatus toConnectionStatus(string value) {
  mixin(EnumSwitch("ConnectionStatus", "ConnectionStatus.active"));
}
ConnectionStatus[] toConnectionStatuses(string[] values) {
  return values.map!(v => v.toConnectionStatus).array;
}
string toString(ConnectionStatus value) {
  return value.to!string();
}
string[] toStrings(ConnectionStatus[] values) {
  return values.map!(v => v.toString()).array;
}
///
unittest {
  mixin(ShowTest!("ConnectionStatus"));

  assert("active".toConnectionStatus == ConnectionStatus.active);
  assert("inactive".toConnectionStatus == ConnectionStatus.inactive);
  assert("error".toConnectionStatus == ConnectionStatus.error);
  assert("testing".toConnectionStatus == ConnectionStatus.testing);
  assert("unknown".toConnectionStatus == ConnectionStatus.active); // default

  assert(ConnectionStatus.active.toString == "active");
  assert(ConnectionStatus.inactive.toString == "inactive");
  assert(ConnectionStatus.error.toString == "error");
  assert(ConnectionStatus.testing.toString == "testing");

  assert(["active", "error"].toConnectionStatus == [ConnectionStatus.active, ConnectionStatus.error]);
  assert([ConnectionStatus.active, ConnectionStatus.error].toStrings == ["active", "error"]);
}

/// Destination / API protocol type.
enum DestinationType {
  http,
  rfc,
  odata,
  soap,
  restApi,
}
DestinationType toDestinationType(string value) {
  mixin(EnumSwitch("DestinationType", "DestinationType.http"));
}
DestinationType[] toDestinationType(string[] values) {
  return values.map!(v => v.toDestinationType).array;
}
string toString(DestinationType value) {
  return value.to!string();
}
string[] toStrings(DestinationType[] values) {
  return values.map!(v => v.toString()).array;
}
///
unittest {
  mixin(ShowTest!("DestinationType"));  

  assert("http".toDestinationType == DestinationType.http);
  assert("rfc".toDestinationType == DestinationType.rfc);
  assert("odata".toDestinationType == DestinationType.odata);
  assert("soap".toDestinationType == DestinationType.soap);
  assert("restApi".toDestinationType == DestinationType.restApi);
  assert("unknown".toDestinationType == DestinationType.http); // default

  assert(DestinationType.http.toString == "http");
  assert(DestinationType.rfc.toString == "rfc");
  assert(DestinationType.odata.toString == "odata");
  assert(DestinationType.soap.toString == "soap");
  assert(DestinationType.restApi.toString == "restApi");

  assert(["http", "odata"].toDestinationType == [DestinationType.http, DestinationType.odata]);
  assert([DestinationType.http, DestinationType.odata].toStrings == ["http", "odata"]);
}

/// Authentication method for destinations.
enum AuthenticationType {
  basic,
  oauth2ClientCredentials,
  oauth2Saml,
  certificate,
  samlBearer,
  principalPropagation,
  noAuthentication,
}
AuthenticationType toAuthenticationType(string value) {
  mixin(EnumSwitch("AuthenticationType", "AuthenticationType.basic"));
}
AuthenticationType[] toAuthenticationType(string[] values) {
  return values.map!(v => v.toAuthenticationType).array;
}
string toString(AuthenticationType value) {
  return value.to!string();
}
string[] toStrings(AuthenticationType[] values) {
  return values.map!(v => v.toString()).array;
}
///
unittest {
  mixin(ShowTest!("AuthenticationType"));

  assert("basic".toAuthenticationType == AuthenticationType.basic);
  assert("oauth2ClientCredentials".toAuthenticationType == AuthenticationType.oauth2ClientCredentials);
  assert("oauth2Saml".toAuthenticationType == AuthenticationType.oauth2Saml);
  assert("certificate".toAuthenticationType == AuthenticationType.certificate);
  assert("samlBearer".toAuthenticationType == AuthenticationType.samlBearer);
  assert("principalPropagation".toAuthenticationType == AuthenticationType.principalPropagation);
  assert("noAuthentication".toAuthenticationType == AuthenticationType.noAuthentication);
  assert("unknown".toAuthenticationType == AuthenticationType.basic); // default

  assert(AuthenticationType.basic.toString == "basic");
  assert(AuthenticationType.oauth2ClientCredentials.toString == "oauth2ClientCredentials");
  assert(AuthenticationType.oauth2Saml.toString == "oauth2Saml");
  assert(AuthenticationType.certificate.toString == "certificate");
  assert(AuthenticationType.samlBearer.toString == "samlBearer");
  assert(AuthenticationType.principalPropagation.toString == "principalPropagation");
  assert(AuthenticationType.noAuthentication.toString == "noAuthentication");

  assert(["basic", "certificate"].toAuthenticationType == [AuthenticationType.basic, AuthenticationType.certificate]);
  assert([AuthenticationType.basic, AuthenticationType.certificate].toStrings == ["basic", "certificate"]);
}

/// Proxy type for destination routing.
enum ProxyType {
  internet,
  onPremise,
  privateLink,
}
ProxyType toProxyType(string value) {
  mixin(EnumSwitch("ProxyType", "ProxyType.internet"));
}
ProxyType[] toProxyType(string[] values) {
  return values.map!(v => v.toProxyType).array;
}
string toString(ProxyType value) {
  return value.to!string();
}
string[] toStrings(ProxyType[] values) {
  return values.map!(v => v.toString()).array;
}
///
unittest {
  mixin(ShowTest!("ProxyType"));

  assert("internet".toProxyType == ProxyType.internet);
  assert("onPremise".toProxyType == ProxyType.onPremise);
  assert("privateLink".toProxyType == ProxyType.privateLink);
  assert("unknown".toProxyType == ProxyType.internet); // default 

  assert(ProxyType.internet.toString == "internet");
  assert(ProxyType.onPremise.toString == "onPremise");
  assert(ProxyType.privateLink.toString == "privateLink");

  assert(["internet", "onPremise"].toProxyType == [ProxyType.internet, ProxyType.onPremise]);
  assert([ProxyType.internet, ProxyType.onPremise].toStrings == ["internet", "onPremise"]);
}

/// Outcome of executing a step or automation.
enum ExecutionOutcome {
  success,
  failure,
  skipped,
  timeout,
  error,
}
ExecutionOutcome toExecutionOutcome(string value) {
  mixin(EnumSwitch("ExecutionOutcome", "ExecutionOutcome.success"));
}
ExecutionOutcome[] toExecutionOutcome(string[] values) {
  return values.map!(v => v.toExecutionOutcome).array;
}
string toString(ExecutionOutcome value) {
  return value.to!string();
}
string[] toStrings(ExecutionOutcome[] values) {
  return values.map!(v => v.toString()).array;
} 
///
unittest {
  mixin(ShowTest!("ExecutionOutcome"));

  assert("success".toExecutionOutcome == ExecutionOutcome.success);
  assert("failure".toExecutionOutcome == ExecutionOutcome.failure);
  assert("skipped".toExecutionOutcome == ExecutionOutcome.skipped);
  assert("timeout".toExecutionOutcome == ExecutionOutcome.timeout);
  assert("error".toExecutionOutcome == ExecutionOutcome.error);
  assert("unknown".toExecutionOutcome == ExecutionOutcome.success); // default

  assert(ExecutionOutcome.success.toString == "success");
  assert(ExecutionOutcome.failure.toString == "failure");
  assert(ExecutionOutcome.skipped.toString == "skipped");
  assert(ExecutionOutcome.timeout.toString == "timeout");
  assert(ExecutionOutcome.error.toString == "error");

  assert(["success", "skipped"].toExecutionOutcome == [ExecutionOutcome.success, ExecutionOutcome.skipped]);
  assert([ExecutionOutcome.success, ExecutionOutcome.skipped].toStrings == ["success", "skipped"]);
}

/// Category of an integration scenario.
enum ScenarioCategory {
  leadToCash,
  sourceToPay,
  recruitToRetire,
  designToOperate,
  btpServices,
  s4HanaIntegration,
  communicationManagement,
  custom,
}
ScenarioCategory toScenarioCategory(string value) {
  mixin(EnumSwitch("ScenarioCategory", "ScenarioCategory.custom"));
}
ScenarioCategory[] toScenarioCategory(string[] values) {
  return values.map!(v => v.toScenarioCategory).array;
}
string toString(ScenarioCategory value) {
  return value.to!string();
}
string[] toStrings(ScenarioCategory[] values) {
  return values.map!(v => v.toString()).array;
}
///
unittest {
  mixin(ShowTest!("ScenarioCategory")); 

  assert("leadToCash".toScenarioCategory == ScenarioCategory.leadToCash);
  assert("sourceToPay".toScenarioCategory == ScenarioCategory.sourceToPay);
  assert("recruitToRetire".toScenarioCategory == ScenarioCategory.recruitToRetire);
  assert("designToOperate".toScenarioCategory == ScenarioCategory.designToOperate);
  assert("btpServices".toScenarioCategory == ScenarioCategory.btpServices);
  assert("s4HanaIntegration".toScenarioCategory == ScenarioCategory.s4HanaIntegration);
  assert("communicationManagement".toScenarioCategory == ScenarioCategory.communicationManagement);
  assert("custom".toScenarioCategory == ScenarioCategory.custom);
  assert("unknown".toScenarioCategory.toScenarioCategory == ScenarioCategory.custom); // default

  assert(ScenarioCategory.leadToCash.toString == "leadToCash");
  assert(ScenarioCategory.sourceToPay.toString == "sourceToPay");
  assert(ScenarioCategory.recruitToRetire.toString == "recruitToRetire");
  assert(ScenarioCategory.designToOperate.toString == "designToOperate");
  assert(ScenarioCategory.btpServices.toString == "btpServices");
  assert(ScenarioCategory.s4HanaIntegration.toString == "s4HanaIntegration");
  assert(ScenarioCategory.communicationManagement.toString == "communicationManagement");
  assert(ScenarioCategory.custom.toString == "custom");

  assert(["leadToCash", "designToOperate"].toScenarioCategory == [ScenarioCategory.leadToCash, ScenarioCategory.designToOperate]);
  assert([ScenarioCategory.leadToCash, ScenarioCategory.designToOperate].toStrings == ["leadToCash", "designToOperate"]);
}

enum ScenarioType {
  standard,
  custom,
}
ScenarioType toScenarioType(string s) { 
  mixin(EnumSwitch("ScenarioType", "ScenarioType.custom"));
}
ScenarioType[] toScenarioType(string[] values) {
  return values.map!(v => v.toScenarioType).array;
}
string toString(ScenarioType value) {
  return value.to!string();
}
string[] toStrings(ScenarioType[] values) {
  return values.map!(v => v.toString()).array;
}
///
unittest {
  mixin(ShowTest!("ScenarioType"));

  assert("standard".toScenarioType == ScenarioType.standard);
  assert("custom".toScenarioType == ScenarioType.custom);
  assert("unknown".toScenarioType.toScenarioType == ScenarioType.custom); // default  

  assert(ScenarioType.standard.toString == "standard");
  assert(ScenarioType.custom.toString == "custom"); 

  assert(["standard", "custom"].toScenarioType == [ScenarioType.standard, ScenarioType.custom]);
  assert([ScenarioType.standard, ScenarioType.custom].toStrings == ["standard", "custom"]);
}
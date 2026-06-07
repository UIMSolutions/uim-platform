/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.domain.enumerations;

import uim.platform.integration.automation;

// mixin(ShowModule!());

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

/// Workflow instance execution status.
enum WorkflowStatus {
  planned,
  inProgress,
  completed,
  terminated,
  failed,
  suspended,
}
WorkflowStatus toWorkflowStatus(string s) {
  switch (s) {
    case "planned":
      return WorkflowStatus.planned;
    case "inProgress":
      return WorkflowStatus.inProgress;
    case "completed":
      return WorkflowStatus.completed;
    case "terminated":
      return WorkflowStatus.terminated;
    case "failed":
      return WorkflowStatus.failed;
    case "suspended":
      return WorkflowStatus.suspended;
    default:
    return WorkflowStatus.planned; // default to planned if unknown
  }
}

/// Type of workflow step / task.
enum StepType {
  manual,
  automated,
  approval,
  notification,
}
StepType toStepType(string s) {
  switch (s) {
    case "manual":
      return StepType.manual;
    case "automated":
      return StepType.automated;
    case "approval":
      return StepType.approval;
    case "notification":
      return StepType.notification;
    default:
    return StepType.manual; // default to manual if unknown
  }
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
StepStatus toStepStatus(string s) {
  switch (s) {
    case "pending":
      return StepStatus.pending;
    case "inProgress":
      return StepStatus.inProgress;
    case "completed":
      return StepStatus.completed;
    case "skipped":
      return StepStatus.skipped;
    case "failed":
      return StepStatus.failed;
    case "blocked":
      return StepStatus.blocked;
    default:
    return StepStatus.pending; // default to pending if unknown
  }
}

/// Priority level for tasks.
enum StepPriority {
  low,
  medium,
  high,
  critical,
}
StepPriority toStepPriority(string s) {
  switch (s) {
    case "low":
      return StepPriority.low;
    case "medium":
      return StepPriority.medium;
    case "high":
      return StepPriority.high;
    case "critical":
      return StepPriority.critical;
    default:
    return StepPriority.medium; // default to medium if unknown
  }
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
SystemType toSystemType(string s) {
  switch (s) {
    case "sapS4Hana":
      return SystemType.sapS4Hana;
    case "sapS4HanaCloud":
      return SystemType.sapS4HanaCloud;
    case "sapBtp":
      return SystemType.sapBtp;
    case "sapSuccessFactors":
      return SystemType.sapSuccessFactors;
    case "sapAriba":
      return SystemType.sapAriba;
    case "sapConcur":
      return SystemType.sapConcur;
    case "sapFieldglass":
      return SystemType.sapFieldglass;
    case "sapIntegratedBusinessPlanning":
      return SystemType.sapIntegratedBusinessPlanning;
    case "sapBuildWorkZone":
      return SystemType.sapBuildWorkZone;
    case "onPremise":
      return SystemType.onPremise;
    case "thirdParty":
      return SystemType.thirdParty;
    default:
    return SystemType.thirdParty; // default to thirdParty if unknown
  }
}

/// Connection status of a system in the landscape.
enum ConnectionStatus {
  active,
  inactive,
  error,
  testing,
}
ConnectionStatus toConnectionStatus(string s) {
  switch (s) {
    case "active":
      return ConnectionStatus.active;
    case "inactive":
      return ConnectionStatus.inactive;
    case "error":
      return ConnectionStatus.error;
    case "testing":
      return ConnectionStatus.testing;
    default:
    return ConnectionStatus.inactive; // default to inactive if unknown
  }
}

/// Destination / API protocol type.
enum DestinationType {
  http,
  rfc,
  odata,
  soap,
  restApi,
}
DestinationType toDestinationType(string s) {
  switch (s) {
    case "http":
      return DestinationType.http;
    case "rfc":
      return DestinationType.rfc;
    case "odata":
      return DestinationType.odata;
    case "soap":
      return DestinationType.soap;
    case "restApi":
      return DestinationType.restApi;
    default:
    return DestinationType.http; // default to http if unknown
  }
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
AuthenticationType toAuthenticationType(string s) {
  switch (s) {
    case "basic":
      return AuthenticationType.basic;
    case "oauth2ClientCredentials":
      return AuthenticationType.oauth2ClientCredentials;
    case "oauth2Saml":
      return AuthenticationType.oauth2Saml;
    case "certificate":
      return AuthenticationType.certificate;
    case "samlBearer":
      return AuthenticationType.samlBearer;
    case "principalPropagation":
      return AuthenticationType.principalPropagation;
    case "noAuthentication":
      return AuthenticationType.noAuthentication;
    default:
    return AuthenticationType.noAuthentication; // default to noAuthentication if unknown
  }
}

/// Proxy type for destination routing.
enum ProxyType {
  internet,
  onPremise,
  privateLink,
}
ProxyType toProxyType(string s) {
  switch (s) {
    case "internet":
      return ProxyType.internet;
    case "onPremise":
      return ProxyType.onPremise;
    case "privateLink":
      return ProxyType.privateLink;
    default:
      return ProxyType.internet; // default to internet if unknown
  }
}

/// Outcome of executing a step or automation.
enum ExecutionOutcome {
  success,
  failure,
  skipped,
  timeout,
  error,
}
ExecutionOutcome toExecutionOutcome(string s) {
  switch (s) {
    case "success":
      return ExecutionOutcome.success;
    case "failure":
      return ExecutionOutcome.failure;
    case "skipped":
      return ExecutionOutcome.skipped;
    case "timeout":
      return ExecutionOutcome.timeout;
    case "error":
      return ExecutionOutcome.error;
    default:
      return ExecutionOutcome.error; // default to error if unknown
  }
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
ScenarioCategory toScenarioCategory(string s) {
  switch (s) {
    case "leadToCash":
      return ScenarioCategory.leadToCash;
    case "sourceToPay":
      return ScenarioCategory.sourceToPay;
    case "recruitToRetire":
      return ScenarioCategory.recruitToRetire;
    case "designToOperate":
      return ScenarioCategory.designToOperate;
    case "btpServices":
      return ScenarioCategory.btpServices;
    case "s4HanaIntegration":
      return ScenarioCategory.s4HanaIntegration;
    case "communicationManagement":
      return ScenarioCategory.communicationManagement;
    case "custom":
      return ScenarioCategory.custom;
    default:
      return ScenarioCategory.custom; // default to custom if unknown
  }
}

enum ScenarioType {
  standard,
  custom,
}
ScenarioType toScenarioType(string s) { 
  switch (s) {
    case "standard":
      return ScenarioType.standard;
    case "custom":
      return ScenarioType.custom;
    default:
      return ScenarioType.custom; // default to custom if unknown
  }
}
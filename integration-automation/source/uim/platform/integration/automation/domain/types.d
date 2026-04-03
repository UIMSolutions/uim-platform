/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.domain.types;

/// Unique identifier type aliases for type safety.
alias ScenarioId = string;
alias WorkflowId = string;
alias StepId = string;
alias SystemId = string;
alias DestinationId = string;
alias TaskAssignmentId = string;
alias ExecutionLogId = string;
alias TenantId = string;
alias UserId = string;

/// Integration scenario lifecycle status.
enum ScenarioStatus
{
  draft,
  active,
  deprecated_,
  archived,
}

/// Workflow instance execution status.
enum WorkflowStatus
{
  planned,
  inProgress,
  completed,
  terminated,
  failed,
  suspended,
}

/// Type of workflow step / task.
enum StepType
{
  manual,
  automated,
  approval,
  notification,
}

/// Status of an individual workflow step.
enum StepStatus
{
  pending,
  inProgress,
  completed,
  skipped,
  failed,
  blocked,
}

/// Priority level for tasks.
enum StepPriority
{
  low,
  medium,
  high,
  critical,
}

/// SAP system types supported in the landscape.
enum SystemType
{
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

/// Connection status of a system in the landscape.
enum ConnectionStatus
{
  active,
  inactive,
  error,
  testing,
}

/// Destination / API protocol type.
enum DestinationType
{
  http,
  rfc,
  odata,
  soap,
  restApi,
}

/// Authentication method for destinations.
enum AuthenticationType
{
  basic,
  oauth2ClientCredentials,
  oauth2Saml,
  certificate,
  samlBearer,
  principalPropagation,
  noAuthentication,
}

/// Proxy type for destination routing.
enum ProxyType
{
  internet,
  onPremise,
  privateLink,
}

/// Outcome of executing a step or automation.
enum ExecutionOutcome
{
  success,
  failure,
  skipped,
  timeout,
  error,
}

/// Category of an integration scenario.
enum ScenarioCategory
{
  leadToCash,
  sourceToPay,
  recruitToRetire,
  designToOperate,
  btpServices,
  s4HanaIntegration,
  communicationManagement,
  custom,
}

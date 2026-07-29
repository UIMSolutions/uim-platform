/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_automation.application.dto;

import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

struct CreateScenarioRequest {
  TenantId tenantId;
  string name;
  string description;
  string category;
  string version_;
  string sourceSystemType;
  string targetSystemType;
  string[] prerequisites;
  ScenarioStepTemplate[] stepTemplates;
  UserId createdBy;
}

struct UpdateScenarioRequest {
  TenantId tenantId;
  ScenarioId scenarioId;
  string name;
  string description;
  string category;
  string version_;
  string status;
  string sourceSystemType;
  string targetSystemType;
  string[] prerequisites;
  ScenarioStepTemplate[] stepTemplates;
}
// ──────────────── Workflow DTOs ────────────────

struct CreateWorkflowRequest {
  TenantId tenantId;
  ScenarioId scenarioId;
  string name;
  string description;
  SystemConnectionId sourceSystemConnectionId;
  SystemConnectionId targetSystemConnectionId;
  UserId createdBy;
}

struct UpdateWorkflowStatusRequest {
  WorkflowId workflowId;
  TenantId tenantId;
  WorkflowStatus status;
}
// ──────────────── Workflow Step DTOs ────────────────

struct CreateStepRequest {
  WorkflowId workflowId;
  TenantId tenantId;
  string name;
  string description;
  string type_;
  string priority;
  int sequenceNumber;
  string assignedTo;
  string assignedRole;
  string instructions;
  string automationEndpoint;
  string automationPayload;
  SystemConnectionId sourceSystemConnectionId;
  SystemConnectionId targetSystemConnectionId;
  WorkflowStepId[] dependencies;
  int estimatedDurationMinutes;
}

struct CompleteStepRequest {
  WorkflowStepId stepId;
  TenantId tenantId;
  UserId completedBy;
  string result;
}

struct FailStepRequest {
  WorkflowStepId stepId;
  TenantId tenantId;
  UserId reportedBy;
  string errorMessage;
}

struct SkipStepRequest {
  WorkflowStepId stepId;
  TenantId tenantId;
  UserId skippedBy;
  string reason;
}

struct AssignStepRequest {
  WorkflowStepId stepId;
  TenantId tenantId;
  UserId assignedTo;
  string assignedRole;
}
// ──────────────── System Connection DTOs ────────────────

struct CreateSystemRequest {
  TenantId tenantId;
  string name;
  string description;
  SystemType systemType;
  string host;
  ushort port;
  string client;
  string protocol;
  string environment;
  string region;
  string systemId;
  string tenant;
  UserId createdBy;
}

struct UpdateSystemRequest {
  SystemConnectionId connectionId;
  TenantId tenantId;
  string name;
  string description;
  SystemType systemType;
  string host;
  ushort port;
  string client;
  string protocol;
  ConnectionStatus status;
  string environment;
  string region;
  string tenant;
}
// ──────────────── Destination DTOs ────────────────

struct CreateDestinationRequest {
  TenantId tenantId;
  string name;
  string description;
  SystemConnectionId connectionId;

  DestinationType destinationType;
  string url;
  AuthenticationType authenticationType;
  ProxyType proxyType;
  string cloudConnectorLocationId;
  string user;
  string tokenServiceUrl;
  string tokenServiceUser;
  string audience;
  string scope_;
  UserId createdBy;
}

struct UpdateDestinationRequest {
  DestinationId destinationId;
  TenantId tenantId;
  string name;
  string description;
  SystemConnectionId connectionId;
  DestinationType destinationType;
  string url;
  AuthenticationType authenticationType;
  ProxyType proxyType;
  string cloudConnectorLocationId;
  string user;
  string tokenServiceUrl;
  string tokenServiceUser;
  string audience;
  string scope_;
  bool isEnabled;
}
// ──────────────── Generic result ────────────────



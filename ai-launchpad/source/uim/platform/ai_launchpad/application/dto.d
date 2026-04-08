/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.application.dto;

// --- Connection ---
struct CreateConnectionRequest {
  string workspaceId;
  string name;
  string type;
  string url;
  string authUrl;
  string clientId;
  string clientSecret;
  string description;
  string defaultResourceGroupId;
}

struct PatchConnectionRequest {
  string connectionId;
  string name;
  string description;
  string defaultResourceGroupId;
}

// --- Workspace ---
struct CreateWorkspaceRequest {
  TenantId tenantId;
  string name;
  string description;
}

struct PatchWorkspaceRequest {
  string workspaceId;
  TenantId tenantId;
  string name;
  string description;
}

// --- Scenario ---
struct SyncScenarioRequest {
  string connectionId;
  string scenarioId;
  string name;
  string description;
  string[] labels;
}

// --- Configuration ---
struct CreateConfigurationRequest {
  string connectionId;
  string scenarioId;
  string executableId;
  string name;
  string[][] parameterValues;
  string[][] inputArtifacts;
}

// --- Execution ---
struct CreateExecutionRequest {
  string connectionId;
  string configurationId;
  string resourceGroupId;
}

struct PatchExecutionRequest {
  string connectionId;
  string executionId;
  string targetStatus;
}

struct BulkPatchExecutionRequest {
  string connectionId;
  string[] executionIds;
  string targetStatus;
}

// --- Deployment ---
struct CreateDeploymentRequest {
  string connectionId;
  string configurationId;
  string resourceGroupId;
  int ttl;
}

struct PatchDeploymentRequest {
  string connectionId;
  string deploymentId;
  string targetStatus;
  string configurationId;
  int ttl;
}

struct BulkPatchDeploymentRequest {
  string connectionId;
  string[] deploymentIds;
  string targetStatus;
}

// --- Model ---
struct RegisterModelRequest {
  string connectionId;
  string name;
  string version_;
  string description;
  string scenarioId;
  string executionId;
  string url;
  long size;
  string[] labels;
}

struct PatchModelRequest {
  string connectionId;
  string modelId;
  string description;
  string status;
}

// --- Dataset ---
struct RegisterDatasetRequest {
  string connectionId;
  string name;
  string description;
  string scenarioId;
  string url;
  long size;
  string[] labels;
}

struct PatchDatasetRequest {
  string connectionId;
  string datasetId;
  string description;
  string status;
}

// --- Prompt ---
struct CreatePromptRequest {
  string collectionId;
  string name;
  string modelName;
  string modelVersion;
  string[][] messages; // [role, content] pairs
  double temperature;
  int maxTokens;
  double topP;
  double frequencyPenalty;
  double presencePenalty;
  string[] inputParams;
  string createdBy;
}

struct PatchPromptRequest {
  string promptId;
  string name;
  string status;
  string[][] messages;
  double temperature;
  int maxTokens;
}

// --- Prompt Collection ---
struct CreatePromptCollectionRequest {
  string name;
  string description;
  string scenarioId;
  string workspaceId;
}

struct PatchPromptCollectionRequest {
  string collectionId;
  string name;
  string description;
}

// --- Resource Group ---
struct CreateResourceGroupRequest {
  string connectionId;
  string resourceGroupId;
  string[][] labels;
}

struct PatchResourceGroupRequest {
  string connectionId;
  string resourceGroupId;
  string[][] labels;
}

// --- Usage Statistics ---
struct GetStatisticsRequest {
  string connectionId;
  string scenarioId;
  string period;
}

// --- Capabilities ---
struct CapabilitiesResponse {
  string serviceName;
  string serviceVersion;
  string[] supportedRuntimes;
  string[] features;
  bool multiTenant;
  bool genAiHub;
  bool promptManagement;
  bool usageStatistics;
  bool bulkOperations;
  int maxConnections;
}

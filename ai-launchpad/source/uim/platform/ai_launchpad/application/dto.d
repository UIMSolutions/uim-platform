/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.application.dto;
import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:
// --- Connection ---
struct CreateConnectionRequest {
  TenantId tenantId;
  ConnectionId connectionId; // optional for create, required for patch
  WorkspaceId workspaceId;

  string name;
  string type;
  string url;
  string authUrl;
  string clientId;
  string clientSecret;
  string description;
  string defaultResourceGroupId;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("workspaceId", workspaceId.value)
      .set("connectionId", connectionId)
      .set("name", name)
      .set("type", type)
      .set("url", url)
      .set("authUrl", authUrl)
      .set("clientId", clientId)
      .set("clientSecret", clientSecret)
      .set("description", description)
      .set("defaultResourceGroupId", defaultResourceGroupId);
  }
}

struct PatchConnectionRequest {
  TenantId tenantId;
  WorkspaceId workspaceId;
  ConnectionId connectionId; // required for patch

  string name;
  string description;
  string defaultResourceGroupId;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("workspaceId", workspaceId.value)
      .set("connectionId", connectionId)
      .set("name", name)
      .set("description", description)
      .set("defaultResourceGroupId", defaultResourceGroupId);
  }
}

// --- Workspace ---
struct CreateWorkspaceRequest {
  TenantId tenantId;
  string name;
  string description;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("name", name)
      .set("description", description);
  }
}

struct PatchWorkspaceRequest {
  WorkspaceId workspaceId;
  TenantId tenantId;
  string name;
  string description;

  Json toJson() const {
    return Json.emptyObject
      .set("workspaceId", workspaceId)
      .set("tenantId", tenantId.value)
      .set("name", name)
      .set("description", description);
  }
}

// --- Scenario ---
struct SyncScenarioRequest {
  TenantId tenantId;
  ConnectionId connectionId;
  ScenarioId scenarioId;
  string name;
  string description;
  string[] labels;

  Json toJson() const {
    return Json.emptyObject
      .set("connectionId", connectionId)
      .set("scenarioId", scenarioId)
      .set("name", name)
      .set("description", description)
      .set("labels", labels.array.toJson);
  }
}

// --- Configuration ---
struct CreateConfigurationRequest {
  TenantId tenantId;
  ConnectionId connectionId;
  ScenarioId scenarioId;
  // ExecutableId executableId;
  string name;
  string[][] parameterValues;
  string[][] inputArtifacts;

  Json toJson() const {
    return Json.emptyObject
      .set("connectionId", connectionId)
      .set("scenarioId", scenarioId) // .set("executableId", executableId)
      .set("name", name)
      .set("parameterValues", parameterValues.array.toJson)
      .set("inputArtifacts", inputArtifacts.array.toJson);
  }
}

// --- Execution ---
struct CreateExecutionRequest {
  TenantId tenantId;
  ConnectionId connectionId;
  ConfigurationId configurationId;
  ResourceGroupId resourceGroupId;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("connectionId", connectionId.value)
      .set("configurationId", configurationId.value)
      .set("resourceGroupId", resourceGroupId.value);
  }
}

struct PatchExecutionRequest {
  TenantId tenantId;
  ConnectionId connectionId;
  ExecutionId executionId;
  string targetStatus;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("connectionId", connectionId.value)
      .set("executionId", executionId.value)
      .set("targetStatus", targetStatus);
  }
}

struct BulkPatchExecutionRequest {
  TenantId tenantId;
  ConnectionId connectionId;
  ExecutionId[] executionIds;
  string targetStatus;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("connectionId", connectionId.value)
      .set("executionIds", executionIds.array.map!(e => e.value).array.toJson)
      .set("targetStatus", targetStatus);
  }
}

// --- Deployment ---
struct CreateDeploymentRequest {
  TenantId tenantId;
  ConnectionId connectionId;
  ConfigurationId configurationId;
  ResourceGroupId resourceGroupId;
  int ttl;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("connectionId", connectionId.value)
      .set("configurationId", configurationId.value)
      .set("resourceGroupId", resourceGroupId.value)
      .set("ttl", ttl);
  }
}

struct PatchDeploymentRequest {
  TenantId tenantId;
  ConnectionId connectionId;
  DeploymentId deploymentId;
  string targetStatus;
  ConfigurationId configurationId;
  int ttl;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("connectionId", connectionId.value)
      .set("deploymentId", deploymentId.value)
      .set("targetStatus", targetStatus)
      .set("configurationId", configurationId.value)
      .set("ttl", ttl);
  }
}

struct BulkPatchDeploymentRequest {
  TenantId tenantId;
  ConnectionId connectionId;
  DeploymentId[] deploymentIds;
  string targetStatus;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("connectionId", connectionId.value)
      .set("deploymentIds", deploymentIds.array.map!(e => e.value)
          .array.toJson)
      .set("targetStatus", targetStatus);
  }

}

// --- Model ---
struct RegisterModelRequest {
  TenantId tenantId;
  ConnectionId connectionId;
  string name;
  string version_;
  string description;
  ScenarioId scenarioId;
  ExecutionId executionId;
  string url;
  long size;
  string[] labels;

  Json toJson() const {
    return Json.emptyObject
      .set("connectionId", connectionId.value)
      .set("name", name)
      .set("version", version_)
      .set("description", description)
      .set("scenarioId", scenarioId.value)
      .set("executionId", executionId.value)
      .set("url", url)
      .set("size", size)
      .set("labels", labels.array.toJson);
  }
}

struct PatchModelRequest {
  TenantId tenantId;
  ConnectionId connectionId;
  ModelId modelId;
  string description;
  string status;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("connectionId", connectionId.value)
      .set("modelId", modelId.value)
      .set("description", description)
      .set("status", status);
  }
}

// --- Dataset ---
struct RegisterDatasetRequest {
  TenantId tenantId;
  ConnectionId connectionId;
  string name;
  string description;
  ScenarioId scenarioId;
  string url;
  long size;
  string[] labels;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("connectionId", connectionId.value)
      .set("name", name)
      .set("description", description)
      .set("scenarioId", scenarioId.value)
      .set("url", url)
      .set("size", size)
      .set("labels", labels.array.toJson);
  }
}

struct PatchDatasetRequest {
  TenantId tenantId;
  ConnectionId connectionId;
  DatasetId datasetId;
  string description;
  string status;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("connectionId", connectionId.value)
      .set("datasetId", datasetId.value)
      .set("description", description)
      .set("status", status);
  }
}

// --- Prompt ---
struct CreatePromptRequest {
  TenantId tenantId;
  ConnectionId connectionId;
  ConnectionId collectionId;
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
  UserId createdBy;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("connectionId", connectionId.value)
      .set("collectionId", collectionId.value)
      .set("name", name)
      .set("modelName", modelName)
      .set("modelVersion", modelVersion)
      .set("messages", messages.array.toJson)
      .set("temperature", temperature)
      .set("maxTokens", maxTokens)
      .set("topP", topP)
      .set("frequencyPenalty", frequencyPenalty)
      .set("presencePenalty", presencePenalty)
      .set("inputParams", inputParams.array.toJson)
      .set("createdBy", createdBy.value);
  }
}

struct PatchPromptRequest {
  TenantId tenantId;
  ConnectionId connectionId;
  PromptId promptId;
  string name;
  string status;
  string[][] messages;
  double temperature;
  int maxTokens;
  double presencePenalty;
  double frequencyPenalty;
  double topP;
  string[] inputParams;

  Json toJson() const {
    return Json.emptyObject
      .set("promptId", promptId)
      .set("name", name)
      .set("status", status)
      .set("messages", messages.array.toJson)
      .set("temperature", temperature)
      .set("maxTokens", maxTokens)
      .set("topP", topP)
      .set("inputParams", inputParams.array.toJson)
      .set("frequencyPenalty", frequencyPenalty)
      .set("presencePenalty", presencePenalty);
  }
}

// --- Prompt Collection ---
struct CreatePromptCollectionRequest {
  TenantId tenantId;
  ConnectionId connectionId;

  string name;
  string description;
  ScenarioId scenarioId;
  WorkspaceId workspaceId;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("connectionId", connectionId.value)
      .set("name", name)
      .set("description", description)
      .set("scenarioId", scenarioId.value)
      .set("workspaceId", workspaceId.value);
  }
}

struct PatchPromptCollectionRequest {
  TenantId tenantId;
  ConnectionId connectionId;
  PromptCollectionId collectionId;
  string name;
  string description;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("connectionId", connectionId.value)
      .set("collectionId", collectionId.value)
      .set("name", name)
      .set("description", description);
  }
}

// --- Resource Group ---
struct CreateResourceGroupRequest {
  TenantId tenantId;
  ConnectionId connectionId;
  ResourceGroupId resourceGroupId;
  string[][] labels;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("connectionId", connectionId.value)
      .set("resourceGroupId", resourceGroupId.value)
      .set("labels", labels.array.toJson);
  }
}

struct PatchResourceGroupRequest {
  TenantId tenantId;
  ConnectionId connectionId;
  ResourceGroupId resourceGroupId;
  string[][] labels;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("connectionId", connectionId.value)
      .set("resourceGroupId", resourceGroupId.value)
      .set("labels", labels.array.toJson);
  }
}

// --- Usage Statistics ---
struct GetStatisticsRequest {
  TenantId tenantId;
  ConnectionId connectionId;
  ScenarioId scenarioId;
  string period;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("connectionId", connectionId.value)
      .set("scenarioId", scenarioId.value)
      .set("period", period);
  }
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

  Json toJson() const {
    return Json.emptyObject
      .set("serviceName", serviceName)
      .set("serviceVersion", serviceVersion)
      .set("supportedRuntimes", supportedRuntimes.array.toJson)
      .set("features", features.array.toJson)
      .set("multiTenant", multiTenant)
      .set("genAiHub", genAiHub)
      .set("promptManagement", promptManagement)
      .set("usageStatistics", usageStatistics)
      .set("bulkOperations", bulkOperations)
      .set("maxConnections", maxConnections);
  }
}

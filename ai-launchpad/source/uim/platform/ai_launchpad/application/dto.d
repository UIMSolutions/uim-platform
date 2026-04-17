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

  Json toJson() const {
    return Json.emptyObject
      .set("workspaceId", workspaceId)
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
  string connectionId;
  string name;
  string description;
  string defaultResourceGroupId;

  Json toJson() const {
    return Json.emptyObject
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
  string workspaceId;
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
  string connectionId;
  string scenarioId;
  string name;
  string description;
  string[] labels;

  Json toJson() const {
    return Json.emptyObject
      .set("connectionId", connectionId)
      .set("scenarioId", scenarioId)
      .set("name", name)
      .set("description", description)
      .set("labels", labels.array);
  }
}

// --- Configuration ---
struct CreateConfigurationRequest {
  string connectionId;
  string scenarioId;
  string executableId;
  string name;
  string[][] parameterValues;
  string[][] inputArtifacts;

  Json toJson() const {
    return Json.emptyObject
      .set("connectionId", connectionId)
      .set("scenarioId", scenarioId)
      .set("executableId", executableId)
      .set("name", name)
      .set("parameterValues", parameterValues.array)
      .set("inputArtifacts", inputArtifacts.array);
  }
}

// --- Execution ---
struct CreateExecutionRequest {
  string connectionId;
  string configurationId;
  string resourceGroupId;

  Json toJson() const {
    return Json.emptyObject
      .set("connectionId", connectionId)
      .set("configurationId", configurationId)
      .set("resourceGroupId", resourceGroupId);
  }
}

struct PatchExecutionRequest {
  string connectionId;
  string executionId;
  string targetStatus;

  Json toJson() const {
    return Json.emptyObject
      .set("connectionId", connectionId)
      .set("executionId", executionId)
      .set("targetStatus", targetStatus);
  }
}

struct BulkPatchExecutionRequest {
  string connectionId;
  string[] executionIds;
  string targetStatus;

  Json toJson() const {
    return Json.emptyObject
      .set("connectionId", connectionId)
      .set("executionIds", executionIds.array)
      .set("targetStatus", targetStatus);
  }
}

// --- Deployment ---
struct CreateDeploymentRequest {
  string connectionId;
  string configurationId;
  string resourceGroupId;
  int ttl;

  Json toJson() const {
    return Json.emptyObject
      .set("connectionId", connectionId)
      .set("configurationId", configurationId)
      .set("resourceGroupId", resourceGroupId)
      .set("ttl", ttl);
  }
}

struct PatchDeploymentRequest {
  string connectionId;
  string deploymentId;
  string targetStatus;
  string configurationId;
  int ttl;

  Json toJson() const {
    return Json.emptyObject
      .set("connectionId", connectionId)
      .set("deploymentId", deploymentId)
      .set("targetStatus", targetStatus)
      .set("configurationId", configurationId)
      .set("ttl", ttl);
  }
}

struct BulkPatchDeploymentRequest {
  string connectionId;
  string[] deploymentIds;
  string targetStatus;

  Json toJson() const {
    return Json.emptyObject
      .set("connectionId", connectionId)
      .set("deploymentIds", deploymentIds.array)
      .set("targetStatus", targetStatus);
  }

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

  Json toJson() const {
    return Json.emptyObject
      .set("connectionId", connectionId)
      .set("name", name)
      .set("version", version_)
      .set("description", description)
      .set("scenarioId", scenarioId)
      .set("executionId", executionId)
      .set("url", url)
      .set("size", size)
      .set("labels", labels.array);
  }
}

struct PatchModelRequest {
  string connectionId;
  string modelId;
  string description;
  string status;

  Json toJson() const {
    return Json.emptyObject
      .set("connectionId", connectionId)
      .set("modelId", modelId)
      .set("description", description)
      .set("status", status);
  }
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

  Json toJson() const {
    return Json.emptyObject
      .set("connectionId", connectionId)
      .set("name", name)
      .set("description", description)
      .set("scenarioId", scenarioId)
      .set("url", url)
      .set("size", size)
      .set("labels", labels.array);
  }
}

struct PatchDatasetRequest {
  string connectionId;
  string datasetId;
  string description;
  string status;

  Json toJson() const {
    return Json.emptyObject
      .set("connectionId", connectionId)
      .set("datasetId", datasetId)
      .set("description", description)
      .set("status", status);
  }
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

  Json toJson() const {
    return Json.emptyObject
      .set("collectionId", collectionId)
      .set("name", name)
      .set("modelName", modelName)
      .set("modelVersion", modelVersion)
      .set("messages", messages.array)
      .set("temperature", temperature)
      .set("maxTokens", maxTokens)
      .set("topP", topP)
      .set("frequencyPenalty", frequencyPenalty)
      .set("presencePenalty", presencePenalty)
      .set("inputParams", inputParams.array)
      .set("createdBy", createdBy);
  }
}

struct PatchPromptRequest {
  string promptId;
  string name;
  string status;
  string[][] messages;
  double temperature;
  int maxTokens;

  Json toJson() const {
    return Json.emptyObject
      .set("promptId", promptId)
      .set("name", name)
      .set("status", status)
      .set("messages", messages.array)
      .set("temperature", temperature)
      .set("maxTokens", maxTokens);
  }
}

// --- Prompt Collection ---
struct CreatePromptCollectionRequest {
  string name;
  string description;
  string scenarioId;
  string workspaceId;

  Json toJson() const {
    return Json.emptyObject
      .set("name", name)
      .set("description", description)
      .set("scenarioId", scenarioId)
      .set("workspaceId", workspaceId);
  }
}

struct PatchPromptCollectionRequest {
  string collectionId;
  string name;
  string description;

  Json toJson() const {
    return Json.emptyObject
      .set("collectionId", collectionId)
      .set("name", name)
      .set("description", description);
  }
}

// --- Resource Group ---
struct CreateResourceGroupRequest {
  string connectionId;
  string resourceGroupId;
  string[][] labels;

  Json toJson() const {
    return Json.emptyObject
      .set("connectionId", connectionId)
      .set("resourceGroupId", resourceGroupId)
      .set("labels", labels.array);
  }
}

struct PatchResourceGroupRequest {
  string connectionId;
  string resourceGroupId;
  string[][] labels;

  Json toJson() const {
    return Json.emptyObject
      .set("connectionId", connectionId)
      .set("resourceGroupId", resourceGroupId)
      .set("labels", labels.array);
  }
}

// --- Usage Statistics ---
struct GetStatisticsRequest {
  string connectionId;
  string scenarioId;
  string period;

  Json toJson() const {
    return Json.emptyObject
      .set("connectionId", connectionId)
      .set("scenarioId", scenarioId)
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
      .set("supportedRuntimes", supportedRuntimes.array)
      .set("features", features.array)
      .set("multiTenant", multiTenant)
      .set("genAiHub", genAiHub)
      .set("promptManagement", promptManagement)
      .set("usageStatistics", usageStatistics)
      .set("bulkOperations", bulkOperations)
      .set("maxConnections", maxConnections);
  }
}

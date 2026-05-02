/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.application.dto;

import uim.platform.ai_core;

mixin(ShowModule!()); 

@safe:

// --- Scenario ---

struct CreateScenarioRequest {
  TenantId tenantId;
  ResourceGroupId resourceGroupId;
  string id;
  string name;
  string description;
  string[] labels;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("resourceGroupId", resourceGroupId.value)
      .set("id", id)
      .set("name", name)
      .set("description", description)
      .set("labels", labels.toJson());
  }
}

// --- Executable ---

struct CreateExecutableRequest {
  TenantId tenantId;
  ResourceGroupId resourceGroupId;
  ScenarioId scenarioId;
  ExecutableId executableId;
  string name;
  string description;
  string type;
  string versionId;
  string deployable;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("resourceGroupId", resourceGroupId.value)
      .set("scenarioId", scenarioId.value)
      .set("id", id)
      .set("name", name)
      .set("description", description)
      .set("type", type)
      .set("versionId", versionId)
      .set("deployable", deployable);
  }
}

// --- Configuration ---

struct CreateConfigurationRequest {
  TenantId tenantId;
  ResourceGroupId resourceGroupId;
  ScenarioId scenarioId;
  ExecutableId executableId;
  string name;
  string[][] parameterValues;
  string[][] inputArtifacts;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("resourceGroupId", resourceGroupId.value)
      .set("scenarioId", scenarioId.value)
      .set("executableId", executableId.value)
      .set("name", name)
      .set("parameterValues", parameterValues.toJson())
      .set("inputArtifacts", inputArtifacts.toJson());
  }
}

// --- Execution ---

struct CreateExecutionRequest {
  TenantId tenantId;
  ResourceGroupId resourceGroupId;
  ConfigurationId configurationId;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("resourceGroupId", resourceGroupId.value)
      .set("configurationId", configurationId.value);
  }
}

struct PatchExecutionRequest {
  TenantId tenantId;
  ResourceGroupId resourceGroupId;
  ExecutionId executionId;
  string targetStatus;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("resourceGroupId", resourceGroupId.value)
      .set("executionId", executionId.value)
      .set("targetStatus", targetStatus);
  }
}

struct BulkPatchExecutionRequest {
  TenantId tenantId;
  ResourceGroupId resourceGroupId;
  ExecutionId[] executionIds;
  string targetStatus;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("resourceGroupId", resourceGroupId.value)
      .set("executionIds", executionIds.map!(e => e.value).array.toJson())
      .set("targetStatus", targetStatus);
  }
}

// --- Deployment ---

struct CreateDeploymentRequest {
  TenantId tenantId;
  ResourceGroupId resourceGroupId;
  ConfigurationId configurationId;
  int ttl;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("resourceGroupId", resourceGroupId.value)
      .set("configurationId", configurationId.value)
      .set("ttl", ttl);
  }
}

struct PatchDeploymentRequest {
  TenantId tenantId;
  ResourceGroupId resourceGroupId;
  DeploymentId deploymentId;
  string targetStatus;
  ConfigurationId configurationId;
  int ttl;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("resourceGroupId", resourceGroupId.value)
      .set("deploymentId", deploymentId.value)
      .set("targetStatus", targetStatus)
      .set("configurationId", configurationId.value)
      .set("ttl", ttl);
  }
}

struct BulkPatchDeploymentRequest {
  TenantId tenantId;
  ResourceGroupId resourceGroupId;
  DeploymentId[] deploymentIds;
  string targetStatus;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("resourceGroupId", resourceGroupId.value)
      .set("deploymentIds", deploymentIds.map!(d => d.value).array.toJson())
      .set("targetStatus", targetStatus);
  }
}

// --- Artifact ---

struct CreateArtifactRequest {
  TenantId tenantId;
  ResourceGroupId resourceGroupId;
  ScenarioId scenarioId;
  string name;
  string description;
  string kind;
  string url;
  string[][] labels;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("resourceGroupId", resourceGroupId.value)
      .set("scenarioId", scenarioId.value)
      .set("name", name)
      .set("description", description)
      .set("kind", kind)
      .set("url", url)
      .set("labels", labels.toJson());
  }
}

// --- Resource Group ---

struct CreateResourceGroupRequest {
  TenantId tenantId;
  ResourceGroupId resourceGroupId;
  string[][] labels;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("resourceGroupId", resourceGroupId.value)
      .set("labels", labels.toJson());
  }
}

struct PatchResourceGroupRequest {
  TenantId tenantId;
  ResourceGroupId resourceGroupId;
  string[][] labels;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("resourceGroupId", resourceGroupId.value)
      .set("labels", labels.toJson());
  }
}

// --- Docker Registry Secret ---

struct CreateDockerRegistrySecretRequest {
  TenantId tenantId;
  ResourceGroupId resourceGroupId;
  string name;
  string server;
  string username;
  string password;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("resourceGroupId", resourceGroupId.value)
      .set("name", name)
      .set("server", server)
      .set("username", username)
      .set("password", password);
  }
}

// --- Object Store Secret ---

struct CreateObjectStoreSecretRequest {
  TenantId tenantId;
  ResourceGroupId resourceGroupId;
  string name;
  string type;
  string bucket;
  string region;
  string endpoint;
  string pathPrefix;
  string accessKey;
  string secretKey;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("resourceGroupId", resourceGroupId.value)
      .set("name", name)
      .set("type", type)
      .set("bucket", bucket)
      .set("region", region)
      .set("endpoint", endpoint)
      .set("pathPrefix", pathPrefix)
      .set("accessKey", accessKey)
      .set("secretKey", secretKey);
  }
}

// --- Metrics ---

struct PatchMetricsRequest {
  TenantId tenantId;
  ResourceGroupId resourceGroupId;
  ExecutionId executionId;
  string[][] metrics;
  string[][] tags;
  string[][] customInfo;
  string[][] labels;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("resourceGroupId", resourceGroupId.value)
      .set("executionId", executionId.value)
      .set("metrics", metrics.toJson())
      .set("tags", tags.toJson())
      .set("customInfo", customInfo.toJson())
      .set("labels", labels.toJson());
  }
}

// --- Execution Schedule ---

struct CreateExecutionScheduleRequest {
  TenantId tenantId;
  ResourceGroupId resourceGroupId;
  ConfigurationId configurationId;
  string name;
  string cron;
  long start;
  long end;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("resourceGroupId", resourceGroupId.value)
      .set("configurationId", configurationId.value)
      .set("name", name)
      .set("cron", cron)
      .set("start", start)
      .set("end", end);
  }
}

struct PatchExecutionScheduleRequest {
  TenantId tenantId;
  ResourceGroupId resourceGroupId;
  ScheduleId scheduleId;
  string status;
  string cron;
  long start;
  long end;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("resourceGroupId", resourceGroupId.value)
      .set("scheduleId", scheduleId.value)
      .set("status", status)
      .set("cron", cron)
      .set("start", start)
      .set("end", end);
  }
}

// --- Meta / Capabilities ---

struct CapabilitiesResponse {
  bool logsExecutions;
  bool logsDeployments;
  bool multitenant;
  bool shareable;
  bool staticDeployments;
  bool userDeployments;
  bool userExecutions;
  bool executionSchedules;
  bool bulkUpdates;
  bool timeToLiveDeployments;
  string apiVersion;

  Json toJson() const {
    return Json.emptyObject
      .set("logsExecutions", logsExecutions)
      .set("logsDeployments", logsDeployments)
      .set("multitenant", multitenant)
      .set("shareable", shareable)
      .set("staticDeployments", staticDeployments)
      .set("userDeployments", userDeployments)
      .set("userExecutions", userExecutions)
      .set("executionSchedules", executionSchedules)
      .set("bulkUpdates", bulkUpdates)
      .set("timeToLiveDeployments", timeToLiveDeployments)
      .set("apiVersion", apiVersion);
  }
}

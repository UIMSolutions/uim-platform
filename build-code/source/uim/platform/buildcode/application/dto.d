/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.application.dto;

import uim.platform.buildcode;

// mixin(ShowModule!());

@safe:

// ── Project DTOs ─────────────────────────────────────────────────────────────

struct CreateProjectRequest {
  TenantId tenantId;

  string      name;
  string      description;
  string      type;        // ProjectType string value
  string      techStack;
  string      ownerEmail;
  string      repositoryUrl;
  string      defaultBranch;
  string[]    tags;
}

struct UpdateProjectRequest {
  TenantId tenantId;

  string      description;
  string      ownerEmail;
  string      repositoryUrl;
  string      defaultBranch;
  string      status;
  string[]    tags;
}

// ── DevSpace DTOs ─────────────────────────────────────────────────────────────

struct CreateDevSpaceRequest {
  TenantId tenantId;

  string   projectId;
  string   name;
  string   displayName;
  string   technicalUser;
  ushort   storageGiB;
  ushort   ramGiB;
}

// ── Template DTOs ─────────────────────────────────────────────────────────────

struct CreateTemplateRequest {
  TenantId tenantId;

  string      name;
  string      displayName;
  string      description;
  string      category;
  string      projectType;
  string      techStack;
  string      version_;
  string      author;
  bool        isBuiltIn;
  string[]    parameters;
}

// ── Pipeline DTOs ─────────────────────────────────────────────────────────────

struct CreatePipelineRequest {
  TenantId tenantId;
  string   projectId;
  string   name;
  string   description;
  string   stage;
  string   repositoryUrl;
  string   branch;
  string   configFilePath;
  string   triggerType;
  string   schedule;
}

struct UpdatePipelineRequest {
  string   description;
  string   branch;
  string   configFilePath;
  bool     isActive;
  string   triggerType;
  string   schedule;
}

// ── BuildJob DTOs ─────────────────────────────────────────────────────────────

struct TriggerBuildRequest {
  TenantId tenantId;

  string   pipelineId;
  string   commitSha;
  string   branch;
  string   triggeredBy;
}

// ── Deployment DTOs ───────────────────────────────────────────────────────────

struct CreateDeploymentRequest {
  TenantId tenantId;
  DeploymentId deploymentId;

  string   projectId;
  string   buildJobId;
  string   artifactVersion;
  string   targetEnvironment;
  string   targetOrg;
  string   targetSpace;
  string   deployedBy;
}

// ── AI Generation DTOs ────────────────────────────────────────────────────────

struct AIGenerateRequest {
  TenantId tenantId;

  string   projectId;
  string   requestedBy;
  string   generationType;
  string   prompt;
  string   targetFilePath;
}

// ── ServiceBinding DTOs ───────────────────────────────────────────────────────

struct CreateServiceBindingRequest {
  TenantId tenantId;
  ServiceBindingId bindingId;

  string   projectId;
  string   serviceName;
  string   servicePlan;
  string   bindingLabel;
  string   instanceId;
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Requests of the catalog use cases.
module uim.platform.ai_core.application.dtos.catalog;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

struct CreateScenarioRequest {
  TenantId tenantId;
  UserId actor;
  ResourceGroupId resourceGroupId;
  string id;
  string name;
  string description;
  Label[] labels;
}

struct UpdateScenarioRequest {
  TenantId tenantId;
  UserId actor;
  ResourceGroupId resourceGroupId;
  string id;
  Patch!string name;
  Patch!string description;
  Patch!(Label[]) labels;
}

struct CreateExecutableRequest {
  TenantId tenantId;
  UserId actor;
  ResourceGroupId resourceGroupId;
  string id;
  string scenarioId;
  string name;
  string description;
  string type = "workflow";
  string versionId = "1.0.0";
  ParameterDef[] parameters;
  ArtifactSlot[] inputArtifacts;
  ArtifactSlot[] outputArtifacts;
  Label[] labels;
}

struct UpdateExecutableRequest {
  TenantId tenantId;
  UserId actor;
  ResourceGroupId resourceGroupId;
  string id;
  Patch!string name;
  Patch!string description;
  Patch!string versionId;
  Patch!(ParameterDef[]) parameters;
  Patch!(ArtifactSlot[]) inputArtifacts;
  Patch!(ArtifactSlot[]) outputArtifacts;
  Patch!(Label[]) labels;
}

struct CreateConfigurationRequest {
  TenantId tenantId;
  UserId actor;
  ResourceGroupId resourceGroupId;
  string id; /// optional; generated if empty
  string name;
  string scenarioId;
  string executableId;
  Label[] parameterBindings;
  ArtifactRef[] inputArtifactBindings;
}

struct CreateArtifactRequest {
  TenantId tenantId;
  UserId actor;
  ResourceGroupId resourceGroupId;
  string id; /// optional; generated if empty
  string name;
  string kind = "other";
  string url;
  string description;
  string scenarioId;
  string executionId;
  Label[] labels;
}

struct UpdateArtifactRequest {
  TenantId tenantId;
  UserId actor;
  ResourceGroupId resourceGroupId;
  string id;
  Patch!string description;
  Patch!(Label[]) labels;
}

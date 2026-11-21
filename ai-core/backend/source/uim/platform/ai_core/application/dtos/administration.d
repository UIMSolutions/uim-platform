/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Requests of the administration use cases.
module uim.platform.ai_core.application.dtos.administration;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

struct CreateResourceGroupRequest {
  TenantId tenantId;
  UserId actor;
  string id;
  Label[] labels;
}

struct UpdateResourceGroupRequest {
  TenantId tenantId;
  UserId actor;
  string id;
  Patch!(Label[]) labels;
}

struct CreateDockerRegistrySecretRequest {
  TenantId tenantId;
  UserId actor;
  string id;
  string server;
  string username;
  string password; /// stored as fingerprint only
}

struct UpdateDockerRegistrySecretRequest {
  TenantId tenantId;
  UserId actor;
  string id;
  Patch!string server;
  Patch!string username;
  Patch!string password;
}

struct CreateObjectStoreSecretRequest {
  TenantId tenantId;
  UserId actor;
  ResourceGroupId resourceGroupId;
  string id;
  string type = "S3";
  string bucket;
  string endpoint;
  string region;
  string pathPrefix;
  string accessKeyId;
  string secretAccessKey; /// stored as fingerprint only
}

struct UpdateObjectStoreSecretRequest {
  TenantId tenantId;
  UserId actor;
  ResourceGroupId resourceGroupId;
  string id;
  Patch!string bucket;
  Patch!string endpoint;
  Patch!string region;
  Patch!string pathPrefix;
  Patch!string accessKeyId;
  Patch!string secretAccessKey;
}

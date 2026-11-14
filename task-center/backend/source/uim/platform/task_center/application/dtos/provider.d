/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.application.dtos.provider;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

struct CreateTaskProviderRequest {
  TenantId tenantId;
  UserId actor;
  string id;

  string name;
  string description;
  string providerType;
  string status; /// active | inactive ("" = inactive)
  string authType;
  string endpointUrl;
  string authEndpointUrl;
  string clientId;
  string clientSecret;
}

struct UpdateTaskProviderRequest {
  TenantId tenantId;
  UserId actor;
  TaskProviderId id;

  Patch!string name;
  Patch!string description;
  Patch!string providerType;
  Patch!string status; /// active | inactive
  Patch!string authType;
  Patch!string endpointUrl;
  Patch!string authEndpointUrl;
  Patch!string clientId;
  Patch!string clientSecret; /// unset = keep; "" = remove
}

/// Outcome of one provider sync.
struct SyncResult {
  string providerId;
  string providerName;
  size_t fetched;
  size_t created;
  size_t updated;
  size_t skipped; /// invalid entries in the feed
  string error; /// "" = success
  long syncedAt;

  bool succeeded() const {
    return error.length == 0;
  }
}

struct CreateTaskDefinitionRequest {
  TenantId tenantId;
  UserId actor;
  string id;

  string providerId;
  string name;
  string description;
  string category;
  string defaultPriority;
  string[] allowedActions;
  string taskSchema;
  int dueInDays;
  bool isActive = true;
  bool requiresClaim;
}

struct UpdateTaskDefinitionRequest {
  TenantId tenantId;
  UserId actor;
  TaskDefinitionId id;

  Patch!string name;
  Patch!string description;
  Patch!string category;
  Patch!string defaultPriority;
  Patch!(string[]) allowedActions;
  Patch!string taskSchema;
  Patch!int dueInDays;
  Patch!bool isActive;
  Patch!bool requiresClaim;
}

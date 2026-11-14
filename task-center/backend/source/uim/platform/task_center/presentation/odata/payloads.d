/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Validated payload (see ODataEngine.validatePayload) → request DTOs.
module uim.platform.task_center.presentation.odata.payloads;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

TenantId tenantOf(const RequestContext ctx) {
  return TenantId(ctx.tenantId);
}

UserId actorOf(const RequestContext ctx) {
  return UserId(ctx.actor);
}

/// Callers that may maintain other users' substitution rules, filters and
/// comments: local adapters (CLI, GUI, open HTTP mode) and holders of Manage.
bool privilegedOf(const RequestContext ctx) {
  return !ctx.authenticated || ctx.hasScope("Manage");
}

string textOf(Json p, string key) {
  return key in p && p[key].type == Json.Type.string ? p[key].get!string : "";
}

bool boolOf(Json p, string key, bool fallback = false) {
  return key in p && p[key].type == Json.Type.bool_ ? p[key].get!bool : fallback;
}

long longOf(Json p, string key, long fallback = 0) {
  if (key !in p)
    return fallback;
  auto v = p[key];
  if (v.type == Json.Type.int_)
    return v.get!long;
  if (v.type == Json.Type.string) {
    try
      return v.get!string.to!long;
    catch (Exception) {
    }
  }
  return fallback;
}

int intOf(Json p, string key, int fallback = 0) {
  return cast(int) longOf(p, key, fallback);
}

string[] textsOf(Json p, string key) @trusted {
  string[] values;
  if (key in p && p[key].type == Json.Type.array)
    foreach (v; p[key])
      if (v.type == Json.Type.string && v.get!string.strip.length > 0)
        values ~= v.get!string.strip;
  return values;
}

/// Present (incl. null → "") or unset.
Patch!string textPatch(Json p, string key) {
  Patch!string r;
  if (key in p)
    r = textOf(p, key);
  return r;
}

Patch!bool boolPatch(Json p, string key) {
  Patch!bool r;
  if (key in p && p[key].type == Json.Type.bool_)
    r = p[key].get!bool;
  return r;
}

Patch!int intPatch(Json p, string key) {
  Patch!int r;
  if (key in p)
    r = intOf(p, key);
  return r;
}

Patch!(string[]) textsPatch(Json p, string key) {
  Patch!(string[]) r;
  if (key in p)
    r = textsOf(p, key);
  return r;
}

// ── Tasks ───────────────────────────────────────────────────────────────────
CreateTaskRequest createTaskRequest(const RequestContext ctx, Json p) {
  CreateTaskRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = textOf(p, "id");
  r.definitionId = textOf(p, "definitionId");
  r.providerId = textOf(p, "providerId");
  r.externalTaskId = textOf(p, "externalTaskId");
  r.title = textOf(p, "title");
  r.description = textOf(p, "description");
  r.priority = textOf(p, "priority");
  r.category = textOf(p, "category");
  r.assignee = textOf(p, "assignee");
  r.creator = textOf(p, "creator");
  r.sourceApplication = textOf(p, "sourceApplication");
  if ("allowedActions" in p && p["allowedActions"].type == Json.Type.array) {
    r.allowedActions = textsOf(p, "allowedActions");
    r.allowedActionsSet = true;
  }
  r.customAttributes = textOf(p, "customAttributes");
  r.dueDate = textOf(p, "dueDate");
  return r;
}

UpdateTaskRequest updateTaskRequest(const RequestContext ctx, string key, Json p) {
  UpdateTaskRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = TaskId(key);
  r.title = textPatch(p, "title");
  r.description = textPatch(p, "description");
  r.priority = textPatch(p, "priority");
  r.category = textPatch(p, "category");
  r.assignee = textPatch(p, "assignee");
  r.sourceApplication = textPatch(p, "sourceApplication");
  r.allowedActions = textsPatch(p, "allowedActions");
  r.customAttributes = textPatch(p, "customAttributes");
  r.dueDate = textPatch(p, "dueDate");
  return r;
}

PerformTaskActionRequest performTaskActionRequest(const RequestContext ctx, Json p) {
  PerformTaskActionRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.taskId = TaskId(textOf(p, "taskId"));
  r.action = textOf(p, "action");
  r.forwardTo = textOf(p, "forwardTo");
  r.comment = textOf(p, "comment");
  return r;
}

// ── Task definitions ────────────────────────────────────────────────────────
CreateTaskDefinitionRequest createTaskDefinitionRequest(const RequestContext ctx, Json p) {
  CreateTaskDefinitionRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = textOf(p, "id");
  r.providerId = textOf(p, "providerId");
  r.name = textOf(p, "name");
  r.description = textOf(p, "description");
  r.category = textOf(p, "category");
  r.defaultPriority = textOf(p, "defaultPriority");
  r.allowedActions = textsOf(p, "allowedActions");
  r.taskSchema = textOf(p, "taskSchema");
  r.dueInDays = intOf(p, "dueInDays");
  r.isActive = boolOf(p, "isActive", true);
  r.requiresClaim = boolOf(p, "requiresClaim");
  return r;
}

UpdateTaskDefinitionRequest updateTaskDefinitionRequest(const RequestContext ctx, string key, Json p) {
  UpdateTaskDefinitionRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = TaskDefinitionId(key);
  r.name = textPatch(p, "name");
  r.description = textPatch(p, "description");
  r.category = textPatch(p, "category");
  r.defaultPriority = textPatch(p, "defaultPriority");
  r.allowedActions = textsPatch(p, "allowedActions");
  r.taskSchema = textPatch(p, "taskSchema");
  r.dueInDays = intPatch(p, "dueInDays");
  r.isActive = boolPatch(p, "isActive");
  r.requiresClaim = boolPatch(p, "requiresClaim");
  return r;
}

// ── Task providers ──────────────────────────────────────────────────────────
CreateTaskProviderRequest createTaskProviderRequest(const RequestContext ctx, Json p) {
  CreateTaskProviderRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = textOf(p, "id");
  r.name = textOf(p, "name");
  r.description = textOf(p, "description");
  r.providerType = textOf(p, "providerType");
  r.status = textOf(p, "status");
  r.authType = textOf(p, "authType");
  r.endpointUrl = textOf(p, "endpointUrl");
  r.authEndpointUrl = textOf(p, "authEndpointUrl");
  r.clientId = textOf(p, "clientId");
  r.clientSecret = textOf(p, "clientSecret");
  return r;
}

UpdateTaskProviderRequest updateTaskProviderRequest(const RequestContext ctx, string key, Json p) {
  UpdateTaskProviderRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = TaskProviderId(key);
  r.name = textPatch(p, "name");
  r.description = textPatch(p, "description");
  r.providerType = textPatch(p, "providerType");
  r.status = textPatch(p, "status");
  r.authType = textPatch(p, "authType");
  r.endpointUrl = textPatch(p, "endpointUrl");
  r.authEndpointUrl = textPatch(p, "authEndpointUrl");
  r.clientId = textPatch(p, "clientId");
  // the row never carries the secret; null keeps it, a string replaces it
  if ("clientSecret" in p && p["clientSecret"].type == Json.Type.string)
    r.clientSecret = p["clientSecret"].get!string;
  return r;
}

// ── Comments / attachments ──────────────────────────────────────────────────
CreateTaskCommentRequest createTaskCommentRequest(const RequestContext ctx, Json p) {
  CreateTaskCommentRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = textOf(p, "id");
  r.taskId = textOf(p, "taskId");
  r.content = textOf(p, "content");
  return r;
}

UpdateTaskCommentRequest updateTaskCommentRequest(const RequestContext ctx, string key, Json p) {
  UpdateTaskCommentRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.privileged = privilegedOf(ctx);
  r.id = TaskCommentId(key);
  r.content = textPatch(p, "content");
  return r;
}

CreateTaskAttachmentRequest createTaskAttachmentRequest(const RequestContext ctx, Json p) {
  CreateTaskAttachmentRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = textOf(p, "id");
  r.taskId = textOf(p, "taskId");
  r.fileName = textOf(p, "fileName");
  r.fileSize = longOf(p, "fileSize");
  r.mimeType = textOf(p, "mimeType");
  r.url = textOf(p, "url");
  r.status = textOf(p, "status");
  return r;
}

UpdateTaskAttachmentRequest updateTaskAttachmentRequest(const RequestContext ctx, string key, Json p) {
  UpdateTaskAttachmentRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = TaskAttachmentId(key);
  r.fileName = textPatch(p, "fileName");
  r.mimeType = textPatch(p, "mimeType");
  r.url = textPatch(p, "url");
  r.status = textPatch(p, "status");
  return r;
}

// ── Substitution rules / filters ────────────────────────────────────────────
CreateSubstitutionRuleRequest createSubstitutionRuleRequest(const RequestContext ctx, Json p) {
  CreateSubstitutionRuleRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.privileged = privilegedOf(ctx);
  r.id = textOf(p, "id");
  r.userId = textOf(p, "userId");
  r.substituteId = textOf(p, "substituteId");
  r.definitionId = textOf(p, "definitionId");
  r.status = textOf(p, "status");
  r.startDate = textOf(p, "startDate");
  r.endDate = textOf(p, "endDate");
  r.isAutoForward = boolOf(p, "isAutoForward");
  return r;
}

UpdateSubstitutionRuleRequest updateSubstitutionRuleRequest(const RequestContext ctx, string key, Json p) {
  UpdateSubstitutionRuleRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.privileged = privilegedOf(ctx);
  r.id = SubstitutionRuleId(key);
  r.substituteId = textPatch(p, "substituteId");
  r.definitionId = textPatch(p, "definitionId");
  r.status = textPatch(p, "status");
  r.startDate = textPatch(p, "startDate");
  r.endDate = textPatch(p, "endDate");
  r.isAutoForward = boolPatch(p, "isAutoForward");
  return r;
}

CreateUserTaskFilterRequest createUserTaskFilterRequest(const RequestContext ctx, Json p) {
  CreateUserTaskFilterRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.privileged = privilegedOf(ctx);
  r.id = textOf(p, "id");
  r.userId = textOf(p, "userId");
  r.name = textOf(p, "name");
  r.description = textOf(p, "description");
  r.criteria = textOf(p, "criteria");
  r.isDefault = boolOf(p, "isDefault");
  return r;
}

UpdateUserTaskFilterRequest updateUserTaskFilterRequest(const RequestContext ctx, string key, Json p) {
  UpdateUserTaskFilterRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.privileged = privilegedOf(ctx);
  r.id = UserTaskFilterId(key);
  r.name = textPatch(p, "name");
  r.description = textPatch(p, "description");
  r.criteria = textPatch(p, "criteria");
  r.isDefault = boolPatch(p, "isDefault");
  return r;
}

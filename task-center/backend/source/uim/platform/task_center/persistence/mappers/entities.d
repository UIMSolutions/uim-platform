/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Entity ↔ record mappers.
module uim.platform.task_center.persistence.mappers.entities;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

// ── Task ──────────────────────────────────────────────────────────────────
Json taskToRecord(const UIMTask e) {
  auto d = auditRecord(e);
  d["definitionId"] = e.definitionId.value;
  d["providerId"] = e.providerId.value;
  d["externalTaskId"] = e.externalTaskId;
  d["title"] = e.title;
  d["description"] = e.description;
  d["status"] = cast(string) e.status;
  d["priority"] = cast(string) e.priority;
  d["category"] = cast(string) e.category;
  d["outcome"] = cast(string) e.outcome;
  d["assignee"] = e.assignee;
  d["substitutedFor"] = e.substitutedFor;
  d["creator"] = e.creator;
  d["processor"] = e.processor;
  d["sourceApplication"] = e.sourceApplication;
  d["allowedActions"] = textsJson(e.allowedActions);
  d["customAttributes"] = e.customAttributes;
  d["isClaimed"] = e.isClaimed;
  d["claimedBy"] = e.claimedBy;
  d["dueDate"] = e.dueDate;
  d["completedAt"] = e.completedAt;
  return d;
}

UIMTask recordToTask(Json d) {
  UIMTask e;
  readAudit!(UIMTask, TaskId)(e, d);
  e.definitionId = TaskDefinitionId(textField(d, "definitionId"));
  e.providerId = TaskProviderId(textField(d, "providerId"));
  e.externalTaskId = textField(d, "externalTaskId");
  e.title = textField(d, "title");
  e.description = textField(d, "description");
  e.status = enumField(d, "status", TaskStatus.open);
  e.priority = enumField(d, "priority", TaskPriority.medium);
  e.category = enumField(d, "category", TaskCategory.approval);
  e.outcome = enumField(d, "outcome", TaskOutcome.none);
  e.assignee = textField(d, "assignee");
  e.substitutedFor = textField(d, "substitutedFor");
  e.creator = textField(d, "creator");
  e.processor = textField(d, "processor");
  e.sourceApplication = textField(d, "sourceApplication");
  e.allowedActions = textsField(d, "allowedActions");
  e.customAttributes = textField(d, "customAttributes");
  e.isClaimed = boolField(d, "isClaimed");
  e.claimedBy = textField(d, "claimedBy");
  e.dueDate = textField(d, "dueDate");
  e.completedAt = longField(d, "completedAt");
  return e;
}

// ── TaskDefinition ────────────────────────────────────────────────────────
Json definitionToRecord(const TaskDefinition e) {
  auto d = auditRecord(e);
  d["providerId"] = e.providerId.value;
  d["name"] = e.name;
  d["description"] = e.description;
  d["category"] = cast(string) e.category;
  d["defaultPriority"] = cast(string) e.defaultPriority;
  d["allowedActions"] = textsJson(e.allowedActions);
  d["taskSchema"] = e.taskSchema;
  d["dueInDays"] = e.dueInDays;
  d["isActive"] = e.isActive;
  d["requiresClaim"] = e.requiresClaim;
  return d;
}

TaskDefinition recordToDefinition(Json d) {
  TaskDefinition e;
  readAudit!(TaskDefinition, TaskDefinitionId)(e, d);
  e.providerId = TaskProviderId(textField(d, "providerId"));
  e.name = textField(d, "name");
  e.description = textField(d, "description");
  e.category = enumField(d, "category", TaskCategory.approval);
  e.defaultPriority = enumField(d, "defaultPriority", TaskPriority.medium);
  e.allowedActions = textsField(d, "allowedActions");
  e.taskSchema = textField(d, "taskSchema");
  e.dueInDays = intField(d, "dueInDays");
  e.isActive = boolField(d, "isActive", true);
  e.requiresClaim = boolField(d, "requiresClaim");
  return e;
}

// ── TaskProvider ──────────────────────────────────────────────────────────
Json providerToRecord(const TaskProvider e) {
  auto d = auditRecord(e);
  d["name"] = e.name;
  d["description"] = e.description;
  d["providerType"] = cast(string) e.providerType;
  d["status"] = cast(string) e.status;
  d["authType"] = cast(string) e.authType;
  d["endpointUrl"] = e.endpointUrl;
  d["authEndpointUrl"] = e.authEndpointUrl;
  d["clientId"] = e.clientId;
  d["clientSecret"] = e.clientSecret;
  d["lastSyncAt"] = e.lastSyncAt;
  d["lastSyncError"] = e.lastSyncError;
  return d;
}

TaskProvider recordToProvider(Json d) {
  TaskProvider e;
  readAudit!(TaskProvider, TaskProviderId)(e, d);
  e.name = textField(d, "name");
  e.description = textField(d, "description");
  e.providerType = enumField(d, "providerType", ProviderType.custom);
  e.status = enumField(d, "status", ProviderStatus.inactive);
  e.authType = enumField(d, "authType", AuthenticationType.none);
  e.endpointUrl = textField(d, "endpointUrl");
  e.authEndpointUrl = textField(d, "authEndpointUrl");
  e.clientId = textField(d, "clientId");
  e.clientSecret = textField(d, "clientSecret");
  e.lastSyncAt = longField(d, "lastSyncAt");
  e.lastSyncError = textField(d, "lastSyncError");
  return e;
}

// ── TaskComment ───────────────────────────────────────────────────────────
Json commentToRecord(const TaskComment e) {
  auto d = auditRecord(e);
  d["taskId"] = e.taskId.value;
  d["author"] = e.author;
  d["content"] = e.content;
  return d;
}

TaskComment recordToComment(Json d) {
  TaskComment e;
  readAudit!(TaskComment, TaskCommentId)(e, d);
  e.taskId = TaskId(textField(d, "taskId"));
  e.author = textField(d, "author");
  e.content = textField(d, "content");
  return e;
}

// ── TaskAttachment ────────────────────────────────────────────────────────
Json attachmentToRecord(const TaskAttachment e) {
  auto d = auditRecord(e);
  d["taskId"] = e.taskId.value;
  d["fileName"] = e.fileName;
  d["fileSize"] = e.fileSize;
  d["mimeType"] = e.mimeType;
  d["url"] = e.url;
  d["status"] = cast(string) e.status;
  d["uploadedBy"] = e.uploadedBy;
  return d;
}

TaskAttachment recordToAttachment(Json d) {
  TaskAttachment e;
  readAudit!(TaskAttachment, TaskAttachmentId)(e, d);
  e.taskId = TaskId(textField(d, "taskId"));
  e.fileName = textField(d, "fileName");
  e.fileSize = longField(d, "fileSize");
  e.mimeType = textField(d, "mimeType");
  e.url = textField(d, "url");
  e.status = enumField(d, "status", AttachmentStatus.available);
  e.uploadedBy = textField(d, "uploadedBy");
  return e;
}

// ── TaskAction ────────────────────────────────────────────────────────────
Json actionToRecord(const TaskAction e) {
  auto d = auditRecord(e);
  d["taskId"] = e.taskId.value;
  d["actionType"] = cast(string) e.actionType;
  d["performedBy"] = e.performedBy;
  d["performedAt"] = e.performedAt;
  d["forwardTo"] = e.forwardTo;
  d["comment"] = e.comment;
  d["fromStatus"] = cast(string) e.fromStatus;
  d["toStatus"] = cast(string) e.toStatus;
  return d;
}

TaskAction recordToAction(Json d) {
  TaskAction e;
  readAudit!(TaskAction, TaskActionId)(e, d);
  e.taskId = TaskId(textField(d, "taskId"));
  e.actionType = enumField(d, "actionType", ActionType.claim);
  e.performedBy = textField(d, "performedBy");
  e.performedAt = longField(d, "performedAt");
  e.forwardTo = textField(d, "forwardTo");
  e.comment = textField(d, "comment");
  e.fromStatus = enumField(d, "fromStatus", TaskStatus.open);
  e.toStatus = enumField(d, "toStatus", TaskStatus.open);
  return e;
}

// ── SubstitutionRule ──────────────────────────────────────────────────────
Json substitutionToRecord(const SubstitutionRule e) {
  auto d = auditRecord(e);
  d["userId"] = e.userId;
  d["substituteId"] = e.substituteId;
  d["definitionId"] = e.definitionId.value;
  d["status"] = cast(string) e.status;
  d["startDate"] = e.startDate;
  d["endDate"] = e.endDate;
  d["isAutoForward"] = e.isAutoForward;
  return d;
}

SubstitutionRule recordToSubstitution(Json d) {
  SubstitutionRule e;
  readAudit!(SubstitutionRule, SubstitutionRuleId)(e, d);
  e.userId = textField(d, "userId");
  e.substituteId = textField(d, "substituteId");
  e.definitionId = TaskDefinitionId(textField(d, "definitionId"));
  e.status = enumField(d, "status", SubstitutionStatus.active);
  e.startDate = textField(d, "startDate");
  e.endDate = textField(d, "endDate");
  e.isAutoForward = boolField(d, "isAutoForward");
  return e;
}

// ── UserTaskFilter ────────────────────────────────────────────────────────
Json filterToRecord(const UserTaskFilter e) {
  auto d = auditRecord(e);
  d["userId"] = e.userId;
  d["name"] = e.name;
  d["description"] = e.description;
  auto criteria = Json.emptyArray;
  foreach (c; e.criteria) {
    auto j = Json.emptyObject;
    j["criterionType"] = cast(string) c.criterionType;
    j["value"] = c.value;
    criteria ~= j;
  }
  d["criteria"] = criteria;
  d["isDefault"] = e.isDefault;
  return d;
}

UserTaskFilter recordToFilter(Json d) @trusted {
  UserTaskFilter e;
  readAudit!(UserTaskFilter, UserTaskFilterId)(e, d);
  e.userId = textField(d, "userId");
  e.name = textField(d, "name");
  e.description = textField(d, "description");
  if ("criteria" in d && d["criteria"].type == Json.Type.array)
    foreach (c; d["criteria"])
      if (c.type == Json.Type.object)
        e.criteria ~= FilterCriterion(enumField(c, "criterionType", FilterCriterionType.status), textField(c, "value"));
  e.isDefault = boolField(d, "isDefault");
  return e;
}

///
unittest {
  UIMTask t;
  t.id = TaskId("t1");
  t.tenantId = TenantId("acme");
  t.title = "Approve";
  t.status = TaskStatus.inProgress;
  t.allowedActions = ["approve"];
  t.dueDate = "2026-12-01";
  auto back = recordToTask(taskToRecord(t));
  assert(back.id == t.id && back.status == TaskStatus.inProgress && back.allowedActions == ["approve"] && back.dueDate == "2026-12-01");

  UserTaskFilter f;
  f.criteria = parseCriteria("status=open,assignee=$me");
  assert(recordToFilter(filterToRecord(f)).criteria == f.criteria);

  auto legacy = Json.emptyObject; // unknown enum values fall back
  legacy["status"] = "zombie";
  assert(recordToTask(legacy).status == TaskStatus.open);
}

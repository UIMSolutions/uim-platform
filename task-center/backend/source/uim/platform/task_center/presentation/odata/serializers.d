/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Entity → row (flat JSON object matching the EDM model). Provider secrets
/// are never serialized (write-only). Some properties depend on the caller
/// (availableActions, odataFilter with $me) or on the day (isOverdue,
/// effectiveStatus) and are computed per request.
module uim.platform.task_center.presentation.odata.serializers;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

/// ISO 8601 (seconds precision, UTC) or null for 0.
Json isoTime(long stdTime) @trusted {
  if (stdTime <= 0)
    return Json(null);
  auto t = SysTime(stdTime - stdTime % hnsecsPerSecond, UTC());
  return Json(t.toISOExtString);
}

Json auditRow(E)(const E e) {
  auto j = Json.emptyObject;
  j["id"] = e.id.value;
  j["tenantId"] = e.tenantId.value;
  j["createdAt"] = isoTime(e.createdAt);
  j["createdBy"] = e.createdBy.value;
  j["updatedAt"] = isoTime(e.updatedAt);
  j["updatedBy"] = e.updatedBy.value;
  return j;
}

/// Empty text → null (optional references, Edm.Date).
Json orNull(string value) {
  return value.length > 0 ? Json(value) : Json(null);
}

Json texts(const string[] values) {
  auto a = Json.emptyArray;
  foreach (v; values)
    a ~= Json(v);
  return a;
}

/// Per request context of the task rows.
struct TaskRowContext {
  string actor;
  string today;
  bool[string] requiresClaim; /// definitionId → requiresClaim
  size_t[string] comments; /// taskId → count
  size_t[string] attachments; /// taskId → count
}

Json taskRow(const UIMTask e, const TaskRowContext c) {
  auto j = auditRow(e);
  j["title"] = e.title;
  j["description"] = e.description;
  j["status"] = cast(string) e.status;
  j["priority"] = cast(string) e.priority;
  j["category"] = cast(string) e.category;
  j["outcome"] = cast(string) e.outcome;
  j["definitionId"] = orNull(e.definitionId.value);
  j["providerId"] = orNull(e.providerId.value);
  j["externalTaskId"] = orNull(e.externalTaskId);
  j["assignee"] = e.assignee;
  j["substitutedFor"] = orNull(e.substitutedFor);
  j["creator"] = e.creator;
  j["processor"] = e.processor;
  j["sourceApplication"] = e.sourceApplication;
  j["allowedActions"] = texts(e.allowedActions);
  auto available = availableActions(e, c.actor, c.requiresClaim.get(e.definitionId.value, false));
  j["availableActions"] = texts(available.map!(a => cast(string) a).array);
  j["customAttributes"] = e.customAttributes;
  j["isClaimed"] = e.isClaimed;
  j["claimedBy"] = orNull(e.claimedBy);
  j["dueDate"] = orNull(e.dueDate);
  j["isOverdue"] = e.isOverdue(c.today);
  j["completedAt"] = isoTime(e.completedAt);
  j["commentCount"] = c.comments.get(e.id.value, 0);
  j["attachmentCount"] = c.attachments.get(e.id.value, 0);
  return j;
}

Json definitionRow(const TaskDefinition e, size_t tasks = 0, size_t openTasks = 0) {
  auto j = auditRow(e);
  j["providerId"] = orNull(e.providerId.value);
  j["name"] = e.name;
  j["description"] = e.description;
  j["category"] = cast(string) e.category;
  j["defaultPriority"] = cast(string) e.defaultPriority;
  j["allowedActions"] = texts(e.allowedActions);
  j["taskSchema"] = e.taskSchema;
  j["dueInDays"] = e.dueInDays;
  j["isActive"] = e.isActive;
  j["requiresClaim"] = e.requiresClaim;
  j["taskCount"] = tasks;
  j["openTaskCount"] = openTasks;
  return j;
}

Json providerRow(const TaskProvider e, size_t tasks = 0, size_t definitions = 0) {
  auto j = auditRow(e);
  j["name"] = e.name;
  j["description"] = e.description;
  j["providerType"] = cast(string) e.providerType;
  j["status"] = cast(string) e.status;
  j["authType"] = cast(string) e.authType;
  j["endpointUrl"] = e.endpointUrl;
  j["authEndpointUrl"] = e.authEndpointUrl;
  j["clientId"] = e.clientId;
  j["clientSecret"] = Json(null);
  j["hasSecret"] = e.clientSecret.length > 0;
  j["lastSyncAt"] = isoTime(e.lastSyncAt);
  j["lastSyncError"] = orNull(e.lastSyncError);
  j["taskCount"] = tasks;
  j["definitionCount"] = definitions;
  return j;
}

Json commentRow(const TaskComment e) {
  auto j = auditRow(e);
  j["taskId"] = e.taskId.value;
  j["author"] = e.author;
  j["content"] = e.content;
  return j;
}

Json attachmentRow(const TaskAttachment e) {
  auto j = auditRow(e);
  j["taskId"] = e.taskId.value;
  j["fileName"] = e.fileName;
  j["fileSize"] = e.fileSize;
  j["mimeType"] = e.mimeType;
  j["url"] = orNull(e.url);
  j["status"] = cast(string) e.status;
  j["uploadedBy"] = e.uploadedBy;
  return j;
}

Json actionRow(const TaskAction e) {
  auto j = auditRow(e);
  j["taskId"] = e.taskId.value;
  j["actionType"] = cast(string) e.actionType;
  j["performedBy"] = e.performedBy;
  j["performedAt"] = isoTime(e.performedAt);
  j["forwardTo"] = orNull(e.forwardTo);
  j["comment"] = orNull(e.comment);
  j["fromStatus"] = cast(string) e.fromStatus;
  j["toStatus"] = cast(string) e.toStatus;
  return j;
}

Json substitutionRow(const SubstitutionRule e, string today) {
  auto j = auditRow(e);
  j["userId"] = e.userId;
  j["substituteId"] = e.substituteId;
  j["definitionId"] = orNull(e.definitionId.value);
  j["status"] = cast(string) e.status;
  j["effectiveStatus"] = cast(string) e.effectiveStatus(today);
  j["startDate"] = orNull(e.startDate);
  j["endDate"] = orNull(e.endDate);
  j["isAutoForward"] = e.isAutoForward;
  return j;
}

Json filterRow(const UserTaskFilter e, string actor) {
  auto j = auditRow(e);
  j["userId"] = e.userId;
  j["name"] = e.name;
  j["description"] = e.description;
  j["criteria"] = formatCriteria(e.criteria);
  j["isDefault"] = e.isDefault;
  // $me resolves to the filter owner, so a shared view shows the owner's inbox
  j["odataFilter"] = e.toODataFilter(e.userId.length > 0 ? e.userId : actor);
  return j;
}

Json statisticsRow(const TaskCenterStatistics s) {
  auto j = Json.emptyObject;
  static foreach (name; ["tenantId", "tasks", "openTasks", "inProgressTasks", "completedTasks", "cancelledTasks",
      "failedTasks", "overdueTasks", "highPriorityTasks", "unassignedTasks", "approvedTasks", "rejectedTasks", "providers",
      "activeProviders", "providersInError", "definitions", "activeSubstitutions", "comments", "attachments", "actions"])
    j[name] = __traits(getMember, s, name);
  return j;
}

Json syncResultRow(const SyncResult r) {
  auto j = Json.emptyObject;
  j["providerId"] = r.providerId;
  j["providerName"] = r.providerName;
  j["fetched"] = r.fetched;
  j["created"] = r.created;
  j["updated"] = r.updated;
  j["skipped"] = r.skipped;
  j["error"] = orNull(r.error);
  j["syncedAt"] = isoTime(r.syncedAt);
  return j;
}

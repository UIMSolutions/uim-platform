/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.application.dtos.task;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

struct CreateTaskRequest {
  TenantId tenantId;
  UserId actor;
  string id; /// optional, generated if empty

  string definitionId;
  string providerId;
  string externalTaskId;
  string title;
  string description;
  string priority; /// "" = definition default (or medium)
  string category; /// "" = definition default (or approval)
  string assignee; /// substitution rules may redirect it
  string creator; /// "" = actor
  string sourceApplication;
  string[] allowedActions; /// null = definition's list
  bool allowedActionsSet;
  string customAttributes;
  string dueDate; /// "" = creation day + definition.dueInDays
  string initialStatus; /// provider sync only: open | reserved (others are reached through actions)
}

struct UpdateTaskRequest {
  TenantId tenantId;
  UserId actor;
  TaskId id;

  Patch!string title;
  Patch!string description;
  Patch!string priority;
  Patch!string category;
  Patch!string assignee;
  Patch!string sourceApplication;
  Patch!(string[]) allowedActions;
  Patch!string customAttributes;
  Patch!string dueDate;
}

struct PerformTaskActionRequest {
  TenantId tenantId;
  UserId actor;
  TaskId taskId;
  string action; /// ActionType value
  string forwardTo;
  string comment; /// stored on the TaskAction and as TaskComment
}

struct TaskActionResult {
  UIMTask task;
  TaskAction action;
}

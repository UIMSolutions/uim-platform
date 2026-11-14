/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.application.usecases.manage_tasks;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class ManageTasksUseCase : IManageTasks {
  protected ITaskRepository tasks;
  protected ITaskDefinitionRepository definitions;
  protected ITaskProviderRepository providers;
  protected ISubstitutionRuleRepository substitutions;
  protected ITaskCommentRepository comments;
  protected ITaskAttachmentRepository attachments;
  protected ITaskActionRepository actions;
  protected ITaskEventPublisher events;

  this(ITaskRepository tasks, ITaskDefinitionRepository definitions, ITaskProviderRepository providers,
    ISubstitutionRuleRepository substitutions, ITaskCommentRepository comments, ITaskAttachmentRepository attachments,
    ITaskActionRepository actions, ITaskEventPublisher events) {
    this.tasks = tasks;
    this.definitions = definitions;
    this.providers = providers;
    this.substitutions = substitutions;
    this.comments = comments;
    this.attachments = attachments;
    this.actions = actions;
    this.events = events;
  }

  UIMTask[] listTasks(TenantId tenantId) {
    return tasks.findAll(tenantId);
  }

  UIMTask getTask(TenantId tenantId, TaskId id) {
    return tasks.findById(tenantId, id).required("Task '" ~ id.value ~ "'");
  }

  UIMTask createTask(CreateTaskRequest r) {
    UIMTask t;
    stampCreated!(UIMTask, TaskId)(t, r.tenantId, r.actor, r.id);
    if (tasks.existsById(r.tenantId, t.id))
      throw TaskCenterException.conflict("Task '" ~ t.id.value ~ "' already exists");

    TaskDefinition def;
    if (r.definitionId.strip.length > 0) {
      def = definitions.findById(r.tenantId, TaskDefinitionId(r.definitionId.strip))
        .required("Task definition '" ~ r.definitionId ~ "'");
      if (!def.isActive)
        throw TaskCenterException.ruleViolation("Task definition '" ~ def.name ~ "' is inactive");
      t.definitionId = def.id;
    }
    TaskProvider provider;
    if (r.providerId.strip.length > 0) {
      provider = providers.findById(r.tenantId, TaskProviderId(r.providerId.strip))
        .required("Task provider '" ~ r.providerId ~ "'");
      t.providerId = provider.id;
    }
    t.externalTaskId = r.externalTaskId.strip;
    if (t.externalTaskId.length > 0 && !tasks.findByExternalId(r.tenantId, t.providerId, t.externalTaskId).isNull)
      throw TaskCenterException.conflict("Provider task '" ~ t.externalTaskId ~ "' was already imported");

    t.title = r.title.strip;
    t.description = r.description;
    t.category = parseDomainEnumOr!TaskCategory(r.category, def.isNull ? TaskCategory.approval : def.category, "category");
    t.priority = parseDomainEnumOr!TaskPriority(r.priority, def.isNull ? TaskPriority.medium : def.defaultPriority, "priority");
    t.allowedActions = r.allowedActionsSet ? r.allowedActions.dup : (def.isNull ? null : def.allowedActions.dup);
    t.customAttributes = r.customAttributes.strip;
    t.creator = r.creator.strip.length > 0 ? r.creator.strip : r.actor.value;
    t.sourceApplication = r.sourceApplication.length > 0 ? r.sourceApplication : (provider.isNull ? "" : provider.name);
    t.dueDate = r.dueDate.strip.length > 0 ? dueDayOf(r.dueDate)
      : (!def.isNull && def.dueInDays > 0 ? addDays(isoDateOf(t.createdAt), def.dueInDays) : "");

    t.status = parseDomainEnumOr!TaskStatus(r.initialStatus, TaskStatus.open, "status");
    if (t.status != TaskStatus.open && t.status != TaskStatus.reserved)
      throw TaskCenterException.invalid("New tasks start 'open' or 'reserved'; other states are reached through actions");

    auto recipient = resolveRecipient(substitutions.findAll(r.tenantId), r.assignee.strip, t.definitionId, todayIso());
    t.assignee = recipient.assignee;
    t.substitutedFor = recipient.substitutedFor;
    if (t.status == TaskStatus.reserved && t.assignee.length == 0)
      throw TaskCenterException.invalid("Reserved tasks need an assignee");

    t.validate();
    tasks.save(t);
    publishTaskEvent(events, t, "created", r.actor.value, Json([
        "assignee": Json(t.assignee), "substitutedFor": Json(t.substitutedFor), "priority": Json(cast(string) t.priority)
      ]));
    return t;
  }

  UIMTask updateTask(UpdateTaskRequest r) {
    auto t = getTask(r.tenantId, r.id);
    if (t.isFinished)
      throw TaskCenterException.ruleViolation("Task '" ~ t.title ~ "' is " ~ cast(string) t.status ~ " and can no longer be changed");
    r.title.applyTo(t.title);
    r.description.applyTo(t.description);
    applyEnum(r.priority, t.priority, "priority");
    applyEnum(r.category, t.category, "category");
    r.sourceApplication.applyTo(t.sourceApplication);
    r.allowedActions.applyTo(t.allowedActions);
    r.customAttributes.applyTo(t.customAttributes);
    if (r.dueDate.isSet)
      t.dueDate = r.dueDate.value.strip.length > 0 ? dueDayOf(r.dueDate.value) : "";
    if (r.assignee.isSet && r.assignee.value.strip != t.assignee) {
      if (t.isClaimed)
        throw TaskCenterException.ruleViolation("Task '" ~ t.title ~ "' is claimed by " ~ t.claimedBy ~ "; forward it instead");
      auto recipient = resolveRecipient(substitutions.findAll(r.tenantId), r.assignee.value.strip, t.definitionId, todayIso());
      t.assignee = recipient.assignee;
      t.substitutedFor = recipient.substitutedFor;
    }
    t.validate();
    stampUpdated(t, r.actor);
    tasks.save(t);
    publishTaskEvent(events, t, "changed", r.actor.value);
    return t;
  }

  void deleteTask(TenantId tenantId, TaskId id) {
    auto t = getTask(tenantId, id);
    foreach (c; comments.findByTask(tenantId, id))
      comments.removeById(tenantId, c.id);
    foreach (a; attachments.findByTask(tenantId, id))
      attachments.removeById(tenantId, a.id);
    foreach (a; actions.findByTask(tenantId, id))
      actions.removeById(tenantId, a.id);
    tasks.removeById(tenantId, id);
    publishTaskEvent(events, t, "deleted", "");
  }
}

/// ISO date or timestamp → "YYYY-MM-DD" (throws invalid).
string dueDayOf(string text) {
  auto day = dayOf(text);
  if (day.length == 0)
    throw TaskCenterException.invalid("dueDate must be an ISO date (YYYY-MM-DD), got '" ~ text ~ "'");
  return day;
}

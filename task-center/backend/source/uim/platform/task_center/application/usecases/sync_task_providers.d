/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Federation: pull the tasks of a provider through ITaskProviderGateway and
/// upsert them by (providerId, externalTaskId). New tasks go through
/// IManageTasks (definition defaults, substitution); known unfinished tasks
/// get the provider's title, description, priority and due date, and are
/// closed when the provider reports them completed, cancelled or failed.
module uim.platform.task_center.application.usecases.sync_task_providers;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class SyncTaskProvidersUseCase : ISyncTaskProviders {
  protected ITaskProviderRepository providers;
  protected ITaskDefinitionRepository definitions;
  protected ITaskRepository tasks;
  protected IManageTasks taskPort;
  protected ITaskProviderGateway gateway;
  protected ITaskEventPublisher events;

  this(ITaskProviderRepository providers, ITaskDefinitionRepository definitions, ITaskRepository tasks,
    IManageTasks taskPort, ITaskProviderGateway gateway, ITaskEventPublisher events) {
    this.providers = providers;
    this.definitions = definitions;
    this.tasks = tasks;
    this.taskPort = taskPort;
    this.gateway = gateway;
    this.events = events;
  }

  SyncResult sync(TenantId tenantId, TaskProviderId id, UserId actor) {
    auto p = providers.findById(tenantId, id).required("Task provider '" ~ id.value ~ "'");
    if (p.status == ProviderStatus.inactive)
      throw TaskCenterException.ruleViolation("Task provider '" ~ p.name ~ "' is inactive");
    if (p.endpointUrl.length == 0)
      throw TaskCenterException.ruleViolation("Task provider '" ~ p.name ~ "' has no endpointUrl");

    SyncResult result;
    result.providerId = p.id.value;
    result.providerName = p.name;
    result.syncedAt = nowStdTime();

    ProviderTask[] feed;
    try
      feed = gateway.fetchTasks(ProviderConnection(p.name, p.providerType, p.authType, p.endpointUrl,
          p.authEndpointUrl, p.clientId, p.clientSecret));
    catch (Exception e) {
      result.error = e.msg;
      p.status = ProviderStatus.error;
      p.lastSyncError = e.msg;
      p.lastSyncAt = result.syncedAt;
      stampUpdated(p, actor);
      providers.save(p);
      return result;
    }

    TaskDefinition[string] byName;
    foreach (d; definitions.findAll(tenantId))
      if (d.providerId == p.id || d.name !in byName)
        byName[d.name] = d;

    foreach (pt; feed) {
      result.fetched++;
      if (pt.externalId.strip.length == 0 || pt.title.strip.length == 0) {
        result.skipped++;
        continue;
      }
      try {
        auto existing = tasks.findByExternalId(tenantId, p.id, pt.externalId.strip);
        if (existing.isNull) {
          if (importTask(tenantId, actor, p, pt, byName))
            result.created++;
          else
            result.skipped++;
        } else if (refreshTask(existing, pt, actor, result.syncedAt))
          result.updated++;
      } catch (TaskCenterException e) {
        result.skipped++;
      }
    }

    p.status = ProviderStatus.active;
    p.lastSyncError = "";
    p.lastSyncAt = result.syncedAt;
    stampUpdated(p, actor);
    providers.save(p);
    return result;
  }

  SyncResult[] syncAll(TenantId tenantId, UserId actor) {
    SyncResult[] results;
    foreach (p; providers.findAll(tenantId)) {
      if (!p.canSync)
        continue;
      try
        results ~= sync(tenantId, p.id, actor);
      catch (TaskCenterException e)
        results ~= SyncResult(p.id.value, p.name, 0, 0, 0, 0, e.msg, nowStdTime());
    }
    return results;
  }

  /// false = not imported (already finished at the provider).
  protected bool importTask(TenantId tenantId, UserId actor, const TaskProvider p, const ProviderTask pt,
    TaskDefinition[string] byName) {
    auto status = tolerant!TaskStatus(pt.status, TaskStatus.open);
    if (status.isFinal)
      return false;
    CreateTaskRequest r;
    r.tenantId = tenantId;
    r.actor = actor;
    r.providerId = p.id.value;
    r.externalTaskId = pt.externalId.strip;
    if (auto d = pt.definitionName in byName)
      if (d.isActive)
        r.definitionId = d.id.value;
    r.title = pt.title;
    r.description = pt.description;
    r.priority = cast(string) tolerant!TaskPriority(pt.priority, TaskPriority.medium);
    if (pt.priority.length == 0)
      r.priority = "";
    r.category = pt.category.length > 0 ? cast(string) tolerant!TaskCategory(pt.category, TaskCategory.approval) : "";
    r.assignee = pt.assignee;
    r.creator = pt.creator.length > 0 ? pt.creator : p.name;
    r.sourceApplication = p.name;
    if (pt.allowedActions.length > 0) {
      r.allowedActions = pt.allowedActions.filter!(a => isEnumValue!ActionType(a)).map!(a => a.idup).array;
      r.allowedActionsSet = true;
    }
    r.customAttributes = pt.customAttributes;
    r.dueDate = dayOf(pt.dueDate);
    r.initialStatus = status == TaskStatus.reserved && pt.assignee.length > 0 ? "reserved" : "open";
    taskPort.createTask(r);
    return true;
  }

  /// true = changed.
  protected bool refreshTask(UIMTask t, const ProviderTask pt, UserId actor, long now) {
    if (t.isFinished)
      return false;
    bool changed;
    void set(ref string target, string value) {
      if (value.length > 0 && target != value) {
        target = value;
        changed = true;
      }
    }

    set(t.title, pt.title.strip);
    set(t.description, pt.description);
    set(t.dueDate, dayOf(pt.dueDate));
    if (pt.priority.length > 0) {
      auto prio = tolerant!TaskPriority(pt.priority, t.priority);
      if (prio != t.priority) {
        t.priority = prio;
        changed = true;
      }
    }
    auto status = tolerant!TaskStatus(pt.status, t.status);
    if (status.isFinal) {
      t.status = status;
      t.outcome = status == TaskStatus.completed ? TaskOutcome.completed : TaskOutcome.cancelled;
      t.isClaimed = false;
      t.completedAt = now;
      changed = true;
    }
    if (!changed)
      return false;
    stampUpdated(t, actor);
    tasks.save(t);
    publishTaskEvent(events, t, status.isFinal ? "closedByProvider" : "refreshed", actor.value);
    return true;
  }
}

/// Parse a provider supplied value; unknown values fall back.
E tolerant(E)(string text, E fallback) {
  try
    return parseDomainEnumOr!E(text, fallback);
  catch (TaskCenterException)
    return fallback;
}

bool isEnumValue(E)(string text) {
  try {
    parseDomainEnum!E(text);
    return true;
  } catch (TaskCenterException)
    return false;
}

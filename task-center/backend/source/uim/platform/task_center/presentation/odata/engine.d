/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Binds the EDM model to the driving ports. The resulting engine serves
/// the OData controller, the REST controller, the CLI and the GUI.
module uim.platform.task_center.presentation.odata.engine;

import uim.platform.service.presentation.odata;
import uim.platform.task_center;

mixin(ShowModule!());

@safe:

/// IEntitySetProvider that translates TaskCenterException.
class PortProvider : IEntitySetProvider {
  protected DelegateEntitySetProvider inner;

  this(DelegateEntitySetProvider inner) {
    this.inner = inner;
  }

  Json[] list(const RequestContext ctx) {
    return translated!(Json[])(() => inner.list(ctx));
  }

  Json get(const RequestContext ctx, string key) {
    return translated!Json(() => inner.get(ctx, key));
  }

  Json create(const RequestContext ctx, Json payload) {
    return translated!Json(() => inner.create(ctx, payload));
  }

  Json update(const RequestContext ctx, string key, Json payload) {
    return translated!Json(() => inner.update(ctx, key, payload));
  }

  void remove(const RequestContext ctx, string key) {
    translated!void(() { inner.remove(ctx, key); });
  }
}

private size_t[string] countBy(T)(T[] items, scope string delegate(const T) @safe keyOf) {
  size_t[string] counts;
  foreach (item; items)
    counts[keyOf(item)]++;
  return counts;
}

ODataEngine taskCenterEngine(TaskCenterPorts ports, size_t maxPageSize = 0) {
  auto engine = new ODataEngine(taskCenterModel());

  /// Caller and tenant dependent inputs of the task rows.
  TaskRowContext rowContext(const RequestContext ctx) {
    auto t = tenantOf(ctx);
    TaskRowContext c;
    c.actor = ctx.actor;
    c.today = todayIso();
    foreach (d; ports.definitions.listTaskDefinitions(t))
      c.requiresClaim[d.id.value] = d.requiresClaim;
    c.comments = countBy(ports.comments.listTaskComments(t), (const TaskComment e) => e.taskId.value);
    c.attachments = countBy(ports.attachments.listTaskAttachments(t), (const TaskAttachment e) => e.taskId.value);
    return c;
  }

  // ── Tasks ─────────────────────────────────────────────────────────────────
  auto tasks = new DelegateEntitySetProvider;
  tasks.onList = (const RequestContext ctx) {
    auto c = rowContext(ctx);
    Json[] rows;
    foreach (e; ports.tasks.listTasks(tenantOf(ctx)))
      rows ~= taskRow(e, c);
    return rows;
  };
  tasks.onGet = (const RequestContext ctx, string key) => taskRow(ports.tasks.getTask(tenantOf(ctx), TaskId(key)), rowContext(ctx));
  tasks.onCreate = (const RequestContext ctx, Json p) => taskRow(ports.tasks.createTask(createTaskRequest(ctx, p)), rowContext(ctx));
  tasks.onUpdate = (const RequestContext ctx, string key, Json p) => taskRow(
    ports.tasks.updateTask(updateTaskRequest(ctx, key, p)), rowContext(ctx));
  tasks.onRemove = (const RequestContext ctx, string key) { ports.tasks.deleteTask(tenantOf(ctx), TaskId(key)); };

  // ── Task definitions ──────────────────────────────────────────────────────
  Json definitionOf(const RequestContext ctx, const TaskDefinition d) {
    auto all = ports.tasks.listTasks(tenantOf(ctx)).filter!(t => t.definitionId == d.id).array;
    return definitionRow(d, all.length, all.count!(t => !t.isFinished));
  }

  auto definitions = new DelegateEntitySetProvider;
  definitions.onList = (const RequestContext ctx) {
    auto t = tenantOf(ctx);
    size_t[string] total, open;
    foreach (task; ports.tasks.listTasks(t)) {
      total[task.definitionId.value]++;
      if (!task.isFinished)
        open[task.definitionId.value]++;
    }
    Json[] rows;
    foreach (d; ports.definitions.listTaskDefinitions(t))
      rows ~= definitionRow(d, total.get(d.id.value, 0), open.get(d.id.value, 0));
    return rows;
  };
  definitions.onGet = (const RequestContext ctx, string key) => definitionOf(ctx,
    ports.definitions.getTaskDefinition(tenantOf(ctx), TaskDefinitionId(key)));
  definitions.onCreate = (const RequestContext ctx, Json p) => definitionOf(ctx,
    ports.definitions.createTaskDefinition(createTaskDefinitionRequest(ctx, p)));
  definitions.onUpdate = (const RequestContext ctx, string key, Json p) => definitionOf(ctx,
    ports.definitions.updateTaskDefinition(updateTaskDefinitionRequest(ctx, key, p)));
  definitions.onRemove = (const RequestContext ctx, string key) {
    ports.definitions.deleteTaskDefinition(tenantOf(ctx), TaskDefinitionId(key));
  };

  // ── Task providers ────────────────────────────────────────────────────────
  Json providerOf(const RequestContext ctx, const TaskProvider p) {
    auto t = tenantOf(ctx);
    return providerRow(p, ports.tasks.listTasks(t).count!(e => e.providerId == p.id),
      ports.definitions.listTaskDefinitions(t).count!(d => d.providerId == p.id));
  }

  auto providers = new DelegateEntitySetProvider;
  providers.onList = (const RequestContext ctx) {
    auto t = tenantOf(ctx);
    auto taskCounts = countBy(ports.tasks.listTasks(t), (const UIMTask e) => e.providerId.value);
    auto definitionCounts = countBy(ports.definitions.listTaskDefinitions(t), (const TaskDefinition e) => e.providerId.value);
    Json[] rows;
    foreach (p; ports.providers.listTaskProviders(t))
      rows ~= providerRow(p, taskCounts.get(p.id.value, 0), definitionCounts.get(p.id.value, 0));
    return rows;
  };
  providers.onGet = (const RequestContext ctx, string key) => providerOf(ctx,
    ports.providers.getTaskProvider(tenantOf(ctx), TaskProviderId(key)));
  providers.onCreate = (const RequestContext ctx, Json p) => providerOf(ctx,
    ports.providers.createTaskProvider(createTaskProviderRequest(ctx, p)));
  providers.onUpdate = (const RequestContext ctx, string key, Json p) => providerOf(ctx,
    ports.providers.updateTaskProvider(updateTaskProviderRequest(ctx, key, p)));
  providers.onRemove = (const RequestContext ctx, string key) {
    ports.providers.deleteTaskProvider(tenantOf(ctx), TaskProviderId(key));
  };

  // ── Comments ──────────────────────────────────────────────────────────────
  auto comments = new DelegateEntitySetProvider;
  comments.onList = (const RequestContext ctx) {
    Json[] rows;
    foreach (e; ports.comments.listTaskComments(tenantOf(ctx)))
      rows ~= commentRow(e);
    return rows;
  };
  comments.onGet = (const RequestContext ctx, string key) => commentRow(
    ports.comments.getTaskComment(tenantOf(ctx), TaskCommentId(key)));
  comments.onCreate = (const RequestContext ctx, Json p) => commentRow(
    ports.comments.createTaskComment(createTaskCommentRequest(ctx, p)));
  comments.onUpdate = (const RequestContext ctx, string key, Json p) => commentRow(
    ports.comments.updateTaskComment(updateTaskCommentRequest(ctx, key, p)));
  comments.onRemove = (const RequestContext ctx, string key) {
    ports.comments.deleteTaskComment(tenantOf(ctx), TaskCommentId(key), actorOf(ctx), privilegedOf(ctx));
  };

  // ── Attachments ───────────────────────────────────────────────────────────
  auto attachments = new DelegateEntitySetProvider;
  attachments.onList = (const RequestContext ctx) {
    Json[] rows;
    foreach (e; ports.attachments.listTaskAttachments(tenantOf(ctx)))
      rows ~= attachmentRow(e);
    return rows;
  };
  attachments.onGet = (const RequestContext ctx, string key) => attachmentRow(
    ports.attachments.getTaskAttachment(tenantOf(ctx), TaskAttachmentId(key)));
  attachments.onCreate = (const RequestContext ctx, Json p) => attachmentRow(
    ports.attachments.createTaskAttachment(createTaskAttachmentRequest(ctx, p)));
  attachments.onUpdate = (const RequestContext ctx, string key, Json p) => attachmentRow(
    ports.attachments.updateTaskAttachment(updateTaskAttachmentRequest(ctx, key, p)));
  attachments.onRemove = (const RequestContext ctx, string key) {
    ports.attachments.deleteTaskAttachment(tenantOf(ctx), TaskAttachmentId(key));
  };

  // ── Action history (read only) ────────────────────────────────────────────
  auto actions = new DelegateEntitySetProvider;
  actions.onList = (const RequestContext ctx) {
    Json[] rows;
    foreach (e; ports.processing.listActions(tenantOf(ctx)))
      rows ~= actionRow(e);
    return rows;
  };
  actions.onGet = (const RequestContext ctx, string key) => actionRow(
    ports.processing.getAction(tenantOf(ctx), TaskActionId(key)));

  // ── Substitution rules ────────────────────────────────────────────────────
  auto substitutions = new DelegateEntitySetProvider;
  substitutions.onList = (const RequestContext ctx) {
    auto today = todayIso();
    Json[] rows;
    foreach (e; ports.substitutions.listSubstitutionRules(tenantOf(ctx)))
      rows ~= substitutionRow(e, today);
    return rows;
  };
  substitutions.onGet = (const RequestContext ctx, string key) => substitutionRow(
    ports.substitutions.getSubstitutionRule(tenantOf(ctx), SubstitutionRuleId(key)), todayIso());
  substitutions.onCreate = (const RequestContext ctx, Json p) => substitutionRow(
    ports.substitutions.createSubstitutionRule(createSubstitutionRuleRequest(ctx, p)), todayIso());
  substitutions.onUpdate = (const RequestContext ctx, string key, Json p) => substitutionRow(
    ports.substitutions.updateSubstitutionRule(updateSubstitutionRuleRequest(ctx, key, p)), todayIso());
  substitutions.onRemove = (const RequestContext ctx, string key) {
    ports.substitutions.deleteSubstitutionRule(tenantOf(ctx), SubstitutionRuleId(key), actorOf(ctx), privilegedOf(ctx));
  };

  // ── Saved filters ─────────────────────────────────────────────────────────
  auto filters = new DelegateEntitySetProvider;
  filters.onList = (const RequestContext ctx) {
    Json[] rows;
    foreach (e; ports.filters.listUserTaskFilters(tenantOf(ctx)))
      rows ~= filterRow(e, ctx.actor);
    return rows;
  };
  filters.onGet = (const RequestContext ctx, string key) => filterRow(
    ports.filters.getUserTaskFilter(tenantOf(ctx), UserTaskFilterId(key)), ctx.actor);
  filters.onCreate = (const RequestContext ctx, Json p) => filterRow(
    ports.filters.createUserTaskFilter(createUserTaskFilterRequest(ctx, p)), ctx.actor);
  filters.onUpdate = (const RequestContext ctx, string key, Json p) => filterRow(
    ports.filters.updateUserTaskFilter(updateUserTaskFilterRequest(ctx, key, p)), ctx.actor);
  filters.onRemove = (const RequestContext ctx, string key) {
    ports.filters.deleteUserTaskFilter(tenantOf(ctx), UserTaskFilterId(key), actorOf(ctx), privilegedOf(ctx));
  };

  // ── Statistics (singleton) ────────────────────────────────────────────────
  auto statistics = new DelegateEntitySetProvider;
  statistics.keyProperty = "tenantId";
  statistics.onGet = (const RequestContext ctx, string key) => statisticsRow(ports.statistics.compute(tenantOf(ctx)));

  engine.provide("Tasks", new PortProvider(tasks))
    .provide("TaskDefinitions", new PortProvider(definitions))
    .provide("TaskProviders", new PortProvider(providers))
    .provide("TaskComments", new PortProvider(comments))
    .provide("TaskAttachments", new PortProvider(attachments))
    .provide("TaskActions", new PortProvider(actions))
    .provide("SubstitutionRules", new PortProvider(substitutions))
    .provide("UserTaskFilters", new PortProvider(filters))
    .provide("Statistics", new PortProvider(statistics));

  // ── Actions ───────────────────────────────────────────────────────────────
  engine.handle("PerformTaskAction", (const RequestContext ctx, Json p) => translated!Json(
      () => taskRow(ports.processing.perform(performTaskActionRequest(ctx, p)).task, rowContext(ctx))));
  engine.handle("SyncProvider", (const RequestContext ctx, Json p) => translated!Json(() => syncResultRow(
      ports.sync.sync(tenantOf(ctx), TaskProviderId(textOf(p, "providerId")), actorOf(ctx)))));
  engine.handle("SyncAllProviders", (const RequestContext ctx, Json p) => translated!Json(() {
      auto rows = Json.emptyArray;
      foreach (r; ports.sync.syncAll(tenantOf(ctx), actorOf(ctx)))
        rows ~= syncResultRow(r);
      return rows;
    }));

  engine.maxPageSize = maxPageSize;
  engine.verify();
  return engine;
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Binds the EDM model to the driving ports. The resulting engine serves
/// the OData controller, the REST API, the CLI and the GUI.
module uim.platform.integration_automation.presentation.odata.engine;

import uim.platform.service.presentation.odata;
import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

/// IEntitySetProvider that translates IntegrationAutomationException.
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

/// A provider over a maintained resource port; rows(t, entities) builds the
/// rows of many entities at once (derived facts are computed once per call).
PortProvider resourceProvider(TEntity, TId, TInput, R)(IManageResource!(TEntity, TId, TInput) port, R rows) {
  auto p = new DelegateEntitySetProvider;
  p.onList = (const RequestContext ctx) => rows(tenantOf(ctx), port.list(tenantOf(ctx)));
  p.onGet = (const RequestContext ctx, string key) => rows(tenantOf(ctx), [port.get(tenantOf(ctx), TId(key))])[0];
  p.onCreate = (const RequestContext ctx, Json payload) => rows(tenantOf(ctx), [
    port.create(createCommandOf!TInput(ctx, payload))
  ])[0];
  p.onUpdate = (const RequestContext ctx, string key, Json payload) => rows(tenantOf(ctx), [
    port.update(updateCommandOf!TInput(ctx, key, payload))
  ])[0];
  p.onRemove = (const RequestContext ctx, string key) { port.remove(tenantOf(ctx), TId(key), actorOf(ctx)); };
  return new PortProvider(p);
}

ODataEngine integrationAutomationEngine(IaPorts ports, IClock clock, size_t maxPageSize = 0) {
  auto engine = new ODataEngine(integrationAutomationModel());

  // ── row builders with derived facts ─────────────────────────────────────
  string[string] systemNames(TenantId t) {
    string[string] names;
    foreach (s; ports.systems.list(t))
      names[s.id.value] = s.name;
    return names;
  }

  Json[] systemRows(TenantId t, SystemConnection[] systems) {
    long[string] destinations, open;
    foreach (d; ports.destinations.list(t))
      if (!d.systemId.isNull)
        destinations[d.systemId.value]++;
    foreach (w; ports.workflows.list(t))
      if (w.isOpen) {
        if (!w.sourceSystemId.isNull)
          open[w.sourceSystemId.value]++;
        if (!w.targetSystemId.isNull && w.targetSystemId != w.sourceSystemId)
          open[w.targetSystemId.value]++;
      }
    return systems.map!(s => systemRow(s, destinations.get(s.id.value, 0), open.get(s.id.value, 0))).array;
  }

  Json[] destinationRows(TenantId t, Destination[] destinations) {
    auto names = systemNames(t);
    long[string] templates;
    foreach (tpl; ports.scenarioTasks.list(t))
      if (!tpl.destinationId.isNull)
        templates[tpl.destinationId.value]++;
    return destinations.map!(d => destinationRow(d, names.get(d.systemId.value, ""), templates.get(d.id.value, 0))).array;
  }

  Json[] scenarioRows(TenantId t, IntegrationScenario[] scenarios) {
    ScenarioFacts[string] facts;
    foreach (tpl; ports.scenarioTasks.list(t)) {
      auto f = facts.get(tpl.scenarioId.value, ScenarioFacts.init);
      f.tasks++;
      f.estimatedMinutes += tpl.estimatedMinutes;
      facts[tpl.scenarioId.value] = f;
    }
    foreach (w; ports.workflows.list(t)) {
      auto f = facts.get(w.scenarioId.value, ScenarioFacts.init);
      f.workflows++;
      if (w.isOpen)
        f.openWorkflows++;
      facts[w.scenarioId.value] = f;
    }
    return scenarios.map!(s => scenarioRow(s, facts.get(s.id.value, ScenarioFacts.init))).array;
  }

  Json[] scenarioTaskRows(TenantId t, ScenarioTask[] templates) {
    ScenarioTask[][string] byScenario;
    foreach (tpl; ports.scenarioTasks.list(t))
      byScenario[tpl.scenarioId.value] ~= tpl;
    Json[] rows;
    foreach (tpl; templates) {
      auto siblings = byScenario.get(tpl.scenarioId.value, null);
      string[] names;
      foreach (d; templateDependencies(tpl, siblings)) {
        auto f = siblings.find!(o => o.id.value == d);
        names ~= f.empty ? d : f.front.name;
      }
      rows ~= scenarioTaskRow(tpl, names.join(", "));
    }
    return rows;
  }

  Json[] workflowRows(TenantId t, Workflow[] workflows) {
    string[string] scenarios;
    foreach (s; ports.scenarios.list(t))
      scenarios[s.id.value] = s.name;
    auto systems = systemNames(t);
    string[string] taskNames;
    foreach (w; workflows)
      if (!w.currentTaskId.isNull)
        taskNames[w.currentTaskId.value] = "";
    if (taskNames.length)
      foreach (task; ports.tasks.list(t))
        if (task.id.value in taskNames)
          taskNames[task.id.value] = task.name;
    return workflows.map!(w => workflowRow(w, WorkflowNames(scenarios.get(w.scenarioId.value, ""),
        systems.get(w.sourceSystemId.value, ""), systems.get(w.targetSystemId.value, ""),
        taskNames.get(w.currentTaskId.value, "")))).array;
  }

  Json[] taskRows(TenantId t, WorkflowTask[] selected) {
    Workflow[string] workflows;
    WorkflowTask[][string] siblings;
    foreach (task; selected)
      if (task.workflowId.value !in workflows) {
        workflows[task.workflowId.value] = ports.workflows.get(t, task.workflowId);
        siblings[task.workflowId.value] = ports.tasks.listOf(t, task.workflowId);
      }
    Json[] rows;
    foreach (task; selected) {
      auto wf = workflows[task.workflowId.value];
      auto all = siblings[task.workflowId.value];
      TaskFacts f;
      f.workflowName = wf.name;
      f.workflowStatus = cast(string) wf.status;
      f.ready = isReady(task, all) && (wf.status == WorkflowStatus.inProgress || wf.status == WorkflowStatus.failed);
      f.waitingFor = task.status == TaskStatus.pending ? openDependencies(task, all).map!(d => taskName(all, d)).join(", ") : "";
      rows ~= workflowTaskRow(task, f);
    }
    return rows;
  }

  // ── entity sets ─────────────────────────────────────────────────────────
  engine.provide("Systems", resourceProvider(
      cast(IManageResource!(SystemConnection, SystemConnectionId, SystemInput)) ports.systems, &systemRows));
  engine.provide("Destinations", resourceProvider(
      cast(IManageResource!(Destination, DestinationId, DestinationInput)) ports.destinations, &destinationRows));
  engine.provide("Scenarios", resourceProvider(
      cast(IManageResource!(IntegrationScenario, ScenarioId, ScenarioInput)) ports.scenarios, &scenarioRows));
  engine.provide("ScenarioTasks", resourceProvider(
      cast(IManageResource!(ScenarioTask, ScenarioTaskId, ScenarioTaskInput)) ports.scenarioTasks, &scenarioTaskRows));

  auto workflows = new DelegateEntitySetProvider;
  workflows.onList = (const RequestContext ctx) => workflowRows(tenantOf(ctx), ports.workflows.list(tenantOf(ctx)));
  workflows.onGet = (const RequestContext ctx, string key) => workflowRows(tenantOf(ctx), [
    ports.workflows.get(tenantOf(ctx), WorkflowId(key))
  ])[0];
  workflows.onCreate = (const RequestContext ctx, Json p) => workflowRows(tenantOf(ctx), [
    ports.workflows.create(createWorkflowCommand(ctx, p))
  ])[0];
  workflows.onUpdate = (const RequestContext ctx, string key, Json p) => workflowRows(tenantOf(ctx), [
    ports.workflows.update(updateWorkflowCommand(ctx, key, p))
  ])[0];
  workflows.onRemove = (const RequestContext ctx, string key) {
    ports.workflows.remove(tenantOf(ctx), WorkflowId(key), actorOf(ctx));
  };
  engine.provide("Workflows", new PortProvider(workflows));

  auto tasks = new DelegateEntitySetProvider;
  tasks.onList = (const RequestContext ctx) => taskRows(tenantOf(ctx), ports.tasks.list(tenantOf(ctx)));
  tasks.onGet = (const RequestContext ctx, string key) => taskRows(tenantOf(ctx), [
    ports.tasks.get(tenantOf(ctx), WorkflowTaskId(key))
  ])[0];
  tasks.onUpdate = (const RequestContext ctx, string key, Json p) {
    auto current = ports.tasks.get(tenantOf(ctx), WorkflowTaskId(key));
    auto assignee = has(p, "assignedTo") ? textOf(p, "assignedTo") : current.assignedTo;
    auto changed = ports.tasks.assign(tenantOf(ctx), current.id, assignee, textOf(p, "priority"), actorOf(ctx));
    return taskRows(tenantOf(ctx), [changed])[0];
  };
  engine.provide("WorkflowTasks", new PortProvider(tasks));

  auto logs = new DelegateEntitySetProvider;
  logs.onList = (const RequestContext ctx) => ports.executions.list(tenantOf(ctx)).map!(l => executionLogRow(l)).array;
  logs.onGet = (const RequestContext ctx, string key) => executionLogRow(ports.executions.get(tenantOf(ctx), ExecutionLogId(key)));
  engine.provide("ExecutionLogs", new PortProvider(logs));

  auto users = new DelegateEntitySetProvider;
  users.onList = (const RequestContext ctx) {
    auto now = clock.now;
    return ports.users.listUsers(tenantOf(ctx)).map!(u => userRow(u, now)).array;
  };
  users.onGet = (const RequestContext ctx, string key) => userRow(ports.users.getUser(tenantOf(ctx), UserAccountId(key)), clock.now);
  users.onCreate = (const RequestContext ctx, Json p) => userRow(ports.users.createUser(createUserRequest(ctx, p)), clock.now);
  users.onUpdate = (const RequestContext ctx, string key, Json p) => userRow(
    ports.users.updateUser(updateUserRequest(ctx, key, p)), clock.now);
  users.onRemove = (const RequestContext ctx, string key) {
    ports.users.deleteUser(tenantOf(ctx), UserAccountId(key), actorOf(ctx));
  };
  engine.provide("Users", new PortProvider(users));

  auto statistics = new DelegateEntitySetProvider;
  statistics.keyProperty = "tenantId";
  statistics.onGet = (const RequestContext ctx, string key) => statisticsRow(ports.statistics.compute(tenantOf(ctx), ctx.userId));
  engine.provide("Statistics", new PortProvider(statistics));

  // ── actions ─────────────────────────────────────────────────────────────
  void action(string name, Json delegate(const RequestContext, Json) @safe handler) {
    engine.handle(name, (const RequestContext ctx, Json p) => translated!Json(() => handler(ctx, p)));
  }

  Json workflowOne(const RequestContext ctx, Workflow w) {
    return workflowRows(tenantOf(ctx), [w])[0];
  }

  Json taskOne(const RequestContext ctx, WorkflowTask task) {
    return taskRows(tenantOf(ctx), [task])[0];
  }

  Json scenarioOne(const RequestContext ctx, IntegrationScenario s) {
    return scenarioRows(tenantOf(ctx), [s])[0];
  }

  action("TestSystemConnection", (ctx, p) => systemRows(tenantOf(ctx), [
      ports.systems.testConnection(tenantOf(ctx), SystemConnectionId(idParam(p)), actorOf(ctx))
    ])[0]);
  action("ActivateScenario", (ctx, p) => scenarioOne(ctx, ports.scenarios.activate(tenantOf(ctx), ScenarioId(idParam(p)), actorOf(ctx))));
  action("DeprecateScenario", (ctx, p) => scenarioOne(ctx, ports.scenarios.deprecate(tenantOf(ctx), ScenarioId(idParam(p)),
      actorOf(ctx))));
  action("ArchiveScenario", (ctx, p) => scenarioOne(ctx, ports.scenarios.archive(tenantOf(ctx), ScenarioId(idParam(p)), actorOf(ctx))));
  action("CopyScenario", (ctx, p) => scenarioOne(ctx, ports.scenarios.copy(tenantOf(ctx), ScenarioId(idParam(p)),
      textOf(p, "newId"), actorOf(ctx))));
  action("StartWorkflow", (ctx, p) => workflowOne(ctx, ports.workflows.start(tenantOf(ctx), WorkflowId(idParam(p)), actorOf(ctx))));
  action("SuspendWorkflow", (ctx, p) => workflowOne(ctx, ports.workflows.suspend(tenantOf(ctx), WorkflowId(idParam(p)), actorOf(ctx))));
  action("ResumeWorkflow", (ctx, p) => workflowOne(ctx, ports.workflows.resume(tenantOf(ctx), WorkflowId(idParam(p)), actorOf(ctx))));
  action("TerminateWorkflow", (ctx, p) => workflowOne(ctx, ports.workflows.terminate(tenantOf(ctx), WorkflowId(idParam(p)),
      textOf(p, "reason"), actorOf(ctx))));
  action("StartTask", (ctx, p) => taskOne(ctx, ports.tasks.start(tenantOf(ctx), WorkflowTaskId(idParam(p)), actorOf(ctx))));
  action("CompleteTask", (ctx, p) => taskOne(ctx, ports.tasks.complete(tenantOf(ctx), WorkflowTaskId(idParam(p)),
      textOf(p, "result"), actorOf(ctx))));
  action("FailTask", (ctx, p) => taskOne(ctx, ports.tasks.fail(tenantOf(ctx), WorkflowTaskId(idParam(p)),
      textOf(p, "errorMessage"), actorOf(ctx))));
  action("SkipTask", (ctx, p) => taskOne(ctx, ports.tasks.skip(tenantOf(ctx), WorkflowTaskId(idParam(p)), textOf(p, "reason"),
      actorOf(ctx))));
  action("RetryTask", (ctx, p) => taskOne(ctx, ports.tasks.retry(tenantOf(ctx), WorkflowTaskId(idParam(p)), actorOf(ctx))));
  action("AssignTask", (ctx, p) => taskOne(ctx, ports.tasks.assign(tenantOf(ctx), WorkflowTaskId(idParam(p)),
      textOf(p, "assignedTo"), textOf(p, "priority"), actorOf(ctx))));
  action("RunAutomatedTasks", (ctx, p) => automationRunRow(ports.tasks.runAutomation(tenantOf(ctx), actorOf(ctx),
      WorkflowId(textOf(p, "workflowId").strip))));
  action("PurgeExecutionLogs", (ctx, p) {
    auto days = cast(int) longOf(p, "olderThanDays");
    auto removed = ports.executions.purge(tenantOf(ctx), days, actorOf(ctx));
    return Json(["removed": Json(removed), "olderThanDays": Json(days)]);
  });
  action("SeedDemoData", (ctx, p) => seedRow(seedDemoData(ports, tenantOf(ctx), actorOf(ctx))));

  engine.maxPageSize = maxPageSize;
  engine.verify();
  return engine;
}

private string taskName(const WorkflowTask[] all, string id) {
  auto f = all.find!(x => x.id.value == id);
  return f.empty ? id : f.front.name;
}

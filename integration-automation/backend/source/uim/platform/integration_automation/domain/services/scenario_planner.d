/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Pure domain service that turns the task templates of a scenario into the
/// tasks of a new workflow: template dependencies (afterPrevious and
/// explicit dependsOn) become dependencies between the new tasks.
///
/// Rules: dependencies must point to templates of the same scenario with a
/// lower sequence number — the graph is therefore always acyclic and the
/// sequence order is a valid execution order.
module uim.platform.integration_automation.domain.services.scenario_planner;

import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

/// Template ids a template depends on (resolved afterPrevious + dependsOn).
string[] templateDependencies(const ScenarioTask t, const ScenarioTask[] all) {
  string[] deps;
  if (t.afterPrevious) {
    int previous = int.min;
    foreach (o; all)
      if (o.sequenceNumber < t.sequenceNumber && o.sequenceNumber > previous)
        previous = o.sequenceNumber;
    foreach (o; all)
      if (o.sequenceNumber == previous && !deps.canFind(o.id.value))
        deps ~= o.id.value;
  }
  foreach (d; t.dependsOn)
    if (!deps.canFind(d))
      deps ~= d;
  return deps;
}

/// Check the dependencies of one template against the others of its scenario.
void checkTemplateDependencies(const ScenarioTask t, const ScenarioTask[] others) {
  foreach (d; t.dependsOn) {
    auto dep = others.find!(o => o.id.value == d);
    if (dep.empty)
      throw IaException.invalid("Task template '" ~ d ~ "' (dependency of '" ~ t.id.value ~ "') is not part of scenario '"
          ~ t.scenarioId.value ~ "'");
    if (dep.front.sequenceNumber >= t.sequenceNumber)
      throw IaException.invalid(format("Task template '%s' (sequence %d) can only depend on templates with a lower sequence "
          ~ "number, not on '%s' (sequence %d)", t.id.value, t.sequenceNumber, d, dep.front.sequenceNumber));
  }
}

/// Tasks of a new workflow (ids from newId, dependencies mapped). Systems
/// are set where the template requires them.
WorkflowTask[] planTasks(const ScenarioTask[] templates, TenantId tenant, WorkflowId workflow,
  SystemConnectionId source, SystemConnectionId target, scope string delegate() @safe newId) @trusted {
  auto ordered = (cast(ScenarioTask[]) templates).dup;
  ordered.sort!((a, b) => a.sequenceNumber != b.sequenceNumber ? a.sequenceNumber < b.sequenceNumber : a.id.value < b.id.value);
  string[string] taskIdOf;
  foreach (t; ordered)
    taskIdOf[t.id.value] = newId();

  WorkflowTask[] tasks;
  foreach (t; ordered) {
    checkTemplateDependencies(t, ordered);
    WorkflowTask w;
    w.id = WorkflowTaskId(taskIdOf[t.id.value]);
    w.tenantId = tenant;
    w.workflowId = workflow;
    w.templateId = t.id;
    w.sequenceNumber = t.sequenceNumber;
    w.name = t.name;
    w.description = t.description;
    w.taskType = t.taskType;
    w.priority = t.priority;
    w.assignedRole = t.assignedRole;
    w.instructions = t.instructions;
    w.destinationId = t.destinationId;
    w.automationEndpoint = t.automationEndpoint;
    w.automationPayload = t.automationPayload;
    w.estimatedMinutes = t.estimatedMinutes;
    if (t.requiresSourceSystem)
      w.sourceSystemId = source;
    if (t.requiresTargetSystem)
      w.targetSystemId = target;
    foreach (d; templateDependencies(t, ordered))
      w.dependsOn ~= taskIdOf[d];
    tasks ~= w;
  }
  return tasks;
}

///
unittest {
  ScenarioTask tpl(string id, int seq, bool afterPrevious = true, string[] deps = null) {
    ScenarioTask t;
    t.id = ScenarioTaskId(id);
    t.scenarioId = ScenarioId("s");
    t.sequenceNumber = seq;
    t.afterPrevious = afterPrevious;
    t.dependsOn = deps;
    t.name = id;
    return t;
  }

  auto templates = [tpl("b", 20), tpl("a", 10), tpl("b2", 20), tpl("c", 30, false, ["a"])];
  assert(templateDependencies(templates[0], templates) == ["a"]);
  assert(templateDependencies(templates[1], templates).length == 0);
  assert(templateDependencies(templates[3], templates) == ["a"]);

  int n;
  auto tasks = planTasks(templates, TenantId("t"), WorkflowId("wf"), SystemConnectionId("src"), SystemConnectionId.init,
    () @safe { return "task-" ~ (++n).to!string; });
  assert(tasks.length == 4 && tasks[0].templateId.value == "a" && tasks[0].dependsOn.length == 0);
  assert(tasks[1].dependsOn == [tasks[0].id.value] && tasks[3].dependsOn == [tasks[0].id.value]);

  auto bad = tpl("x", 5, false, ["c"]);
  assert(failsWith(IaErrorKind.invalid, () { checkTemplateDependencies(bad, templates); }));
  auto unknown = tpl("y", 50, false, ["nope"]);
  assert(failsWith(IaErrorKind.invalid, () { checkTemplateDependencies(unknown, templates); }));
}

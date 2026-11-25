/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Commands and results of workflows and the automation.
module uim.platform.integration_automation.application.dtos.workflows;

import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

struct CreateWorkflowCommand {
  TenantId tenantId;
  UserId actor;
  string id; /// "" = generated
  string scenarioId;
  string name; /// "" = the scenario name
  string description;
  string sourceSystemId;
  string targetSystemId;
  bool start; /// start right away
}

struct UpdateWorkflowCommand {
  TenantId tenantId;
  UserId actor;
  string id;
  Patch!string name;
  Patch!string description;
}

/// Outcome of an automation run.
struct AutomationRunSummary {
  long workflows; /// running workflows looked at
  long executed; /// automated tasks executed
  long succeeded;
  long failed;
  long notified; /// notification tasks delivered
  string[] messages;

  void add(const AutomationRunSummary o) {
    workflows += o.workflows;
    executed += o.executed;
    succeeded += o.succeeded;
    failed += o.failed;
    notified += o.notified;
    messages ~= o.messages;
  }
}

/// What the demo content created.
struct SeedResult {
  long systems;
  long destinations;
  long scenarios;
  long scenarioTasks;
  long workflows;
  long workflowTasks;
}

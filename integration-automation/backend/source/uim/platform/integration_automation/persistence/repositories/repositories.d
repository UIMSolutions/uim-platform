/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Concrete repositories (driven port implementations).
module uim.platform.integration_automation.persistence.repositories.repositories;

import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

class SystemRepository : DocumentRepository!(SystemConnection, SystemConnectionId), ISystemRepository {
  this(IDocumentStore store) {
    super(store, Collections.systems);
  }
}

class DestinationRepository : DocumentRepository!(Destination, DestinationId), IDestinationRepository {
  this(IDocumentStore store) {
    super(store, Collections.destinations);
  }
}

class ScenarioRepository : DocumentRepository!(IntegrationScenario, ScenarioId), IScenarioRepository {
  this(IDocumentStore store) {
    super(store, Collections.scenarios);
  }
}

class ScenarioTaskRepository : DocumentRepository!(ScenarioTask, ScenarioTaskId), IScenarioTaskRepository {
  this(IDocumentStore store) {
    super(store, Collections.scenarioTasks);
  }
}

class WorkflowRepository : DocumentRepository!(Workflow, WorkflowId), IWorkflowRepository {
  this(IDocumentStore store) {
    super(store, Collections.workflows);
  }
}

class WorkflowTaskRepository : DocumentRepository!(WorkflowTask, WorkflowTaskId), IWorkflowTaskRepository {
  this(IDocumentStore store) {
    super(store, Collections.workflowTasks);
  }
}

class ExecutionLogRepository : DocumentRepository!(ExecutionLog, ExecutionLogId), IExecutionLogRepository {
  this(IDocumentStore store) {
    super(store, Collections.executionLogs);
  }
}

class UserAccountRepository : DocumentRepository!(UserAccount, UserAccountId), IUserAccountRepository {
  this(IDocumentStore store) {
    super(store, Collections.users);
  }
}

/// All repositories over one document store.
IaRepositories createRepositories(IDocumentStore store) {
  IaRepositories r;
  r.systems = new SystemRepository(store);
  r.destinations = new DestinationRepository(store);
  r.scenarios = new ScenarioRepository(store);
  r.scenarioTasks = new ScenarioTaskRepository(store);
  r.workflows = new WorkflowRepository(store);
  r.workflowTasks = new WorkflowTaskRepository(store);
  r.executionLogs = new ExecutionLogRepository(store);
  r.users = new UserAccountRepository(store);
  return r;
}

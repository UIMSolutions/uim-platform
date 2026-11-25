/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driven ports of the aggregates.
module uim.platform.integration_automation.ports.repositories.repositories;

import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

interface ISystemRepository : IIaRepository!(SystemConnection, SystemConnectionId) {
}

interface IDestinationRepository : IIaRepository!(Destination, DestinationId) {
}

interface IScenarioRepository : IIaRepository!(IntegrationScenario, ScenarioId) {
}

interface IScenarioTaskRepository : IIaRepository!(ScenarioTask, ScenarioTaskId) {
}

interface IWorkflowRepository : IIaRepository!(Workflow, WorkflowId) {
}

interface IWorkflowTaskRepository : IIaRepository!(WorkflowTask, WorkflowTaskId) {
}

interface IExecutionLogRepository : IIaRepository!(ExecutionLog, ExecutionLogId) {
}

interface IUserAccountRepository : IIaRepository!(UserAccount, UserAccountId) {
}

/// All repositories (passed to the interactors as one bundle).
struct IaRepositories {
  ISystemRepository systems;
  IDestinationRepository destinations;
  IScenarioRepository scenarios;
  IScenarioTaskRepository scenarioTasks;
  IWorkflowRepository workflows;
  IWorkflowTaskRepository workflowTasks;
  IExecutionLogRepository executionLogs;
  IUserAccountRepository users;
}

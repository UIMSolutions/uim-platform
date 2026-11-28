/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving ports of the ML life cycle: scenarios, configurations,
/// executions, deployments, the registry (models, datasets) and the
/// reconciliation with the runtime.
module uim.platform.ai_launchpad.ports.usecases.lifecycle;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

interface IManageScenarios : IManageResource!(Scenario, ScenarioId, ScenarioInput) {
}

interface IManageConfigurations : IManageResource!(Configuration, ConfigurationId, ConfigurationInput) {
}

interface IManageExecutions : IManageResource!(Execution, ExecutionId, ExecutionInput) {
  Execution stop(TenantId t, ExecutionId id, UserId actor);
}

interface IManageDeployments : IManageResource!(Deployment, DeploymentId, DeploymentInput) {
  Deployment stop(TenantId t, DeploymentId id, UserId actor);
  /// Restart a stopped or dead deployment.
  Deployment start(TenantId t, DeploymentId id, UserId actor);
}

interface IManageModels : IManageResource!(Model, ModelId, ModelInput) {
}

interface IManageDatasets : IManageResource!(Dataset, DatasetId, DatasetInput) {
}

interface IReconcileRuntime {
  /// Poll the runtime for the active executions and deployments of the
  /// tenant, apply their state changes and stop expired deployments.
  ReconcileSummary reconcile(TenantId t, UserId actor);
}

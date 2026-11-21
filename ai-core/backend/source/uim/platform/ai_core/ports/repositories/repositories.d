/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driven ports of the aggregates.
module uim.platform.ai_core.ports.repositories.repositories;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

interface IResourceGroupRepository : ITenantWideRepository!(ResourceGroup, ResourceGroupId) {
}

interface IScenarioRepository : IGroupRepository!(Scenario, ScenarioId) {
}

interface IExecutableRepository : IGroupRepository!(Executable, ExecutableId) {
  Executable[] findByScenario(TenantId t, ResourceGroupId rg, ScenarioId scenario);
}

interface IConfigurationRepository : IGroupRepository!(Configuration, ConfigurationId) {
  Configuration[] findByScenario(TenantId t, ResourceGroupId rg, ScenarioId scenario);
  Configuration[] findByExecutable(TenantId t, ResourceGroupId rg, ExecutableId executable);
}

interface IExecutionRepository : IGroupRepository!(Execution, ExecutionId) {
  Execution[] findByConfiguration(TenantId t, ResourceGroupId rg, ConfigurationId configuration);
}

interface IDeploymentRepository : IGroupRepository!(Deployment, DeploymentId) {
  Deployment[] findByConfiguration(TenantId t, ResourceGroupId rg, ConfigurationId configuration);
}

interface IArtifactRepository : IGroupRepository!(Artifact, ArtifactId) {
  Artifact[] findByScenario(TenantId t, ResourceGroupId rg, ScenarioId scenario);
  Artifact[] findByExecution(TenantId t, ResourceGroupId rg, ExecutionId execution);
}

interface IScheduleRepository : IGroupRepository!(ExecutionSchedule, ScheduleId) {
  ExecutionSchedule[] findByConfiguration(TenantId t, ResourceGroupId rg, ConfigurationId configuration);
}

interface IMetricRepository : IGroupRepository!(Metric, MetricId) {
  Metric[] findByExecution(TenantId t, ResourceGroupId rg, ExecutionId execution);
  size_t removeByExecution(TenantId t, ResourceGroupId rg, ExecutionId execution);
}

interface IDockerRegistrySecretRepository : ITenantWideRepository!(DockerRegistrySecret, DockerRegistrySecretId) {
}

interface IObjectStoreSecretRepository : IGroupRepository!(ObjectStoreSecret, ObjectStoreSecretId) {
}

/// All repositories (passed to the interactors as one bundle).
struct AiCoreRepositories {
  IResourceGroupRepository resourceGroups;
  IScenarioRepository scenarios;
  IExecutableRepository executables;
  IConfigurationRepository configurations;
  IExecutionRepository executions;
  IDeploymentRepository deployments;
  IArtifactRepository artifacts;
  IScheduleRepository schedules;
  IMetricRepository metrics;
  IDockerRegistrySecretRepository dockerSecrets;
  IObjectStoreSecretRepository objectStoreSecrets;
}

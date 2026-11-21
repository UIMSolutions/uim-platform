/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Concrete repositories (driven port implementations).
module uim.platform.ai_core.persistence.repositories.repositories;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

class ResourceGroupRepository : TenantDocumentRepository!(ResourceGroup, ResourceGroupId, resourceGroupToRecord,
  recordToResourceGroup), IResourceGroupRepository {
  this(IDocumentStore store) {
    super(store, Collections.resourceGroups);
  }
}

class ScenarioRepository : GroupDocumentRepository!(Scenario, ScenarioId, scenarioToRecord, recordToScenario), IScenarioRepository {
  this(IDocumentStore store) {
    super(store, Collections.scenarios);
  }
}

class ExecutableRepository : GroupDocumentRepository!(Executable, ExecutableId, executableToRecord, recordToExecutable),
IExecutableRepository {
  this(IDocumentStore store) {
    super(store, Collections.executables);
  }

  Executable[] findByScenario(TenantId t, ResourceGroupId rg, ScenarioId scenario) {
    return where(t, rg, (const Executable e) => e.scenarioId == scenario);
  }
}

class ConfigurationRepository : GroupDocumentRepository!(Configuration, ConfigurationId, configurationToRecord,
  recordToConfiguration), IConfigurationRepository {
  this(IDocumentStore store) {
    super(store, Collections.configurations);
  }

  Configuration[] findByScenario(TenantId t, ResourceGroupId rg, ScenarioId scenario) {
    return where(t, rg, (const Configuration e) => e.scenarioId == scenario);
  }

  Configuration[] findByExecutable(TenantId t, ResourceGroupId rg, ExecutableId executable) {
    return where(t, rg, (const Configuration e) => e.executableId == executable);
  }
}

class ExecutionRepository : GroupDocumentRepository!(Execution, ExecutionId, executionToRecord, recordToExecution),
IExecutionRepository {
  this(IDocumentStore store) {
    super(store, Collections.executions);
  }

  Execution[] findByConfiguration(TenantId t, ResourceGroupId rg, ConfigurationId configuration) {
    return where(t, rg, (const Execution e) => e.configurationId == configuration);
  }
}

class DeploymentRepository : GroupDocumentRepository!(Deployment, DeploymentId, deploymentToRecord, recordToDeployment),
IDeploymentRepository {
  this(IDocumentStore store) {
    super(store, Collections.deployments);
  }

  Deployment[] findByConfiguration(TenantId t, ResourceGroupId rg, ConfigurationId configuration) {
    return where(t, rg, (const Deployment e) => e.configurationId == configuration);
  }
}

class ArtifactRepository : GroupDocumentRepository!(Artifact, ArtifactId, artifactToRecord, recordToArtifact), IArtifactRepository {
  this(IDocumentStore store) {
    super(store, Collections.artifacts);
  }

  Artifact[] findByScenario(TenantId t, ResourceGroupId rg, ScenarioId scenario) {
    return where(t, rg, (const Artifact e) => e.scenarioId == scenario);
  }

  Artifact[] findByExecution(TenantId t, ResourceGroupId rg, ExecutionId execution) {
    return where(t, rg, (const Artifact e) => e.executionId == execution);
  }
}

class ScheduleRepository : GroupDocumentRepository!(ExecutionSchedule, ScheduleId, scheduleToRecord, recordToSchedule),
IScheduleRepository {
  this(IDocumentStore store) {
    super(store, Collections.schedules);
  }

  ExecutionSchedule[] findByConfiguration(TenantId t, ResourceGroupId rg, ConfigurationId configuration) {
    return where(t, rg, (const ExecutionSchedule e) => e.configurationId == configuration);
  }
}

class MetricRepository : GroupDocumentRepository!(Metric, MetricId, metricToRecord, recordToMetric), IMetricRepository {
  this(IDocumentStore store) {
    super(store, Collections.metrics);
  }

  Metric[] findByExecution(TenantId t, ResourceGroupId rg, ExecutionId execution) {
    return where(t, rg, (const Metric e) => e.executionId == execution);
  }

  size_t removeByExecution(TenantId t, ResourceGroupId rg, ExecutionId execution) {
    size_t removed;
    foreach (m; findByExecution(t, rg, execution))
      if (removeById(t, rg, m.id))
        removed++;
    return removed;
  }
}

class DockerRegistrySecretRepository : TenantDocumentRepository!(DockerRegistrySecret, DockerRegistrySecretId,
  dockerSecretToRecord, recordToDockerSecret), IDockerRegistrySecretRepository {
  this(IDocumentStore store) {
    super(store, Collections.dockerSecrets);
  }
}

class ObjectStoreSecretRepository : GroupDocumentRepository!(ObjectStoreSecret, ObjectStoreSecretId,
  objectStoreSecretToRecord, recordToObjectStoreSecret), IObjectStoreSecretRepository {
  this(IDocumentStore store) {
    super(store, Collections.objectStoreSecrets);
  }
}

/// All repositories over one document store.
AiCoreRepositories createRepositories(IDocumentStore store) {
  AiCoreRepositories r;
  r.resourceGroups = new ResourceGroupRepository(store);
  r.scenarios = new ScenarioRepository(store);
  r.executables = new ExecutableRepository(store);
  r.configurations = new ConfigurationRepository(store);
  r.executions = new ExecutionRepository(store);
  r.deployments = new DeploymentRepository(store);
  r.artifacts = new ArtifactRepository(store);
  r.schedules = new ScheduleRepository(store);
  r.metrics = new MetricRepository(store);
  r.dockerSecrets = new DockerRegistrySecretRepository(store);
  r.objectStoreSecrets = new ObjectStoreSecretRepository(store);
  return r;
}

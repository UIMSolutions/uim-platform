module uim.platform.xyz.infrastructure.container;

import uim.platform.xyz.infrastructure.config;

// Repositories
import uim.platform.xyz.infrastructure.persistence.memory.source_system_repo;
import uim.platform.xyz.infrastructure.persistence.memory.target_system_repo;
import uim.platform.xyz.infrastructure.persistence.memory.proxy_system_repo;
import uim.platform.xyz.infrastructure.persistence.memory.transformation_repo;
import uim.platform.xyz.infrastructure.persistence.memory.provisioning_job_repo;
import uim.platform.xyz.infrastructure.persistence.memory.provisioning_log_repo;
import uim.platform.xyz.infrastructure.persistence.memory.provisioned_entity_repo;

// Domain services
import uim.platform.xyz.domain.services.provisioning_engine;
import uim.platform.xyz.domain.services.transformation_engine;

// Use cases
import uim.platform.xyz.application.usecases.manage_source_systems;
import uim.platform.xyz.application.usecases.manage_target_systems;
import uim.platform.xyz.application.usecases.manage_proxy_systems;
import uim.platform.xyz.application.usecases.manage_transformations;
import uim.platform.xyz.application.usecases.run_provisioning_jobs;
import uim.platform.xyz.application.usecases.monitor_provisioning;

// Controllers
import uim.platform.xyz.presentation.http.source_system;
import uim.platform.xyz.presentation.http.target_system;
import uim.platform.xyz.presentation.http.proxy_system;
import uim.platform.xyz.presentation.http.transformation;
import uim.platform.xyz.presentation.http.provisioning_job;
import uim.platform.xyz.presentation.http.monitoring;
import uim.platform.xyz.presentation.http.health;

/// Dependency injection container - wires all layers together.
struct Container {
  // Repositories (driven adapters)
  MemorySourceSystemRepository sourceRepo;
  MemoryTargetSystemRepository targetRepo;
  MemoryProxySystemRepository proxyRepo;
  MemoryTransformationRepository transformRepo;
  MemoryProvisioningJobRepository jobRepo;
  MemoryProvisioningLogRepository logRepo;
  MemoryProvisionedEntityRepository entityRepo;

  // Domain services
  ProvisioningEngine provisioningEngine;
  TransformationEngine transformationEngine;

  // Use cases (application layer)
  ManageSourceSystemsUseCase manageSourceSystems;
  ManageTargetSystemsUseCase manageTargetSystems;
  ManageProxySystemsUseCase manageProxySystems;
  ManageTransformationsUseCase manageTransformations;
  RunProvisioningJobsUseCase runProvisioningJobs;
  MonitorProvisioningUseCase monitorProvisioning;

  // Controllers (driving adapters)
  SourceSystemController sourceSystemController;
  TargetSystemController targetSystemController;
  ProxySystemController proxySystemController;
  TransformationController transformationController;
  ProvisioningJobController provisioningJobController;
  MonitoringController monitoringController;
  HealthController healthController;
}

/// Build the full dependency graph.
Container buildContainer(AppConfig config) {
  Container c;

  // Infrastructure adapters
  c.sourceRepo = new MemorySourceSystemRepository();
  c.targetRepo = new MemoryTargetSystemRepository();
  c.proxyRepo = new MemoryProxySystemRepository();
  c.transformRepo = new MemoryTransformationRepository();
  c.jobRepo = new MemoryProvisioningJobRepository();
  c.logRepo = new MemoryProvisioningLogRepository();
  c.entityRepo = new MemoryProvisionedEntityRepository();

  // Domain services
  c.provisioningEngine = new ProvisioningEngine(
    c.sourceRepo, c.targetRepo, c.jobRepo, c.logRepo, c.entityRepo);
  c.transformationEngine = new TransformationEngine(c.transformRepo);

  // Application use cases
  c.manageSourceSystems = new ManageSourceSystemsUseCase(c.sourceRepo);
  c.manageTargetSystems = new ManageTargetSystemsUseCase(c.targetRepo);
  c.manageProxySystems = new ManageProxySystemsUseCase(c.proxyRepo, c.sourceRepo, c.targetRepo);
  c.manageTransformations = new ManageTransformationsUseCase(c.transformRepo, c
      .transformationEngine);
  c.runProvisioningJobs = new RunProvisioningJobsUseCase(
    c.jobRepo, c.sourceRepo, c.targetRepo, c.logRepo, c.provisioningEngine);
  c.monitorProvisioning = new MonitorProvisioningUseCase(
    c.jobRepo, c.logRepo, c.entityRepo, c.sourceRepo, c.targetRepo);

  // Presentation controllers
  c.sourceSystemController = new SourceSystemController(c.manageSourceSystems);
  c.targetSystemController = new TargetSystemController(c.manageTargetSystems);
  c.proxySystemController = new ProxySystemController(c.manageProxySystems);
  c.transformationController = new TransformationController(c.manageTransformations);
  c.provisioningJobController = new ProvisioningJobController(c.runProvisioningJobs);
  c.monitoringController = new MonitoringController(c.monitorProvisioning);
  c.healthController = new HealthController("identity-provisioning");

  return c;
}

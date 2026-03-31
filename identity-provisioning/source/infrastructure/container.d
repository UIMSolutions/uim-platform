module infrastructure.container;

import infrastructure.config;

// Repositories
import infrastructure.persistence.in_memory_source_system_repo;
import infrastructure.persistence.in_memory_target_system_repo;
import infrastructure.persistence.in_memory_proxy_system_repo;
import infrastructure.persistence.in_memory_transformation_repo;
import infrastructure.persistence.in_memory_provisioning_job_repo;
import infrastructure.persistence.in_memory_provisioning_log_repo;
import infrastructure.persistence.in_memory_provisioned_entity_repo;

// Domain services
import domain.services.provisioning_engine;
import domain.services.transformation_engine;

// Use cases
import application.usecases.manage_source_systems;
import application.usecases.manage_target_systems;
import application.usecases.manage_proxy_systems;
import application.usecases.manage_transformations;
import application.usecases.run_provisioning_jobs;
import application.usecases.monitor_provisioning;

// Controllers
import presentation.http.source_system_controller;
import presentation.http.target_system_controller;
import presentation.http.proxy_system_controller;
import presentation.http.transformation_controller;
import presentation.http.provisioning_job_controller;
import presentation.http.monitoring_controller;
import presentation.http.health_controller;

/// Dependency injection container - wires all layers together.
struct Container
{
  // Repositories (driven adapters)
  InMemorySourceSystemRepository sourceRepo;
  InMemoryTargetSystemRepository targetRepo;
  InMemoryProxySystemRepository proxyRepo;
  InMemoryTransformationRepository transformRepo;
  InMemoryProvisioningJobRepository jobRepo;
  InMemoryProvisioningLogRepository logRepo;
  InMemoryProvisionedEntityRepository entityRepo;

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
Container buildContainer(AppConfig config)
{
  Container c;

  // Infrastructure adapters
  c.sourceRepo = new InMemorySourceSystemRepository();
  c.targetRepo = new InMemoryTargetSystemRepository();
  c.proxyRepo = new InMemoryProxySystemRepository();
  c.transformRepo = new InMemoryTransformationRepository();
  c.jobRepo = new InMemoryProvisioningJobRepository();
  c.logRepo = new InMemoryProvisioningLogRepository();
  c.entityRepo = new InMemoryProvisionedEntityRepository();

  // Domain services
  c.provisioningEngine = new ProvisioningEngine(
    c.sourceRepo, c.targetRepo, c.jobRepo, c.logRepo, c.entityRepo);
  c.transformationEngine = new TransformationEngine(c.transformRepo);

  // Application use cases
  c.manageSourceSystems = new ManageSourceSystemsUseCase(c.sourceRepo);
  c.manageTargetSystems = new ManageTargetSystemsUseCase(c.targetRepo);
  c.manageProxySystems = new ManageProxySystemsUseCase(c.proxyRepo, c.sourceRepo, c.targetRepo);
  c.manageTransformations = new ManageTransformationsUseCase(c.transformRepo, c.transformationEngine);
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
  c.healthController = new HealthController();

  return c;
}

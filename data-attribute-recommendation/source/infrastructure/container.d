module infrastructure.container;

import infrastructure.config;

// Repositories
import infrastructure.persistence.memory.dataset_repo;
import infrastructure.persistence.memory.data_record_repo;
import infrastructure.persistence.memory.model_config_repo;
import infrastructure.persistence.memory.training_job_repo;
import infrastructure.persistence.memory.deployment_repo;
import infrastructure.persistence.memory.inference_request_repo;
import infrastructure.persistence.memory.inference_result_repo;

// Domain services
import domain.services.model_trainer;
import domain.services.inference_engine;

// Use cases
import application.usecases.manage_datasets;
import application.usecases.manage_data_records;
import application.usecases.manage_models;
import application.usecases.manage_deployments;
import application.usecases.process_inference;
import application.usecases.monitor_training;

// Controllers
import presentation.http.dataset;
import presentation.http.data_record;
import presentation.http.model;
import presentation.http.deployment;
import presentation.http.inference;
import presentation.http.monitoring;
import presentation.http.health;

/// Dependency injection container - wires all layers together.
struct Container
{
  // Repositories (driven adapters)
  InMemoryDatasetRepository datasetRepo;
  InMemoryDataRecordRepository recordRepo;
  InMemoryModelConfigRepository configRepo;
  InMemoryTrainingJobRepository jobRepo;
  InMemoryDeploymentRepository deploymentRepo;
  InMemoryInferenceRequestRepository inferenceRequestRepo;
  InMemoryInferenceResultRepository inferenceResultRepo;

  // Domain services
  ModelTrainer modelTrainer;
  InferenceEngine inferenceEngine;

  // Use cases (application layer)
  ManageDatasetsUseCase manageDatasets;
  ManageDataRecordsUseCase manageDataRecords;
  ManageModelsUseCase manageModels;
  ManageDeploymentsUseCase manageDeployments;
  ProcessInferenceUseCase processInference;
  MonitorTrainingUseCase monitorTraining;

  // Controllers (driving adapters)
  DatasetController datasetController;
  DataRecordController dataRecordController;
  ModelController modelController;
  DeploymentController deploymentController;
  InferenceController inferenceController;
  MonitoringController monitoringController;
  HealthController healthController;
}

/// Build the full dependency graph.
Container buildContainer(AppConfig config)
{
  Container c;

  // Infrastructure adapters
  c.datasetRepo = new MemoryDatasetRepository();
  c.recordRepo = new MemoryDataRecordRepository();
  c.configRepo = new MemoryModelConfigRepository();
  c.jobRepo = new MemoryTrainingJobRepository();
  c.deploymentRepo = new MemoryDeploymentRepository();
  c.inferenceRequestRepo = new MemoryInferenceRequestRepository();
  c.inferenceResultRepo = new MemoryInferenceResultRepository();

  // Domain services
  c.modelTrainer = new ModelTrainer(
    c.datasetRepo, c.configRepo, c.jobRepo, c.recordRepo);
  c.inferenceEngine = new InferenceEngine(
    c.deploymentRepo, c.inferenceRequestRepo, c.inferenceResultRepo);

  // Application use cases
  c.manageDatasets = new ManageDatasetsUseCase(c.datasetRepo, c.recordRepo);
  c.manageDataRecords = new ManageDataRecordsUseCase(c.recordRepo, c.datasetRepo);
  c.manageModels = new ManageModelsUseCase(c.configRepo, c.datasetRepo, c.modelTrainer);
  c.manageDeployments = new ManageDeploymentsUseCase(c.deploymentRepo, c.jobRepo, c.configRepo);
  c.processInference = new ProcessInferenceUseCase(
    c.inferenceRequestRepo, c.inferenceResultRepo, c.inferenceEngine);
  c.monitorTraining = new MonitorTrainingUseCase(
    c.jobRepo, c.deploymentRepo, c.configRepo, c.inferenceRequestRepo);

  // Presentation controllers
  c.datasetController = new DatasetController(c.manageDatasets);
  c.dataRecordController = new DataRecordController(c.manageDataRecords);
  c.modelController = new ModelController(c.manageModels);
  c.deploymentController = new DeploymentController(c.manageDeployments);
  c.inferenceController = new InferenceController(c.processInference);
  c.monitoringController = new MonitoringController(c.monitorTraining);
  c.healthController = new HealthController();

  return c;
}

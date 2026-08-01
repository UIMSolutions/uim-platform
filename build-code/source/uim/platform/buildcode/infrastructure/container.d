/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.infrastructure.container;

import uim.platform.buildcode;

mixin(ShowModule!());

@safe:

struct Container {
  // Repositories (driven adapters)
  IProjectRepository        projectRepo;
  IDevSpaceRepository       devSpaceRepo;
  ITemplateRepository       templateRepo;
  IPipelineRepository       pipelineRepo;
  IBuildJobRepository       buildJobRepo;
  IDeploymentRepository     deploymentRepo;
  IAIRequestRepository      aiRequestRepo;
  IServiceBindingRepository serviceBindingRepo;

  // Use cases (application layer)
  ManageProjectsUseCase        manageProjects;
  ManageDevSpacesUseCase       manageDevSpaces;
  ManageTemplatesUseCase       manageTemplates;
  ManagePipelinesUseCase       managePipelines;
  ManageBuildJobsUseCase       manageBuildJobs;
  ManageDeploymentsUseCase     manageDeployments;
  ManageAIRequestsUseCase      manageAIRequests;
  ManageServiceBindingsUseCase manageServiceBindings;

  // Controllers (driving adapters)
  ProjectController        projectController;
  DevSpaceController       devSpaceController;
  TemplateController       templateController;
  PipelineController       pipelineController;
  BuildJobController       buildJobController;
  DeploymentController     deploymentController;
  AIRequestController      aiRequestController;
  ServiceBindingController serviceBindingController;
  HealthController         healthController;
}

Container buildContainer(AppConfig config) @safe {
  Container c;

  // Repositories
  c.projectRepo        = new ProjectRepository();
  c.devSpaceRepo       = new DevSpaceRepository();
  c.templateRepo       = new TemplateRepository();
  c.pipelineRepo       = new PipelineRepository();
  c.buildJobRepo       = new BuildJobRepository();
  c.deploymentRepo     = new DeploymentRepository();
  c.aiRequestRepo      = new AIRequestRepository();
  c.serviceBindingRepo = new ServiceBindingRepository();

  // Use cases
  c.manageProjects        = new ManageProjectsUseCase(c.projectRepo);
  c.manageDevSpaces       = new ManageDevSpacesUseCase(c.devSpaceRepo);
  c.manageTemplates       = new ManageTemplatesUseCase(c.templateRepo);
  c.managePipelines       = new ManagePipelinesUseCase(c.pipelineRepo);
  c.manageBuildJobs       = new ManageBuildJobsUseCase(c.buildJobRepo, c.pipelineRepo);
  c.manageDeployments     = new ManageDeploymentsUseCase(c.deploymentRepo);
  c.manageAIRequests      = new ManageAIRequestsUseCase(c.aiRequestRepo);
  c.manageServiceBindings = new ManageServiceBindingsUseCase(c.serviceBindingRepo);

  // Controllers
  c.projectController        = new ProjectController(c.manageProjects);
  c.devSpaceController       = new DevSpaceController(c.manageDevSpaces);
  c.templateController       = new TemplateController(c.manageTemplates);
  c.pipelineController       = new PipelineController(c.managePipelines);
  c.buildJobController       = new BuildJobController(c.manageBuildJobs);
  c.deploymentController     = new DeploymentController(c.manageDeployments);
  c.aiRequestController      = new AIRequestController(c.manageAIRequests);
  c.serviceBindingController = new ServiceBindingController(c.manageServiceBindings);
  c.healthController         = new HealthController(config.serviceName, "2026.0.1", config.serviceDisplay);

  return c;
}

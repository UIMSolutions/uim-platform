/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.infrastructure.container;

import uim.platform.integration_delivery;

mixin(ShowModule!());

@safe:

struct Container {
    ManageCicdRepositoriesUseCase manageCicdRepositoriesUseCase;
    ManageCredentialsUseCase manageCredentialsUseCase;
    ManagePipelinesUseCase managePipelinesUseCase;
    ManageJobsUseCase manageJobsUseCase;
    ManageBuildsUseCase manageBuildsUseCase;
    ManageStagesUseCase manageStagesUseCase;
    ManageWebhooksUseCase manageWebhooksUseCase;
    ManageDeploymentTargetsUseCase manageDeploymentTargetsUseCase;

    CicdRepositoryController cicdRepositoryController;
    CredentialController credentialController;
    PipelineController pipelineController;
    JobController jobController;
    BuildController buildController;
    StageController stageController;
    WebhookController webhookController;
    DeploymentTargetController deploymentTargetController;
    HealthController healthController;
}

Container buildContainer(SrvConfig config) {
    Container c;

    // Repositories
    auto cicdRepositoryRepo = new CicdRepositoryRepository();
    auto credentialRepo = new CredentialRepository();
    auto pipelineRepo = new PipelineRepository();
    auto jobRepo = new JobRepository();
    auto buildRepo = new BuildRepository();
    auto stageRepo = new StageRepository();
    auto webhookRepo = new WebhookRepository();
    auto deploymentTargetRepo = new DeploymentTargetRepository();

    // Use Cases
    c.manageCicdRepositoriesUseCase = new ManageCicdRepositoriesUseCase(cicdRepositoryRepo);
    c.manageCredentialsUseCase = new ManageCredentialsUseCase(credentialRepo);
    c.managePipelinesUseCase = new ManagePipelinesUseCase(pipelineRepo);
    c.manageJobsUseCase = new ManageJobsUseCase(jobRepo);
    c.manageBuildsUseCase = new ManageBuildsUseCase(buildRepo);
    c.manageStagesUseCase = new ManageStagesUseCase(stageRepo);
    c.manageWebhooksUseCase = new ManageWebhooksUseCase(webhookRepo);
    c.manageDeploymentTargetsUseCase = new ManageDeploymentTargetsUseCase(deploymentTargetRepo);

    // Controllers
    c.cicdRepositoryController = new CicdRepositoryController(c.manageCicdRepositoriesUseCase);
    c.credentialController = new CredentialController(c.manageCredentialsUseCase);
    c.pipelineController = new PipelineController(c.managePipelinesUseCase);
    c.jobController = new JobController(c.manageJobsUseCase);
    c.buildController = new BuildController(c.manageBuildsUseCase);
    c.stageController = new StageController(c.manageStagesUseCase);
    c.webhookController = new WebhookController(c.manageWebhooksUseCase);
    c.deploymentTargetController = new DeploymentTargetController(c.manageDeploymentTargetsUseCase);
    c.healthController = new HealthController();

    return c;
}

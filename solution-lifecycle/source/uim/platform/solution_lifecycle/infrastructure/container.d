/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.solution_lifecycle.infrastructure.container;

import uim.platform.solution_lifecycle;

mixin(ShowModule!());

@safe:

struct Container {
    // Repositories (driven adapters)
    MemoryMtaArchiveRepository     mtaArchiveRepo;
    MemoryMtaRepository            mtaRepo;
    MemoryMtaOperationRepository   mtaOperationRepo;
    MemoryMtaSubscriptionRepository mtaSubscriptionRepo;

    // Domain services
    DeploymentEngine deploymentEngine;

    // Use cases (application layer)
    ManageMtaArchivesUseCase      manageMtaArchives;
    ManageMtasUseCase             manageMtas;
    ManageMtaOperationsUseCase    manageMtaOperations;
    ManageMtaSubscriptionsUseCase manageMtaSubscriptions;

    // Controllers (driving adapters)
    MtaArchiveController     mtaArchiveController;
    MtaController            mtaController;
    MtaOperationController   mtaOperationController;
    MtaSubscriptionController mtaSubscriptionController;
    HealthController         healthController;
}

Container buildContainer(SrvConfig config) {
    Container c;

    // Infrastructure adapters
    c.mtaArchiveRepo      = new MemoryMtaArchiveRepository();
    c.mtaRepo             = new MemoryMtaRepository();
    c.mtaOperationRepo    = new MemoryMtaOperationRepository();
    c.mtaSubscriptionRepo = new MemoryMtaSubscriptionRepository();

    // Domain services
    c.deploymentEngine = new DeploymentEngine();

    // Application use cases
    c.manageMtaArchives   = new ManageMtaArchivesUseCase(c.mtaArchiveRepo);
    c.manageMtas          = new ManageMtasUseCase(c.mtaRepo, c.mtaOperationRepo,
                                                   c.mtaArchiveRepo, c.deploymentEngine);
    c.manageMtaOperations = new ManageMtaOperationsUseCase(c.mtaOperationRepo, c.deploymentEngine);
    c.manageMtaSubscriptions = new ManageMtaSubscriptionsUseCase(
                                    c.mtaSubscriptionRepo, c.mtaOperationRepo, c.deploymentEngine);

    // Presentation controllers
    c.mtaArchiveController      = new MtaArchiveController(c.manageMtaArchives);
    c.mtaController             = new MtaController(c.manageMtas);
    c.mtaOperationController    = new MtaOperationController(c.manageMtaOperations);
    c.mtaSubscriptionController = new MtaSubscriptionController(c.manageMtaSubscriptions);
    c.healthController          = new HealthController("solution-lifecycle");

    return c;
}

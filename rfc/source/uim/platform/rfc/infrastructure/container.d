/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.rfc.infrastructure.container;

import uim.platform.rfc;

mixin(ShowModule!());
@safe:

struct Container {
    // Repositories (ports)
    DestinationRepository    destinationRepo;
    FunctionModuleRepository functionModuleRepo;
    RfcCallRepository        callRepo;
    TidRepository            tidRepo;
    RfcQueueRepository       queueRepo;

    // Use cases
    InvokeRfcUseCase             invokeRfc;
    ManageDestinationsUseCase    manageDestinations;
    ManageFunctionModulesUseCase manageFunctionModules;
    ManageCallsUseCase           manageCalls;
    ManageQueuesUseCase          manageQueues;

    // HTTP Controllers
    DestinationController    destinationController;
    FunctionModuleController functionModuleController;
    CallController           callController;
    QueueController          queueController;
    HealthController         healthController;
}

Container buildContainer(SrvConfig config) @trusted {
    Container c;

    // 1. Repositories
    c.destinationRepo    = new MemoryDestinationRepository();
    c.functionModuleRepo = new MemoryFunctionModuleRepository();
    c.callRepo           = new MemoryRfcCallRepository();
    c.tidRepo            = new MemoryTidRepository();
    c.queueRepo          = new MemoryRfcQueueRepository();

    // 2. Use cases
    c.invokeRfc            = new InvokeRfcUseCase(c.destinationRepo, c.functionModuleRepo,
                                                   c.callRepo, c.tidRepo, c.queueRepo);
    c.manageDestinations   = new ManageDestinationsUseCase(c.destinationRepo);
    c.manageFunctionModules = new ManageFunctionModulesUseCase(c.functionModuleRepo);
    c.manageCalls          = new ManageCallsUseCase(c.callRepo);
    c.manageQueues         = new ManageQueuesUseCase(c.queueRepo, c.callRepo, c.destinationRepo,
                                                      c.functionModuleRepo, c.tidRepo);

    // 3. Controllers
    c.destinationController    = new DestinationController(c.manageDestinations);
    c.functionModuleController = new FunctionModuleController(c.manageFunctionModules);
    c.callController           = new CallController(c.invokeRfc, c.manageCalls);
    c.queueController          = new QueueController(c.manageQueues);
    c.healthController         = new HealthController();

    return c;
}

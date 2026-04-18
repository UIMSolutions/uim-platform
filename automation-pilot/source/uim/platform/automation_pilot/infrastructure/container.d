/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.infrastructure.container;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

struct Container {
    ManageCatalogsUseCase manageCatalogsUseCase;
    ManageCommandsUseCase manageCommandsUseCase;
    ManageCommandInputsUseCase manageCommandInputsUseCase;
    ManageExecutionsUseCase manageExecutionsUseCase;
    ManageScheduledExecutionsUseCase manageScheduledExecutionsUseCase;
    ManageTriggersUseCase manageTriggersUseCase;
    ManageServiceAccountsUseCase manageServiceAccountsUseCase;
    ManageContentConnectorsUseCase manageContentConnectorsUseCase;

    CatalogController catalogController;
    CommandController commandController;
    CommandInputController commandInputController;
    ExecutionController executionController;
    ScheduledExecutionController scheduledExecutionController;
    TriggerController triggerController;
    ServiceAccountController serviceAccountController;
    ContentConnectorController contentConnectorController;
    HealthController healthController;
}

Container buildContainer(AppConfig config) {
    Container c;

    // Repositories
    auto catalogRepo = new MemoryCatalogRepository();
    auto commandRepo = new MemoryCommandRepository();
    auto commandInputRepo = new MemoryCommandInputRepository();
    auto executionRepo = new MemoryExecutionRepository();
    auto scheduledExecutionRepo = new MemoryScheduledExecutionRepository();
    auto triggerRepo = new MemoryTriggerRepository();
    auto serviceAccountRepo = new MemoryServiceAccountRepository();
    auto contentConnectorRepo = new MemoryContentConnectorRepository();

    // Use Cases
    c.manageCatalogsUseCase = new ManageCatalogsUseCase(catalogRepo);
    c.manageCommandsUseCase = new ManageCommandsUseCase(commandRepo);
    c.manageCommandInputsUseCase = new ManageCommandInputsUseCase(commandInputRepo);
    c.manageExecutionsUseCase = new ManageExecutionsUseCase(executionRepo);
    c.manageScheduledExecutionsUseCase = new ManageScheduledExecutionsUseCase(scheduledExecutionRepo);
    c.manageTriggersUseCase = new ManageTriggersUseCase(triggerRepo);
    c.manageServiceAccountsUseCase = new ManageServiceAccountsUseCase(serviceAccountRepo);
    c.manageContentConnectorsUseCase = new ManageContentConnectorsUseCase(contentConnectorRepo);

    // Controllers
    c.catalogController = new CatalogController(c.manageCatalogsUseCase);
    c.commandController = new CommandController(c.manageCommandsUseCase);
    c.commandInputController = new CommandInputController(c.manageCommandInputsUseCase);
    c.executionController = new ExecutionController(c.manageExecutionsUseCase);
    c.scheduledExecutionController = new ScheduledExecutionController(c.manageScheduledExecutionsUseCase);
    c.triggerController = new TriggerController(c.manageTriggersUseCase);
    c.serviceAccountController = new ServiceAccountController(c.manageServiceAccountsUseCase);
    c.contentConnectorController = new ContentConnectorController(c.manageContentConnectorsUseCase);
    c.healthController = new HealthController();

    return c;
}

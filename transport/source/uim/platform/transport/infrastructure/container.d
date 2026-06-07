/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.infrastructure.container;

import uim.platform.transport;

// mixin(ShowModule!());

@safe:

struct Container {
    ManageTransportNodesUseCase manageNodesUseCase;
    ManageTransportRoutesUseCase manageRoutesUseCase;
    ManageTransportRequestsUseCase manageRequestsUseCase;
    ManageImportQueueEntriesUseCase manageQueueEntriesUseCase;
    ManageTransportActionsUseCase manageActionsUseCase;

    TransportNodeController nodeController;
    TransportRouteController routeController;
    TransportRequestController requestController;
    ImportQueueEntryController queueEntryController;
    TransportActionController actionController;
    HealthController healthController;
}

Container buildContainer(SrvConfig config) {
    Container c;

    // Repositories (in-memory adapters)
    auto nodeRepo = new MemoryTransportNodeRepository();
    auto routeRepo = new MemoryTransportRouteRepository();
    auto requestRepo = new MemoryTransportRequestRepository();
    auto queueEntryRepo = new MemoryImportQueueEntryRepository();
    auto actionRepo = new MemoryTransportActionRepository();

    // Use Cases
    c.manageNodesUseCase = new ManageTransportNodesUseCase(nodeRepo);
    c.manageRoutesUseCase = new ManageTransportRoutesUseCase(routeRepo);
    c.manageRequestsUseCase = new ManageTransportRequestsUseCase(requestRepo);
    c.manageQueueEntriesUseCase = new ManageImportQueueEntriesUseCase(queueEntryRepo);
    c.manageActionsUseCase = new ManageTransportActionsUseCase(actionRepo);

    // Controllers
    c.nodeController = new TransportNodeController(c.manageNodesUseCase);
    c.routeController = new TransportRouteController(c.manageRoutesUseCase);
    c.requestController = new TransportRequestController(c.manageRequestsUseCase);
    c.queueEntryController = new ImportQueueEntryController(c.manageQueueEntriesUseCase);
    c.actionController = new TransportActionController(c.manageActionsUseCase);
    c.healthController = new HealthController();

    return c;
}

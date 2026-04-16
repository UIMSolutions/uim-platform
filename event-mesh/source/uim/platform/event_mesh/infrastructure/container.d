/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.infrastructure.container;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

struct Container {
    ManageBrokerServicesUseCase manageBrokerServicesUseCase;
    ManageQueuesUseCase manageQueuesUseCase;
    ManageTopicsUseCase manageTopicsUseCase;
    ManageSubscriptionsUseCase manageSubscriptionsUseCase;
    ManageEventMessagesUseCase manageEventMessagesUseCase;
    ManageEventSchemasUseCase manageEventSchemasUseCase;
    ManageEventApplicationsUseCase manageEventApplicationsUseCase;
    ManageMeshBridgesUseCase manageMeshBridgesUseCase;

    BrokerServiceController brokerServiceController;
    QueueController queueController;
    TopicController topicController;
    SubscriptionController subscriptionController;
    EventMessageController eventMessageController;
    EventSchemaController eventSchemaController;
    EventApplicationController eventApplicationController;
    MeshBridgeController meshBridgeController;
    HealthController healthController;
}

Container buildContainer(AppConfig config) {
    Container c;

    // Repositories
    auto brokerServiceRepo = new MemoryBrokerServiceRepository();
    auto queueRepo = new MemoryQueueRepository();
    auto topicRepo = new MemoryTopicRepository();
    auto subscriptionRepo = new MemorySubscriptionRepository();
    auto eventMessageRepo = new MemoryEventMessageRepository();
    auto eventSchemaRepo = new MemoryEventSchemaRepository();
    auto eventApplicationRepo = new MemoryEventApplicationRepository();
    auto meshBridgeRepo = new MemoryMeshBridgeRepository();

    // Use Cases
    c.manageBrokerServicesUseCase = new ManageBrokerServicesUseCase(brokerServiceRepo);
    c.manageQueuesUseCase = new ManageQueuesUseCase(queueRepo);
    c.manageTopicsUseCase = new ManageTopicsUseCase(topicRepo);
    c.manageSubscriptionsUseCase = new ManageSubscriptionsUseCase(subscriptionRepo);
    c.manageEventMessagesUseCase = new ManageEventMessagesUseCase(eventMessageRepo);
    c.manageEventSchemasUseCase = new ManageEventSchemasUseCase(eventSchemaRepo);
    c.manageEventApplicationsUseCase = new ManageEventApplicationsUseCase(eventApplicationRepo);
    c.manageMeshBridgesUseCase = new ManageMeshBridgesUseCase(meshBridgeRepo);

    // Controllers
    c.brokerServiceController = new BrokerServiceController(c.manageBrokerServicesUseCase);
    c.queueController = new QueueController(c.manageQueuesUseCase);
    c.topicController = new TopicController(c.manageTopicsUseCase);
    c.subscriptionController = new SubscriptionController(c.manageSubscriptionsUseCase);
    c.eventMessageController = new EventMessageController(c.manageEventMessagesUseCase);
    c.eventSchemaController = new EventSchemaController(c.manageEventSchemasUseCase);
    c.eventApplicationController = new EventApplicationController(c.manageEventApplicationsUseCase);
    c.meshBridgeController = new MeshBridgeController(c.manageMeshBridgesUseCase);
    c.healthController = new HealthController();

    return c;
}

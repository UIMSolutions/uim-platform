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
    ODataBrokerServiceController odataBrokerServiceController;
    ODataQueueController odataQueueController;
    ODataTopicController odataTopicController;
    ODataSubscriptionController odataSubscriptionController;
    ODataEventMessageController odataEventMessageController;
    ODataEventSchemaController odataEventSchemaController;
    ODataEventApplicationController odataEventApplicationController;
    ODataMeshBridgeController odataMeshBridgeController;
    WebBrokerServiceController webBrokerServiceController;
    WebQueueController webQueueController;
    WebTopicController webTopicController;
    WebSubscriptionController webSubscriptionController;
    WebEventMessageController webEventMessageController;
    WebEventSchemaController webEventSchemaController;
    WebEventApplicationController webEventApplicationController;
    WebMeshBridgeController webMeshBridgeController;
    HealthController healthController;
}

Container buildContainer(SrvConfig config) {
    Container c;

    // Repositories
    IBrokerServiceRepository brokerServiceRepo;
    QueueRepository queueRepo;
    TopicRepository topicRepo;
    SubscriptionRepository subscriptionRepo;
    EventMessageRepository eventMessageRepo;
    EventSchemaRepository eventSchemaRepo;
    EventApplicationRepository eventApplicationRepo;
    MeshBridgeRepository meshBridgeRepo;

    if (config.repositoryBackend == "file") {
        brokerServiceRepo = new FileBrokerServiceRepository(config.fileRepositoryBasePath);
        queueRepo = new FileQueueRepository(config.fileRepositoryBasePath);
        topicRepo = new FileTopicRepository(config.fileRepositoryBasePath);
        subscriptionRepo = new FileSubscriptionRepository(config.fileRepositoryBasePath);
        eventMessageRepo = new FileEventMessageRepository(config.fileRepositoryBasePath);
        eventSchemaRepo = new FileEventSchemaRepository(config.fileRepositoryBasePath);
        eventApplicationRepo = new FileEventApplicationRepository(config.fileRepositoryBasePath);
        meshBridgeRepo = new FileMeshBridgeRepository(config.fileRepositoryBasePath);
    } else {
        brokerServiceRepo = new MemoryBrokerServiceRepository();
        queueRepo = new MemoryQueueRepository();
        topicRepo = new MemoryTopicRepository();
        subscriptionRepo = new MemorySubscriptionRepository();
        eventMessageRepo = new MemoryEventMessageRepository();
        eventSchemaRepo = new MemoryEventSchemaRepository();
        eventApplicationRepo = new MemoryEventApplicationRepository();
        meshBridgeRepo = new MemoryMeshBridgeRepository();
    }

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
    c.odataBrokerServiceController = new ODataBrokerServiceController(c.manageBrokerServicesUseCase);
    c.odataQueueController = new ODataQueueController(c.manageQueuesUseCase);
    c.odataTopicController = new ODataTopicController(c.manageTopicsUseCase);
    c.odataSubscriptionController = new ODataSubscriptionController(c.manageSubscriptionsUseCase);
    c.odataEventMessageController = new ODataEventMessageController(c.manageEventMessagesUseCase);
    c.odataEventSchemaController = new ODataEventSchemaController(c.manageEventSchemasUseCase);
    c.odataEventApplicationController = new ODataEventApplicationController(c.manageEventApplicationsUseCase);
    c.odataMeshBridgeController = new ODataMeshBridgeController(c.manageMeshBridgesUseCase);
    c.webBrokerServiceController = new WebBrokerServiceController(
        new WebBrokerServiceModel(c.manageBrokerServicesUseCase),
        new WebBrokerServiceView());
    c.webQueueController = new WebQueueController(
        new WebQueueModel(c.manageQueuesUseCase),
        new WebQueueView());
    c.webTopicController = new WebTopicController(
        new WebTopicModel(c.manageTopicsUseCase),
        new WebTopicView());
    c.webSubscriptionController = new WebSubscriptionController(
        new WebSubscriptionModel(c.manageSubscriptionsUseCase),
        new WebSubscriptionView());
    c.webEventMessageController = new WebEventMessageController(
        new WebEventMessageModel(c.manageEventMessagesUseCase),
        new WebEventMessageView());
    c.webEventSchemaController = new WebEventSchemaController(
        new WebEventSchemaModel(c.manageEventSchemasUseCase),
        new WebEventSchemaView());
    c.webEventApplicationController = new WebEventApplicationController(
        new WebEventApplicationModel(c.manageEventApplicationsUseCase),
        new WebEventApplicationView());
    c.webMeshBridgeController = new WebMeshBridgeController(
        new WebMeshBridgeModel(c.manageMeshBridgesUseCase),
        new WebMeshBridgeView());
    c.healthController = new HealthController();

    return c;
}

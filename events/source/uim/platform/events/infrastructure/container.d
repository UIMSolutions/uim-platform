/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.infrastructure.container;

import uim.platform.events;

mixin(ShowModule!());

@safe:

struct Container {
    // Use cases
    ManageMessagingServicesUseCase messagingServicesUseCase;
    ManageMessageClientsUseCase messageClientsUseCase;
    ManageQueuesUseCase queuesUseCase;
    ManageQueueSubscriptionsUseCase queueSubscriptionsUseCase;
    ManageWebhooksUseCase webhooksUseCase;
    ManageEventChannelsUseCase eventChannelsUseCase;
    ManageMessageBindingsUseCase messageBindingsUseCase;

    // Controllers
    MessagingServiceController messagingServiceController;
    MessageClientController messageClientController;
    QueueController queueController;
    QueueSubscriptionController queueSubscriptionController;
    WebhookController webhookController;
    EventChannelController eventChannelController;
    MessageBindingController messageBindingController;
    HealthController healthController;
}

Container buildContainer(SrvConfig config) {
    Container c;

    // Repositories
    auto messagingServiceRepo = new MemoryMessagingServiceRepository();
    auto messageClientRepo    = new MemoryMessageClientRepository();
    auto queueRepo            = new MemoryQueueRepository();
    auto queueSubRepo         = new MemoryQueueSubscriptionRepository();
    auto webhookRepo          = new MemoryWebhookRepository();
    auto eventChannelRepo     = new MemoryEventChannelRepository();
    auto messageBindingRepo   = new MemoryMessageBindingRepository();

    // Use Cases
    c.messagingServicesUseCase   = new ManageMessagingServicesUseCase(messagingServiceRepo);
    c.messageClientsUseCase      = new ManageMessageClientsUseCase(messageClientRepo);
    c.queuesUseCase              = new ManageQueuesUseCase(queueRepo);
    c.queueSubscriptionsUseCase  = new ManageQueueSubscriptionsUseCase(queueSubRepo);
    c.webhooksUseCase            = new ManageWebhooksUseCase(webhookRepo);
    c.eventChannelsUseCase       = new ManageEventChannelsUseCase(eventChannelRepo);
    c.messageBindingsUseCase     = new ManageMessageBindingsUseCase(messageBindingRepo);

    // Controllers
    c.messagingServiceController  = new MessagingServiceController(c.messagingServicesUseCase);
    c.messageClientController     = new MessageClientController(c.messageClientsUseCase);
    c.queueController             = new QueueController(c.queuesUseCase);
    c.queueSubscriptionController = new QueueSubscriptionController(c.queueSubscriptionsUseCase);
    c.webhookController           = new WebhookController(c.webhooksUseCase);
    c.eventChannelController      = new EventChannelController(c.eventChannelsUseCase);
    c.messageBindingController    = new MessageBindingController(c.messageBindingsUseCase);
    c.healthController            = new HealthController("SAP Event Mesh Service");

    return c;
}

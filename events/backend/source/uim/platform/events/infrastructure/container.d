/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Composition root shared by the server, the CLI and the GUI.
module uim.platform.events.infrastructure.container;

import uim.platform.events;
import uim.platform.events.presentation.odata.engine : eventsEngine;
import uim.platform.service.presentation.odata.engine : ODataEngine;

mixin(ShowModule!());

@safe:

class EventsContainer {
  EventsConfig config;
  IDocumentStore store;
  IWebhookEndpointGateway gateway;
  EventsPorts ports;
  ODataEngine engine; /// drives OData, REST, CLI and GUI

  /// gateway / store may be injected (tests); defaults follow the configuration.
  this(EventsConfig config, IWebhookEndpointGateway gateway = null, IDocumentStore store = null) {
    this.config = config;
    this.store = store !is null ? store : createDocumentStore(config.storage, config.dataFile);
    this.gateway = gateway !is null ? gateway : new HttpWebhookClient(config.webhookTimeoutSeconds);

    // driven adapters
    auto services = new MessagingServiceRepository(this.store);
    auto clients = new MessageClientRepository(this.store);
    auto queues = new QueueRepository(this.store);
    auto subscriptions = new QueueSubscriptionRepository(this.store);
    auto webhooks = new WebhookRepository(this.store);
    auto channels = new EventChannelRepository(this.store);
    auto bindings = new MessageBindingRepository(this.store);
    auto messages = new QueueMessageRepository(this.store);

    // application
    ports.services = new ManageMessagingServicesUseCase(services, clients, queues, channels);
    ports.clients = new ManageMessageClientsUseCase(clients, services, bindings);
    ports.queues = new ManageQueuesUseCase(queues, services, subscriptions, webhooks, bindings, messages);
    ports.subscriptions = new ManageQueueSubscriptionsUseCase(subscriptions, queues, services);
    ports.webhooks = new ManageWebhooksUseCase(webhooks, queues);
    ports.channels = new ManageEventChannelsUseCase(channels, services, bindings);
    ports.bindings = new ManageMessageBindingsUseCase(bindings, clients, queues, channels);
    ports.publisher = new PublishEventsUseCase(services, clients, bindings, channels, subscriptions, queues, messages);
    ports.consumer = new ConsumeMessagesUseCase(messages, queues, clients, bindings);
    ports.delivery = new DeliverWebhooksUseCase(webhooks, queues, messages, this.gateway);
    ports.statistics = new EventsStatisticsService(services, clients, queues, subscriptions, webhooks, channels, bindings, messages);

    // one engine for all driving adapters
    engine = eventsEngine(ports, config.maxPageSize);
  }
}

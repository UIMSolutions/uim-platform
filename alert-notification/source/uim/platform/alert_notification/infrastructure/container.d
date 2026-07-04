/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.alert_notification.infrastructure.container;

import uim.platform.alert_notification;

mixin(ShowModule!());

@safe:

/// Dependency-injection container — wires all layers together.
struct Container {
    // Repositories
    MemoryConditionRepository     conditionRepo;
    MemoryActionRepository        actionRepo;
    MemorySubscriptionRepository  subscriptionRepo;
    MemoryMatchedEventRepository  matchedEventRepo;
    MemoryUndeliveredEventRepository undeliveredEventRepo;

    // Domain services
    EventMatcher    matcher;
    EventDispatcher dispatcher;

    // Application use cases
    ManageConditionsUseCase     manageConditions;
    ManageActionsUseCase        manageActions;
    ManageSubscriptionsUseCase  manageSubscriptions;
    ProduceEventsUseCase        produceEvents;
    ConsumeMatchedEventsUseCase    consumeMatchedEvents;
    ConsumeUndeliveredEventsUseCase consumeUndeliveredEvents;

    // HTTP controllers
    ConditionController     conditionController;
    ActionController        actionController;
    SubscriptionController  subscriptionController;
    AlertEventController    alertEventController;
    MatchedEventController  matchedEventController;
    UndeliveredEventController undeliveredEventController;
}

Container buildContainer(SrvConfig cfg) @safe {
    Container c;

    // Repositories
    c.conditionRepo        = new MemoryConditionRepository();
    c.actionRepo           = new MemoryActionRepository();
    c.subscriptionRepo     = new MemorySubscriptionRepository();
    c.matchedEventRepo     = new MemoryMatchedEventRepository();
    c.undeliveredEventRepo = new MemoryUndeliveredEventRepository();

    // Domain services
    c.matcher    = new EventMatcher();
    c.dispatcher = new EventDispatcher();

    // Use cases
    c.manageConditions    = new ManageConditionsUseCase(c.conditionRepo);
    c.manageActions       = new ManageActionsUseCase(c.actionRepo);
    c.manageSubscriptions = new ManageSubscriptionsUseCase(c.subscriptionRepo);
    c.produceEvents       = new ProduceEventsUseCase(
        c.subscriptionRepo, c.conditionRepo, c.actionRepo,
        c.matchedEventRepo, c.undeliveredEventRepo,
        c.matcher, c.dispatcher
    );
    c.consumeMatchedEvents    = new ConsumeMatchedEventsUseCase(c.matchedEventRepo);
    c.consumeUndeliveredEvents = new ConsumeUndeliveredEventsUseCase(c.undeliveredEventRepo);

    // HTTP controllers
    c.conditionController     = new ConditionController(c.manageConditions);
    c.actionController        = new ActionController(c.manageActions);
    c.subscriptionController  = new SubscriptionController(c.manageSubscriptions);
    c.alertEventController    = new AlertEventController(c.produceEvents);
    c.matchedEventController  = new MatchedEventController(c.consumeMatchedEvents);
    c.undeliveredEventController = new UndeliveredEventController(c.consumeUndeliveredEvents);

    return c;
}

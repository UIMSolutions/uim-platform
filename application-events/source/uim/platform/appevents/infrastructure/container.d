/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.infrastructure.container;

// import uim.platform.service;
// import uim.platform.appevents.application.usecases.manage;
// import uim.platform.appevents.infrastructure.config;
// import uim.platform.appevents.infrastructure.persistence.memory;
// import uim.platform.appevents.infrastructure.persistence.file;
// import uim.platform.appevents.infrastructure.persistence.mongodb;
// import uim.platform.appevents.presentation.http.controllers;

import uim.platform.appevents;

// mixin(ShowModule!());

@safe:


struct Container {
    ManageEventSubscriptionsUseCase  eventSubscriptions;
    ManageEventTopicsUseCase         eventTopics;
    ManageEventChannelsUseCase       eventChannels;
    ManageEventMessagesUseCase       eventMessages;
    ManageEventFiltersUseCase        eventFilters;
    ManageDeadLetterEntriesUseCase   deadLetterEntries;
    ManageFormationsUseCase          formations;
    ManageSystemRegistrationsUseCase systemRegistrations;

    EventSubscriptionController  subscriptionCtrl;
    EventTopicController         topicCtrl;
    EventChannelController       channelCtrl;
    EventMessageController       messageCtrl;
    EventFilterController        filterCtrl;
    DeadLetterEntryController    deadLetterCtrl;
    FormationController          formationCtrl;
    SystemRegistrationController systemCtrl;
    HealthController             healthCtrl;
}

Container buildContainer(SrvConfig config) @trusted {
    import vibe.db.mongo.mongo : connectMongoDB;

    Container c;

    final switch (config.persistence) {
        case "file": {
            auto subscriptionRepo    = new FileEventSubscriptionRepository(config.filePath);
            auto topicRepo           = new FileEventTopicRepository(config.filePath);
            auto channelRepo         = new FileEventChannelRepository(config.filePath);
            auto messageRepo         = new FileEventMessageRepository(config.filePath);
            auto filterRepo          = new FileEventFilterRepository(config.filePath);
            auto deadLetterRepo      = new FileDeadLetterEntryRepository(config.filePath);
            auto formationRepo       = new FileFormationRepository(config.filePath);
            auto systemRepo          = new FileSystemRegistrationRepository(config.filePath);

            c.eventSubscriptions  = new ManageEventSubscriptionsUseCase(subscriptionRepo);
            c.eventTopics         = new ManageEventTopicsUseCase(topicRepo);
            c.eventChannels       = new ManageEventChannelsUseCase(channelRepo);
            c.eventMessages       = new ManageEventMessagesUseCase(messageRepo);
            c.eventFilters        = new ManageEventFiltersUseCase(filterRepo);
            c.deadLetterEntries   = new ManageDeadLetterEntriesUseCase(deadLetterRepo);
            c.formations          = new ManageFormationsUseCase(formationRepo);
            c.systemRegistrations = new ManageSystemRegistrationsUseCase(systemRepo);
            break;
        }
        case "mongodb": {
            auto client = connectMongoDB(config.mongoUri);
            auto db     = client.getDatabase(config.mongoDb);

            auto subscriptionRepo    = new MongoEventSubscriptionRepository(db["event_subscriptions"]);
            auto topicRepo           = new MongoEventTopicRepository(db["event_topics"]);
            auto channelRepo         = new MongoEventChannelRepository(db["event_channels"]);
            auto messageRepo         = new MongoEventMessageRepository(db["event_messages"]);
            auto filterRepo          = new MongoEventFilterRepository(db["event_filters"]);
            auto deadLetterRepo      = new MongoDeadLetterEntryRepository(db["dead_letter_entries"]);
            auto formationRepo       = new MongoFormationRepository(db["formations"]);
            auto systemRepo          = new MongoSystemRegistrationRepository(db["system_registrations"]);

            c.eventSubscriptions  = new ManageEventSubscriptionsUseCase(subscriptionRepo);
            c.eventTopics         = new ManageEventTopicsUseCase(topicRepo);
            c.eventChannels       = new ManageEventChannelsUseCase(channelRepo);
            c.eventMessages       = new ManageEventMessagesUseCase(messageRepo);
            c.eventFilters        = new ManageEventFiltersUseCase(filterRepo);
            c.deadLetterEntries   = new ManageDeadLetterEntriesUseCase(deadLetterRepo);
            c.formations          = new ManageFormationsUseCase(formationRepo);
            c.systemRegistrations = new ManageSystemRegistrationsUseCase(systemRepo);
            break;
        }
        case "memory": {
            auto subscriptionRepo    = new MemoryEventSubscriptionRepository();
            auto topicRepo           = new MemoryEventTopicRepository();
            auto channelRepo         = new MemoryEventChannelRepository();
            auto messageRepo         = new MemoryEventMessageRepository();
            auto filterRepo          = new MemoryEventFilterRepository();
            auto deadLetterRepo      = new MemoryDeadLetterEntryRepository();
            auto formationRepo       = new MemoryFormationRepository();
            auto systemRepo          = new MemorySystemRegistrationRepository();

            c.eventSubscriptions  = new ManageEventSubscriptionsUseCase(subscriptionRepo);
            c.eventTopics         = new ManageEventTopicsUseCase(topicRepo);
            c.eventChannels       = new ManageEventChannelsUseCase(channelRepo);
            c.eventMessages       = new ManageEventMessagesUseCase(messageRepo);
            c.eventFilters        = new ManageEventFiltersUseCase(filterRepo);
            c.deadLetterEntries   = new ManageDeadLetterEntriesUseCase(deadLetterRepo);
            c.formations          = new ManageFormationsUseCase(formationRepo);
            c.systemRegistrations = new ManageSystemRegistrationsUseCase(systemRepo);
            break;
        }
    }

    c.subscriptionCtrl = new EventSubscriptionController(c.eventSubscriptions);
    c.topicCtrl        = new EventTopicController(c.eventTopics);
    c.channelCtrl      = new EventChannelController(c.eventChannels);
    c.messageCtrl      = new EventMessageController(c.eventMessages);
    c.filterCtrl       = new EventFilterController(c.eventFilters);
    c.deadLetterCtrl   = new DeadLetterEntryController(c.deadLetterEntries);
    c.formationCtrl    = new FormationController(c.formations);
    c.systemCtrl       = new SystemRegistrationController(c.systemRegistrations);
    c.healthCtrl       = new HealthController();

    return c;
}

/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.application.dto;

import uim.platform.appevents.domain.enums;
import uim.platform.appevents.domain.valueobjects;

@safe:

struct EventSubscriptionDTO {
    string name;
    string description;
    string producerSystemId;
    string consumerSystemId;
    string eventType;
    SubscriptionStatus status;
    string formationId;
    string filterExpression;
    int maxRetries = 3;
}

struct EventTopicDTO {
    string name;
    string namespace;
    string description;
    string version_;
    string category;
    TopicStatus status;
    string ownerId;
}

struct EventChannelDTO {
    string name;
    string topicId;
    ChannelType channelType;
    string endpoint;
    ChannelStatus status;
    DeliveryMode deliveryMode;
    long maxSizeBytes = 1_048_576;
}

struct EventMessageDTO {
    string channelId;
    string eventType;
    string payload;
    MessageStatus status;
    string sourceSystemId;
    string targetSystemId;
}

struct EventFilterDTO {
    string subscriptionId;
    FilterType filterType;
    string attribute;
    FilterOperator operator_;
    string value;
    bool active = true;
}

struct DeadLetterEntryDTO {
    string originalMessageId;
    string channelId;
    string errorMessage;
    long failedAt;
    DeadLetterStatus status;
}

struct FormationDTO {
    string name;
    string description;
    string globalAccountId;
    FormationStatus status;
}

struct SystemRegistrationDTO {
    string formationId;
    string systemId;
    SystemType systemType;
    string systemUrl;
    SystemStatus status;
}

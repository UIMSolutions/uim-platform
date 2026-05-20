/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.application.dto;

import uim.platform.service;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums;

@safe:

struct EventSubscriptionDTO {
    EventSubscriptionId subscriptionId;
    TenantId tenantId;
    string name;
    string description;
    string producerSystemId;
    string consumerSystemId;
    string eventType;
    SubscriptionStatus status;
    FormationId formationId;
    string filterExpression;
    int maxRetries = 3;
    UserId createdBy;
    UserId updatedBy;
}

struct EventTopicDTO {
    EventTopicId topicId;
    TenantId tenantId;
    string name;
    string namespace;
    string description;
    string version_;
    string category;
    TopicStatus status;
    string ownerId;
    UserId createdBy;
    UserId updatedBy;
}

struct EventChannelDTO {
    EventChannelId channelId;
    TenantId tenantId;
    string name;
    EventTopicId topicId;
    ChannelType channelType;
    string endpoint;
    ChannelStatus status;
    DeliveryMode deliveryMode;
    long maxSizeBytes = 1_048_576;
    UserId createdBy;
    UserId updatedBy;
}

struct EventMessageDTO {
    EventMessageId messageId;
    TenantId tenantId;
    EventChannelId channelId;
    string eventType;
    string payload;
    string sourceSystemId;
    string targetSystemId;
    UserId createdBy;
}

struct EventFilterDTO {
    EventFilterId filterId;
    TenantId tenantId;
    EventSubscriptionId subscriptionId;
    FilterType filterType;
    string attribute;
    FilterOperator operator_;
    string value;
    bool active = true;
    UserId createdBy;
    UserId updatedBy;
}

struct DeadLetterEntryDTO {
    DeadLetterEntryId entryId;
    TenantId tenantId;
    EventMessageId originalMessageId;
    EventChannelId channelId;
    string errorMessage;
    long failedAt;
    UserId createdBy;
}

struct FormationDTO {
    FormationId formationId;
    TenantId tenantId;
    string name;
    string description;
    string globalAccountId;
    FormationStatus status;
    UserId createdBy;
    UserId updatedBy;
}

struct SystemRegistrationDTO {
    SystemRegistrationId registrationId;
    TenantId tenantId;
    FormationId formationId;
    string systemId;
    SystemType systemType;
    string systemUrl;
    SystemStatus status;
    UserId createdBy;
}


/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.application.dto;

import uim.platform.events;

// mixin(ShowModule!());

@safe:

struct MessagingServiceDTO {
    MessagingServiceId serviceId;
    TenantId tenantId;
    string name;
    string description;
    string namespace;
    string plan;
    string region;
    string datacenter;
    string version_;
    string maxConnections;
    string maxQueues;
    string maxQueueDepth;
    string maxMessageSize;
    UserId createdBy;
    UserId updatedBy;
    long createdAt;
    long updatedAt;
}

struct MessageClientDTO {
    MessageClientId clientId;
    TenantId tenantId;
    MessagingServiceId serviceId;
    string name;
    string description;
    string protocol;
    string xsappname;
    string namespace;
    string permittedNamespace;
    UserId createdBy;
    UserId updatedBy;
    long createdAt;
    long updatedAt;
}

struct QueueDTO {
    QueueId queueId;
    TenantId tenantId;
    MessagingServiceId serviceId;
    string name;
    string description;
    string accessType;
    string maxMessageSizeBytes;
    string maxQueueSizeBytes;
    string maxConsumers;
    string deadLetterQueue;
    string discardMessages;
    string maxRedeliveryCount;
    string messageExpiryTimer;
    string owner;
    string permission;
    bool egressEnabled;
    bool ingressEnabled;
    UserId createdBy;
    UserId updatedBy;
    long createdAt;
    long updatedAt;
}

struct QueueSubscriptionDTO {
    QueueSubscriptionId subscriptionId;
    TenantId tenantId;
    QueueId queueId;
    MessagingServiceId serviceId;
    string name;
    string description;
    string topicPattern;
    string namespace;
    UserId createdBy;
    UserId updatedBy;
    long createdAt;
    long updatedAt;
}

struct WebhookDTO {
    WebhookId webhookId;
    TenantId tenantId;
    MessagingServiceId serviceId;
    QueueSubscriptionId subscriptionId;
    string name;
    string description;
    string url;
    string headers;
    bool exemptHandshake;
    string authenticationType;
    string credentialsType;
    string credentialGrant;
    string tokenUrl;
    string clientId;
    string pushInterval;
    string deliveryMode;
    string maxParallelity;
    UserId createdBy;
    UserId updatedBy;
    long createdAt;
    long updatedAt;
}

struct EventChannelDTO {
    EventChannelId channelId;
    TenantId tenantId;
    MessagingServiceId serviceId;
    string name;
    string description;
    string channelType;
    string namespace;
    string topicName;
    string asyncapiDefinition;
    string maxRetentionPeriod;
    string maxPartitions;
    UserId createdBy;
    UserId updatedBy;
    long createdAt;
    long updatedAt;
}

struct MessageBindingDTO {
    MessageBindingId bindingId;
    TenantId tenantId;
    MessageClientId clientId;
    MessagingServiceId serviceId;
    QueueId queueId;
    EventChannelId channelId;
    string name;
    string description;
    string permission;
    string bindingType;
    UserId createdBy;
    UserId updatedBy;
    long createdAt;
    long updatedAt;
}

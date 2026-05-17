/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.application.dto;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

struct BrokerServiceDTO {
    BrokerServiceId serviceId;
    TenantId tenantId;

    string name;
    string description;
    string status;
    string serviceType;
    string serviceClass;
    string cloudProvider;
    string region;
    string datacenter;
    string version_;
    string maxConnections;
    string maxQueueDepth;
    string maxMessageSize;
    string msgVpnName;
    UserId createdBy;
    UserId updatedBy;
    long createdAt;
    long updatedAt;
}

struct QueueDTO {
    QueueId queueId;
    TenantId tenantId;
    BrokerServiceId serviceId;

    string name;
    string description;
    string queueType;
    string accessType;
    string status;
    string maxMsgSpoolUsage;
    string maxBindCount;
    string maxMsgSize;
    string maxRedeliveryCount;
    string maxTtl;
    string deadMessageQueue;
    string owner;
    string permission;
    string egressEnabled;
    string ingressEnabled;
    UserId createdBy;
    UserId updatedBy;
    long createdAt;
    long updatedAt;
}

struct TopicDTO {
    TopicId topicId;
    TenantId tenantId;
    BrokerServiceId serviceId;

    string name;
    string description;
    string status;
    string topicString;
    string maxMessageSize;
    string publishEnabled;
    string subscribeEnabled;
    UserId createdBy;
    UserId updatedBy;
    long createdAt;
    long updatedAt;
}

struct SubscriptionDTO {
    EventSubscriptionId subscriptionId;
    TenantId tenantId;
    BrokerServiceId serviceId;
    TopicId topicId;
    QueueId queueId;
    EventApplicationId applicationId;

    string name;
    string description;
    string status;
    string subscriptionType;
    string deliveryMode;
    string topicFilter;
    string selector;
    string maxRedeliveryCount;
    string maxTtl;
    UserId createdBy;
    UserId updatedBy;
    long createdAt;
    long updatedAt;
}

struct EventMessageDTO {
    EventMessageId messageId;
    TenantId tenantId;
    BrokerServiceId serviceId;
    TopicId topicId;
    QueueId queueId;
    EventApplicationId applicationId;

    string correlationId;
    string contentType;
    string payload;
    string deliveryMode;
    string status;
    string priority;
    string topicString;
    string replyTo;
    string timeToLive;
    UserId createdBy;
    long createdAt;
}

struct EventSchemaDTO {
    TenantId tenantId;
    EventSchemaId schemaId;

    string name;
    string description;
    string format;
    string status;
    string version_;
    string schemaContent;
    string applicationDomainId;
    string shared_;
    UserId createdBy;
    UserId updatedBy;
    long createdAt;
    long updatedAt;
}

struct EventApplicationDTO {
    EventApplicationId applicationId;
    TenantId tenantId;
    BrokerServiceId serviceId;
    string applicationDomainId;

    string name;
    string description;
    string status;
    string applicationType;
    string clientUsername;
    string clientProfile;
    string aclProfile;
    string version_;
    string protocol;
    string publishTopics;
    string subscribeTopics;
    string webhookUrl;
    string maxConnections;
    UserId createdBy;
    UserId updatedBy;
    long createdAt;
    long updatedAt;
}

struct MeshBridgeDTO {
    MeshBridgeId bridgeId;
    TenantId tenantId;
    BrokerServiceId sourceServiceId;
    BrokerServiceId targetServiceId;
    
    string name;
    string description;
    string status;
    string bridgeType;
    string remoteAddress;
    string remoteVpnName;
    string topicSubscriptions;
    string queueBindings;
    string tlsEnabled;
    string compressedDataEnabled;
    string maxTtl;
    string retryCount;
    string retryDelay;
    UserId createdBy;
    UserId updatedBy;
    long createdAt;
    long updatedAt;
}

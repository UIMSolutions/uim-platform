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
    string id;
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
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}

struct QueueDTO {
    string id;
    TenantId tenantId;
    string brokerServiceId;
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
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}

struct TopicDTO {
    string id;
    TenantId tenantId;
    string brokerServiceId;
    string name;
    string description;
    string status;
    string topicString;
    string maxMessageSize;
    string publishEnabled;
    string subscribeEnabled;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}

struct SubscriptionDTO {
    string id;
    TenantId tenantId;
    string brokerServiceId;
    string topicId;
    string queueId;
    string applicationId;
    string name;
    string description;
    string status;
    string subscriptionType;
    string deliveryMode;
    string topicFilter;
    string selector;
    string maxRedeliveryCount;
    string maxTtl;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}

struct EventMessageDTO {
    string id;
    TenantId tenantId;
    string brokerServiceId;
    string topicId;
    string queueId;
    string publisherId;
    string correlationId;
    string contentType;
    string payload;
    string deliveryMode;
    string status;
    string priority;
    string topicString;
    string replyTo;
    string timeToLive;
    string createdBy;
    string createdAt;
}

struct EventSchemaDTO {
    string id;
    TenantId tenantId;
    string name;
    string description;
    string format;
    string status;
    string version_;
    string schemaContent;
    string applicationDomainId;
    string shared_;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}

struct EventApplicationDTO {
    string id;
    TenantId tenantId;
    string brokerServiceId;
    string name;
    string description;
    string status;
    string applicationType;
    string applicationDomainId;
    string clientUsername;
    string clientProfile;
    string aclProfile;
    string version_;
    string protocol;
    string publishTopics;
    string subscribeTopics;
    string webhookUrl;
    string maxConnections;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}

struct MeshBridgeDTO {
    string id;
    TenantId tenantId;
    string sourceBrokerId;
    string targetBrokerId;
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
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}

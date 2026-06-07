/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.presentation.web.models.entities;

import std.conv : to;
import std.uuid : randomUUID;

import uim.platform.event_mesh;

// mixin(ShowModule!());

@safe:

private string newId() {
    return randomUUID().to!string;
}

class WebBrokerServiceModel {
    private ManageBrokerServicesUseCase usecase;

    this(ManageBrokerServicesUseCase usecase) {
        this.usecase = usecase;
    }

    BrokerService[] list(TenantId tenantId) {
        return usecase.listServices(tenantId);
    }

    BrokerService get(TenantId tenantId, string id) {
        return usecase.getService(tenantId, BrokerServiceId(id));
    }

    CommandResult create(TenantId tenantId, Json data) {
        BrokerServiceDTO dto;
        dto.serviceId = BrokerServiceId(data.getString("id").length > 0 ? data.getString("id") : newId());
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.region = data.getString("region");
        dto.datacenter = data.getString("datacenter");
        dto.version_ = data.getString("version");
        dto.maxConnections = data.getString("maxConnections");
        dto.maxQueueDepth = data.getString("maxQueueDepth");
        dto.maxMessageSize = data.getString("maxMessageSize");
        dto.msgVpnName = data.getString("msgVpnName");
        dto.createdBy = UserId(data.getString("createdBy"));
        return usecase.createService(dto);
    }

    CommandResult update(TenantId tenantId, string id, Json data) {
        BrokerServiceDTO dto;
        dto.serviceId = BrokerServiceId(id);
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.region = data.getString("region");
        dto.maxConnections = data.getString("maxConnections");
        dto.maxQueueDepth = data.getString("maxQueueDepth");
        dto.maxMessageSize = data.getString("maxMessageSize");
        dto.updatedBy = UserId(data.getString("updatedBy"));
        return usecase.updateService(dto);
    }

    CommandResult remove(TenantId tenantId, string id) {
        return usecase.deleteService(tenantId, BrokerServiceId(id));
    }
}

class WebQueueModel {
    private ManageQueuesUseCase usecase;

    this(ManageQueuesUseCase usecase) {
        this.usecase = usecase;
    }

    Queue[] list(TenantId tenantId) {
        return usecase.listQueues(tenantId);
    }

    Queue get(TenantId tenantId, string id) {
        return usecase.getQueue(tenantId, QueueId(id));
    }

    CommandResult create(TenantId tenantId, Json data) {
        QueueDTO dto;
        dto.queueId = QueueId(data.getString("id").length > 0 ? data.getString("id") : newId());
        dto.tenantId = tenantId;
        dto.serviceId = BrokerServiceId(data.getString("brokerServiceId"));
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.maxMsgSpoolUsage = data.getString("maxMsgSpoolUsage");
        dto.maxBindCount = data.getString("maxBindCount");
        dto.maxMsgSize = data.getString("maxMsgSize");
        dto.maxRedeliveryCount = data.getString("maxRedeliveryCount");
        dto.maxTtl = data.getString("maxTtl");
        dto.deadMessageQueue = data.getString("deadMessageQueue");
        dto.owner = data.getString("owner");
        dto.permission = data.getString("permission");
        dto.egressEnabled = data.getString("egressEnabled");
        dto.ingressEnabled = data.getString("ingressEnabled");
        dto.createdBy = UserId(data.getString("createdBy"));
        return usecase.createQueue(dto);
    }

    CommandResult update(TenantId tenantId, string id, Json data) {
        QueueDTO dto;
        dto.queueId = QueueId(id);
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.maxMsgSpoolUsage = data.getString("maxMsgSpoolUsage");
        dto.maxBindCount = data.getString("maxBindCount");
        dto.maxMsgSize = data.getString("maxMsgSize");
        dto.updatedBy = UserId(data.getString("updatedBy"));
        return usecase.updateQueue(dto);
    }

    CommandResult remove(TenantId tenantId, string id) {
        return usecase.deleteQueue(tenantId, QueueId(id));
    }
}

class WebTopicModel {
    private ManageTopicsUseCase usecase;

    this(ManageTopicsUseCase usecase) {
        this.usecase = usecase;
    }

    Topic[] list(TenantId tenantId) {
        return usecase.listTopics(tenantId);
    }

    Topic get(TenantId tenantId, string id) {
        return usecase.getTopic(tenantId, TopicId(id));
    }

    CommandResult create(TenantId tenantId, Json data) {
        TopicDTO dto;
        dto.topicId = TopicId(data.getString("id").length > 0 ? data.getString("id") : newId());
        dto.tenantId = tenantId;
        dto.serviceId = BrokerServiceId(data.getString("brokerServiceId"));
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.topicString = data.getString("topicString");
        dto.maxMessageSize = data.getString("maxMessageSize");
        dto.publishEnabled = data.getString("publishEnabled");
        dto.subscribeEnabled = data.getString("subscribeEnabled");
        dto.createdBy = UserId(data.getString("createdBy"));
        return usecase.createTopic(dto);
    }

    CommandResult update(TenantId tenantId, string id, Json data) {
        TopicDTO dto;
        dto.topicId = TopicId(id);
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.topicString = data.getString("topicString");
        dto.maxMessageSize = data.getString("maxMessageSize");
        dto.updatedBy = UserId(data.getString("updatedBy"));
        return usecase.updateTopic(dto);
    }

    CommandResult remove(TenantId tenantId, string id) {
        return usecase.deleteTopic(tenantId, TopicId(id));
    }
}

class WebSubscriptionModel {
    private ManageSubscriptionsUseCase usecase;

    this(ManageSubscriptionsUseCase usecase) {
        this.usecase = usecase;
    }

    EventSubscription[] list(TenantId tenantId) {
        return usecase.listSubscriptions(tenantId);
    }

    EventSubscription get(TenantId tenantId, string id) {
        return usecase.getSubscription(tenantId, EventSubscriptionId(id));
    }

    CommandResult create(TenantId tenantId, Json data) {
        SubscriptionDTO dto;
        dto.subscriptionId = EventSubscriptionId(data.getString("id").length > 0 ? data.getString("id") : newId());
        dto.tenantId = tenantId;
        dto.serviceId = BrokerServiceId(data.getString("brokerServiceId"));
        dto.topicId = TopicId(data.getString("topicId"));
        dto.queueId = QueueId(data.getString("queueId"));
        dto.applicationId = EventApplicationId(data.getString("applicationId"));
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.topicFilter = data.getString("topicFilter");
        dto.selector = data.getString("selector");
        dto.maxRedeliveryCount = data.getString("maxRedeliveryCount");
        dto.maxTtl = data.getString("maxTtl");
        dto.createdBy = UserId(data.getString("createdBy"));
        return usecase.createSubscription(dto);
    }

    CommandResult update(TenantId tenantId, string id, Json data) {
        SubscriptionDTO dto;
        dto.subscriptionId = EventSubscriptionId(id);
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.topicFilter = data.getString("topicFilter");
        dto.selector = data.getString("selector");
        dto.updatedBy = UserId(data.getString("updatedBy"));
        return usecase.updateSubscription(dto);
    }

    CommandResult remove(TenantId tenantId, string id) {
        return usecase.deleteSubscription(tenantId, EventSubscriptionId(id));
    }
}

class WebEventMessageModel {
    private ManageEventMessagesUseCase usecase;

    this(ManageEventMessagesUseCase usecase) {
        this.usecase = usecase;
    }

    EventMessage[] list(TenantId tenantId) {
        return usecase.listMessages(tenantId);
    }

    EventMessage get(TenantId tenantId, string id) {
        return usecase.getMessage(tenantId, EventMessageId(id));
    }

    CommandResult create(TenantId tenantId, Json data) {
        EventMessageDTO dto;
        dto.messageId = EventMessageId(data.getString("id").length > 0 ? data.getString("id") : newId());
        dto.tenantId = tenantId;
        dto.serviceId = BrokerServiceId(data.getString("serviceId"));
        dto.topicId = TopicId(data.getString("topicId"));
        dto.queueId = QueueId(data.getString("queueId"));
        dto.applicationId = EventApplicationId(data.getString("applicationId"));
        dto.correlationId = data.getString("correlationId");
        dto.contentType = data.getString("contentType");
        dto.payload = data.getString("payload");
        dto.topicString = data.getString("topicString");
        dto.replyTo = data.getString("replyTo");
        dto.timeToLive = data.getString("timeToLive");
        dto.createdBy = UserId(data.getString("createdBy"));
        return usecase.publishMessage(dto);
    }

    CommandResult update(TenantId tenantId, string id, Json data) {
        auto status = data.getString("status");
        auto acknowledge = data.getString("acknowledge");
        if (status == "acknowledged" || acknowledge == "true") {
            return usecase.acknowledgeMessage(tenantId, EventMessageId(id));
        }
        return CommandResult(false, "", "Event message update supports acknowledgement only");
    }

    CommandResult remove(TenantId tenantId, string id) {
        return usecase.deleteMessage(tenantId, EventMessageId(id));
    }
}

class WebEventSchemaModel {
    private ManageEventSchemasUseCase usecase;

    this(ManageEventSchemasUseCase usecase) {
        this.usecase = usecase;
    }

    EventSchema[] list(TenantId tenantId) {
        return usecase.listSchemas(tenantId);
    }

    EventSchema get(TenantId tenantId, string id) {
        return usecase.getSchema(tenantId, EventSchemaId(id));
    }

    CommandResult create(TenantId tenantId, Json data) {
        EventSchemaDTO dto;
        dto.schemaId = EventSchemaId(data.getString("id").length > 0 ? data.getString("id") : newId());
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.version_ = data.getString("version");
        dto.schemaContent = data.getString("schemaContent");
        dto.applicationDomainId = data.getString("applicationDomainId");
        dto.shared_ = data.getString("shared");
        dto.createdBy = UserId(data.getString("createdBy"));
        return usecase.createSchema(dto);
    }

    CommandResult update(TenantId tenantId, string id, Json data) {
        EventSchemaDTO dto;
        dto.schemaId = EventSchemaId(id);
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.version_ = data.getString("version");
        dto.schemaContent = data.getString("schemaContent");
        dto.updatedBy = UserId(data.getString("updatedBy"));
        return usecase.updateSchema(dto);
    }

    CommandResult remove(TenantId tenantId, string id) {
        return usecase.deleteSchema(tenantId, EventSchemaId(id));
    }
}

class WebEventApplicationModel {
    private ManageEventApplicationsUseCase usecase;

    this(ManageEventApplicationsUseCase usecase) {
        this.usecase = usecase;
    }

    EventApplication[] list(TenantId tenantId) {
        return usecase.listApplications(tenantId);
    }

    EventApplication get(TenantId tenantId, string id) {
        return usecase.getApplication(tenantId, EventApplicationId(id));
    }

    CommandResult create(TenantId tenantId, Json data) {
        EventApplicationDTO dto;
        dto.applicationId = EventApplicationId(data.getString("id").length > 0 ? data.getString("id") : newId());
        dto.tenantId = tenantId;
        dto.serviceId = BrokerServiceId(data.getString("brokerServiceId"));
        dto.applicationDomainId = data.getString("applicationDomainId");
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.clientUsername = data.getString("clientUsername");
        dto.clientProfile = data.getString("clientProfile");
        dto.aclProfile = data.getString("aclProfile");
        dto.version_ = data.getString("version");
        dto.publishTopics = data.getString("publishTopics");
        dto.subscribeTopics = data.getString("subscribeTopics");
        dto.webhookUrl = data.getString("webhookUrl");
        dto.maxConnections = data.getString("maxConnections");
        dto.createdBy = UserId(data.getString("createdBy"));
        return usecase.createApplication(dto);
    }

    CommandResult update(TenantId tenantId, string id, Json data) {
        EventApplicationDTO dto;
        dto.applicationId = EventApplicationId(id);
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.clientUsername = data.getString("clientUsername");
        dto.clientProfile = data.getString("clientProfile");
        dto.aclProfile = data.getString("aclProfile");
        dto.publishTopics = data.getString("publishTopics");
        dto.subscribeTopics = data.getString("subscribeTopics");
        dto.updatedBy = UserId(data.getString("updatedBy"));
        return usecase.updateApplication(dto);
    }

    CommandResult remove(TenantId tenantId, string id) {
        return usecase.deleteApplication(tenantId, EventApplicationId(id));
    }
}

class WebMeshBridgeModel {
    private ManageMeshBridgesUseCase usecase;

    this(ManageMeshBridgesUseCase usecase) {
        this.usecase = usecase;
    }

    MeshBridge[] list(TenantId tenantId) {
        return usecase.listBridges(tenantId);
    }

    MeshBridge get(TenantId tenantId, string id) {
        return usecase.getBridge(tenantId, MeshBridgeId(id));
    }

    CommandResult create(TenantId tenantId, Json data) {
        MeshBridgeDTO dto;
        dto.bridgeId = MeshBridgeId(data.getString("id").length > 0 ? data.getString("id") : newId());
        dto.tenantId = tenantId;
        dto.sourceServiceId = BrokerServiceId(data.getString("sourceServiceId"));
        dto.targetServiceId = BrokerServiceId(data.getString("targetServiceId"));
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.remoteAddress = data.getString("remoteAddress");
        dto.remoteVpnName = data.getString("remoteVpnName");
        dto.topicSubscriptions = data.getString("topicSubscriptions");
        dto.queueBindings = data.getString("queueBindings");
        dto.tlsEnabled = data.getString("tlsEnabled");
        dto.compressedDataEnabled = data.getString("compressedDataEnabled");
        dto.maxTtl = data.getString("maxTtl");
        dto.retryCount = data.getString("retryCount");
        dto.retryDelay = data.getString("retryDelay");
        dto.createdBy = UserId(data.getString("createdBy"));
        return usecase.createBridge(dto);
    }

    CommandResult update(TenantId tenantId, string id, Json data) {
        MeshBridgeDTO dto;
        dto.bridgeId = MeshBridgeId(id);
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.remoteAddress = data.getString("remoteAddress");
        dto.topicSubscriptions = data.getString("topicSubscriptions");
        dto.queueBindings = data.getString("queueBindings");
        dto.updatedBy = UserId(data.getString("updatedBy"));
        return usecase.updateBridge(dto);
    }

    CommandResult remove(TenantId tenantId, string id) {
        return usecase.deleteBridge(tenantId, MeshBridgeId(id));
    }
}

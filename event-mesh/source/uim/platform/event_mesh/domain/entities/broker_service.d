/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.domain.entities.broker_service;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

struct BrokerService {
    BrokerServiceId id;
    TenantId tenantId;
    string name;
    string description;
    BrokerServiceStatus status = BrokerServiceStatus.provisioning;
    BrokerServiceType serviceType = BrokerServiceType.standard;
    BrokerServiceClass serviceClass = BrokerServiceClass.standardKilo;
    CloudProvider cloudProvider = CloudProvider.sap;
    string region;
    string datacenter;
    string version_;
    string maxConnections;
    string maxQueueDepth;
    string maxMessageSize;
    string msgVpnName;
    string smfHost;
    string smfPort;
    string mqttHost;
    string mqttPort;
    string amqpHost;
    string amqpPort;
    string restHost;
    string restPort;
    string webSocketHost;
    string webSocketPort;
    string adminUrl;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;

    Json brokerServiceToJson() {
        return Json.emptyObject
            .set("id", id)
            .set("tenantId", tenantId)
            .set("name", name)
            .set("description", description)
            .set("status", status.to!string)
            .set("serviceType", serviceType.to!string)
            .set("serviceClass", serviceClass.to!string)
            .set("cloudProvider", cloudProvider.to!string)
            .set("region", region)
            .set("datacenter", datacenter)
            .set("version", version_)
            .set("maxConnections", maxConnections)
            .set("maxQueueDepth", maxQueueDepth)
            .set("maxMessageSize", maxMessageSize)
            .set("msgVpnName", msgVpnName)
            .set("smfHost", smfHost)
            .set("smfPort", smfPort)
            .set("mqttHost", mqttHost)
            .set("mqttPort", mqttPort)
            .set("amqpHost", amqpHost)
            .set("amqpPort", amqpPort)
            .set("restHost", restHost)
            .set("restPort", restPort)
            .set("webSocketHost", webSocketHost)
            .set("webSocketPort", webSocketPort)
            .set("adminUrl", adminUrl)
            .set("createdBy", createdBy)
            .set("modifiedBy", modifiedBy)
            .set("createdAt", createdAt)
            .set("modifiedAt", modifiedAt);
    }
}

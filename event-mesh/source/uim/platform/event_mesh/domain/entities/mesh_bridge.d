/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.domain.entities.mesh_bridge;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

struct MeshBridge {
    mixin TenantEntity!(MeshBridgeId);
    
    BrokerServiceId sourceBrokerId;
    BrokerServiceId targetBrokerId;
    string name;
    string description;
    BridgeStatus status = BridgeStatus.provisioning;
    BridgeType bridgeType = BridgeType.mesh;
    string remoteAddress;
    string remoteVpnName;
    string topicSubscriptions;
    string queueBindings;
    string tlsEnabled;
    string compressedDataEnabled;
    string maxTtl;
    string retryCount;
    string retryDelay;
    string egressFlowWindowSize;
    string uplinkThroughput;
    string downlinkThroughput;
    
    Json toJson() const {
        return Json.entityToJson
            .set("sourceBrokerId", sourceBrokerId)
            .set("targetBrokerId", targetBrokerId)
            .set("name", name)
            .set("description", description)
            .set("status", status.to!string)
            .set("bridgeType", bridgeType.to!string)
            .set("remoteAddress", remoteAddress)
            .set("remoteVpnName", remoteVpnName)
            .set("topicSubscriptions", topicSubscriptions)
            .set("queueBindings", queueBindings)
            .set("tlsEnabled", tlsEnabled)
            .set("compressedDataEnabled", compressedDataEnabled)
            .set("maxTtl", maxTtl)
            .set("retryCount", retryCount)
            .set("retryDelay", retryDelay)
            .set("egressFlowWindowSize", egressFlowWindowSize)
            .set("uplinkThroughput", uplinkThroughput)
            .set("downlinkThroughput", downlinkThroughput);
    }
}

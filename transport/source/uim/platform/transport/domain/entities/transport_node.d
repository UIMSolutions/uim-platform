/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.domain.entities.transport_node;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// Represents a deployment target or source in the transport landscape.
/// Maps to a Cloud Foundry space, ABAP system, Neo subaccount, or Kyma cluster.
struct TransportNode {
    mixin TenantEntity!TransportNodeId;

    string name;
    string description;
    NodeType nodeType = NodeType.cloudFoundry;
    NodeStatus status = NodeStatus.enabled;
    string environment;
    string region;
    string globalAccount;
    string subaccountId;
    SpaceId spaceId;
    string serviceKey;
    bool isForwardEnabled = true;
    bool autoImport = false;
    string autoImportSchedule;
    long lastCheckedAt;
    string connectionStatus;

    Json toJson() const {
        return entityToJson
            .set("name", name)
            .set("description", description)
            .set("nodeType", nodeType.to!string)
            .set("status", status.to!string)
            .set("environment", environment)
            .set("region", region)
            .set("globalAccount", globalAccount)
            .set("subaccountId", subaccountId)
            .set("spaceId", spaceId)
            .set("isForwardEnabled", isForwardEnabled)
            .set("autoImport", autoImport)
            .set("autoImportSchedule", autoImportSchedule)
            .set("lastCheckedAt", lastCheckedAt)
            .set("connectionStatus", connectionStatus);
    }
}

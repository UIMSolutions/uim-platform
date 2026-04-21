/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.domain.repositories.mesh_bridges;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

interface MeshBridgeRepository : ITenantRepository!(MeshBridge, MeshBridgeId) {

    size_t countBySourceBroker(BrokerServiceId sourceBrokerId);
    MeshBridge[] findBySourceBroker(BrokerServiceId sourceBrokerId);
    void removeBySourceBroker(BrokerServiceId sourceBrokerId);

    size_t countByTargetBroker(BrokerServiceId targetBrokerId);
    MeshBridge[] findByTargetBroker(BrokerServiceId targetBrokerId);
    void removeByTargetBroker(BrokerServiceId targetBrokerId);

    size_t countByStatus(BridgeStatus status);
    MeshBridge[] findByStatus(BridgeStatus status);
    void removeByStatus(BridgeStatus status);

}

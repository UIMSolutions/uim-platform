/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.domain.repositories.mesh_bridges;

import uim.platform.event_mesh;

// mixin(ShowModule!());

@safe:

interface MeshBridgeRepository : ITentRepository!(MeshBridge, MeshBridgeId) {

    size_t countBySourceBrokerService(TenantId tenantId, BrokerServiceId sourceBrokerId);
    MeshBridge[] findBySourceBrokerService(TenantId tenantId, BrokerServiceId sourceBrokerId);
    void removeBySourceBrokerService(TenantId tenantId, BrokerServiceId sourceBrokerId);

    size_t countByTargetBrokerService(TenantId tenantId, BrokerServiceId targetBrokerId);
    MeshBridge[] findByTargetBrokerService(TenantId tenantId, BrokerServiceId targetBrokerId);
    void removeByTargetBrokerService(TenantId tenantId, BrokerServiceId targetBrokerId);

    size_t countByStatus(TenantId tenantId, BridgeStatus status);
    MeshBridge[] findByStatus(TenantId tenantId, BridgeStatus status);
    void removeByStatus(TenantId tenantId, BridgeStatus status);

}

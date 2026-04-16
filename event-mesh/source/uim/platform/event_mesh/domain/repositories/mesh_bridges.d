/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.domain.repositories.mesh_bridges;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

interface MeshBridgeRepository {
    bool existsById(MeshBridgeId id);
    MeshBridge findById(MeshBridgeId id);

    MeshBridge[] findAll();
    MeshBridge[] findByTenant(TenantId tenantId);
    MeshBridge[] findBySourceBroker(BrokerServiceId sourceBrokerId);
    MeshBridge[] findByTargetBroker(BrokerServiceId targetBrokerId);
    MeshBridge[] findByStatus(BridgeStatus status);

    void save(MeshBridge bridge);
    void update(MeshBridge bridge);
    void remove(MeshBridgeId id);
}

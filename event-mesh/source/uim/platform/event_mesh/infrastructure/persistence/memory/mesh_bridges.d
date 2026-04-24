/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.infrastructure.persistence.memory.mesh_bridges;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class MemoryMeshBridgeRepository : MeshBridgeRepository {
    private MeshBridge[] store;

    bool existsById(MeshBridgeId id) {
        return store.any!(e => e.id == id);
    }

    MeshBridge findById(MeshBridgeId id) {
        foreach (e; findAll)
            if (e.id == id) return e;
        return MeshBridge.init;
    }

    MeshBridge[] findAll() { return store; }

    MeshBridge[] findByTenant(TenantId tenantId) {
        return findAll().filter!(e => e.tenantId == tenantId).array;
    }

    MeshBridge[] findBySourceBroker(BrokerServiceId sourceBrokerId) {
        return findAll().filter!(e => e.sourceBrokerId == sourceBrokerId).array;
    }

    MeshBridge[] findByTargetBroker(BrokerServiceId targetBrokerId) {
        return findAll().filter!(e => e.targetBrokerId == targetBrokerId).array;
    }

    MeshBridge[] findByStatus(BridgeStatus status) {
        return findAll().filter!(e => e.status == status).array;
    }

    void save(MeshBridge bridge) { store ~= bridge; }

    void update(MeshBridge bridge) {
        foreach (ref e; store)
            if (e.id == bridge.id) { e = bridge; return; }
    }

    void remove(MeshBridgeId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}

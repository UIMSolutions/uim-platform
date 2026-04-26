/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.infrastructure.persistence.memory.mesh_bridges;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class MemoryMeshBridgeRepository : TenantRepository!(MeshBridge, MeshBridgeId), MeshBridgeRepository {

    size_t countBySourceBroker(BrokerServiceId sourceBrokerId) {
        return findBySourceBroker(sourceBrokerId).length;
    }
    MeshBridge[] filterBySourceBroker(MeshBridge[] bridges, BrokerServiceId sourceBrokerId) {
        return bridges.filter!(e => e.sourceBrokerId == sourceBrokerId).array;
    }
    MeshBridge[] findBySourceBroker(BrokerServiceId sourceBrokerId) {
        return findAll().filter!(e => e.sourceBrokerId == sourceBrokerId).array;
    }
    void removeBySourceBroker(BrokerServiceId sourceBrokerId) {
        findBySourceBroker(sourceBrokerId).each!(e => remove(e));
    }

    size_t countByTargetBroker(BrokerServiceId targetBrokerId) {
        return findByTargetBroker(targetBrokerId).length;
    }
    MeshBridge[] filterByTargetBroker(MeshBridge[] bridges, BrokerServiceId targetBrokerId) {
        return bridges.filter!(e => e.targetBrokerId == targetBrokerId).array;
    }
    MeshBridge[] findByTargetBroker(BrokerServiceId targetBrokerId) {
        return findAll().filter!(e => e.targetBrokerId == targetBrokerId).array;
    }
    void removeByTargetBroker(BrokerServiceId targetBrokerId) {
        findByTargetBroker(targetBrokerId).each!(e => remove(e));
    }

    size_t countByStatus(BridgeStatus status) {
        return findByStatus(status).length;
    }
    MeshBridge[] filterByStatus(MeshBridge[] bridges, BridgeStatus status) {
        return bridges.filter!(e => e.status == status).array;
    }
    MeshBridge[] findByStatus(BridgeStatus status) {
        return findAll().filter!(e => e.status == status).array;
    }
    void removeByStatus(BridgeStatus status) {
        findByStatus(status).each!(e => remove(e));
    }

}

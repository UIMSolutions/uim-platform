/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.infrastructure.persistence.memory.mesh_bridges;

import uim.platform.event_mesh;

// mixin(ShowModule!());

@safe:

class MemoryMeshBridgeRepository : TentRepository!(MeshBridge, MeshBridgeId), MeshBridgeRepository {

    size_t countBySourceBrokerService(TenantId tenantId, BrokerServiceId sourceServiceId) {
        return findBySourceBrokerService(tenantId, sourceServiceId).length;
    }
    MeshBridge[] filterBySourceBrokerService(MeshBridge[] bridges, BrokerServiceId sourceServiceId) {
        return bridges.filter!(e => e.sourceServiceId == sourceServiceId).array;
    }
    MeshBridge[] findBySourceBrokerService(TenantId tenantId, BrokerServiceId sourceServiceId) {
        return filterBySourceBrokerService(findByTenant(tenantId), sourceServiceId);
    }
    void removeBySourceBrokerService(TenantId tenantId, BrokerServiceId sourceServiceId) {
        findBySourceBrokerService(tenantId, sourceServiceId).each!(e => remove(e));
    }

    size_t countByTargetBrokerService(TenantId tenantId, BrokerServiceId targetServiceId) {
        return findByTargetBrokerService(tenantId, targetServiceId).length;
    }
    MeshBridge[] filterByTargetBrokerService(MeshBridge[] bridges, BrokerServiceId targetServiceId) {
        return bridges.filter!(e => e.targetServiceId == targetServiceId).array;
    }
    MeshBridge[] findByTargetBrokerService(TenantId tenantId, BrokerServiceId targetServiceId) {
        return filterByTargetBrokerService(findByTenant(tenantId), targetServiceId);
    }
    void removeByTargetBrokerService(TenantId tenantId, BrokerServiceId targetServiceId) {
        findByTargetBrokerService(tenantId, targetServiceId).each!(e => remove(e));
    }

    size_t countByStatus(TenantId tenantId, BridgeStatus status) {
        return findByStatus(tenantId, status).length;
    }
    MeshBridge[] filterByStatus(MeshBridge[] bridges, BridgeStatus status) {
        return bridges.filter!(e => e.status == status).array;
    }
    MeshBridge[] findByStatus(TenantId tenantId, BridgeStatus status) {
        return filterByStatus(findByTenant(tenantId), status);
    }
    void removeByStatus(TenantId tenantId, BridgeStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }

}

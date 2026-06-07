/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.application.usecases.manage.mesh_bridges;

import uim.platform.event_mesh;

// mixin(ShowModule!());

@safe:

class ManageMeshBridgesUseCase { // TODO: UIMUseCase {
    private MeshBridgeRepository repo;

    this(MeshBridgeRepository repo) {
        this.repo = repo;
    }

    MeshBridge getBridge(TenantId tenantId,  MeshBridgeId bridgeId) {
        return repo.findById(tenantId, bridgeId);
    }

    MeshBridge[] listBridges(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    MeshBridge[] listBridges(TenantId tenantId, BrokerServiceId serviceId) {
        return repo.findBySourceBrokerService(tenantId, serviceId);
    }

    CommandResult createBridge(MeshBridgeDTO dto) {
        MeshBridge bridge;
        bridge.id = dto.bridgeId;
        bridge.tenantId = dto.tenantId;
        bridge.sourceServiceId = dto.sourceServiceId;
        bridge.targetServiceId = dto.targetServiceId;
        bridge.name = dto.name;
        bridge.description = dto.description;
        bridge.remoteAddress = dto.remoteAddress;
        bridge.remoteVpnName = dto.remoteVpnName;
        bridge.topicSubscriptions = dto.topicSubscriptions;
        bridge.queueBindings = dto.queueBindings;
        bridge.tlsEnabled = dto.tlsEnabled;
        bridge.compressedDataEnabled = dto.compressedDataEnabled;
        bridge.maxTtl = dto.maxTtl;
        bridge.retryCount = dto.retryCount;
        bridge.retryDelay = dto.retryDelay;
        bridge.createdBy = dto.createdBy;
        if (!EventMeshValidator.isValidMeshBridge(bridge))
            return CommandResult(false, "", "Invalid mesh bridge data");

        repo.save(bridge);
        return CommandResult(true, bridge.id.value, "");
    }

    CommandResult updateBridge(MeshBridgeDTO dto) {
        auto bridge = repo.findById(dto.tenantId, dto.bridgeId);
        if (bridge.isNull)
            return CommandResult(false, "", "Mesh bridge not found");

        if (dto.name.length > 0) bridge.name = dto.name;
        if (dto.description.length > 0) bridge.description = dto.description;
        if (dto.remoteAddress.length > 0) bridge.remoteAddress = dto.remoteAddress;
        if (dto.topicSubscriptions.length > 0) bridge.topicSubscriptions = dto.topicSubscriptions;
        if (dto.queueBindings.length > 0) bridge.queueBindings = dto.queueBindings;
        if (!dto.updatedBy.isNull) bridge.updatedBy = dto.updatedBy;

        repo.update(bridge);
        return CommandResult(true, bridge.id.value, "");
    }

    CommandResult deleteBridge(TenantId tenantId, MeshBridgeId bridgeId) {
        auto bridge = repo.findById(tenantId, bridgeId);
        if (bridge.isNull)
            return CommandResult(false, "", "Mesh bridge not found");

        repo.remove(bridge);
        return CommandResult(true, bridge.id.value, "");
    }
}

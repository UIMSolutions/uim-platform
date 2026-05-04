/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.application.usecases.manage.mesh_bridges;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class ManageMeshBridgesUseCase { // TODO: UIMUseCase {
    private MeshBridgeRepository repo;

    this(MeshBridgeRepository repo) {
        this.repo = repo;
    }

    MeshBridge getById(MeshBridgeId id) {
        return repo.findById(id);
    }

    MeshBridge[] list() {
        return repo.findAll();
    }

    MeshBridge[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    MeshBridge[] listBySourceBroker(BrokerServiceId sourceBrokerId) {
        return repo.findBySourceBroker(sourceBrokerId);
    }

    CommandResult create(MeshBridgeDTO dto) {
        MeshBridge b;
        b.id = MeshBridgeId(dto.id);
        b.tenantId = dto.tenantId;
        b.sourceBrokerId = BrokerServiceId(dto.sourceBrokerId);
        b.targetBrokerId = BrokerServiceId(dto.targetBrokerId);
        b.name = dto.name;
        b.description = dto.description;
        b.remoteAddress = dto.remoteAddress;
        b.remoteVpnName = dto.remoteVpnName;
        b.topicSubscriptions = dto.topicSubscriptions;
        b.queueBindings = dto.queueBindings;
        b.tlsEnabled = dto.tlsEnabled;
        b.compressedDataEnabled = dto.compressedDataEnabled;
        b.maxTtl = dto.maxTtl;
        b.retryCount = dto.retryCount;
        b.retryDelay = dto.retryDelay;
        b.createdBy = dto.createdBy;
        if (!EventMeshValidator.isValidMeshBridge(b))
            return CommandResult(false, "", "Invalid mesh bridge data");
        repo.save(b);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(MeshBridgeDTO dto) {
        auto existing = repo.findById(MeshBridgeId(dto.id));
        if (existing.isNull)
            return CommandResult(false, "", "Mesh bridge not found");
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.remoteAddress.length > 0) existing.remoteAddress = dto.remoteAddress;
        if (dto.topicSubscriptions.length > 0) existing.topicSubscriptions = dto.topicSubscriptions;
        if (dto.queueBindings.length > 0) existing.queueBindings = dto.queueBindings;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(MeshBridgeId id) {
        auto existing = repo.findById(id);
        if (existing.isNull)
            return CommandResult(false, "", "Mesh bridge not found");
        repo.removeById(id);
        return CommandResult(true, id.value, "");
    }
}

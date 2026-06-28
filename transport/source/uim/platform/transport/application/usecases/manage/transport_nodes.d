/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.application.usecases.manage.transport_nodes;

import uim.platform.transport;

// mixin(ShowModule!());

@safe:

class ManageTransportNodesUseCase {
    private TransportNodeRepository repo;

    this(TransportNodeRepository repo) {
        this.repo = repo;
    }

    TransportNode getNode(TenantId tenantId, TransportNodeId id) {
        return repo.find(tenantId, id);
    }

    TransportNode[] listNodes(TenantId tenantId) {
        return repo.find(tenantId);
    }

    TransportNode[] listNodesByStatus(TenantId tenantId, NodeStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    TransportNode[] listNodesByType(TenantId tenantId, NodeType nodeType) {
        return repo.findByType(tenantId, nodeType);
    }

    CommandResult createNode(TransportNodeDTO dto) {
        TransportNode node;
        node.id = dto.nodeId;
        node.tenantId = dto.tenantId;
        node.name = dto.name;
        node.description = dto.description;
        node.environment = dto.environment;
        node.region = dto.region;
        node.globalAccount = dto.globalAccount;
        node.subaccountId = dto.subaccountId;
        node.spaceId = dto.spaceId;
        node.serviceKey = dto.serviceKey;
        node.isForwardEnabled = dto.isForwardEnabled;
        node.autoImport = dto.autoImport;
        node.autoImportSchedule = dto.autoImportSchedule;
        node.createdBy = dto.createdBy;
        if (dto.nodeType.length > 0) {
            
            try { node.nodeType = dto.nodeType.to!NodeType; } catch (Exception) {}
        }
        node.status = NodeStatus.enabled;
        if (!TransportValidator.isValidNode(node))
            return CommandResult(false, "", "Invalid node: name is required");
        repo.save(node);
        return CommandResult(true, node.id.value, "");
    }

    CommandResult updateNode(TransportNodeDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.nodeId);
        if (existing.isNull)
            return CommandResult(false, "", "Transport node not found");
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.region.length > 0) existing.region = dto.region;
        if (dto.environment.length > 0) existing.environment = dto.environment;
        existing.isForwardEnabled = dto.isForwardEnabled;
        existing.autoImport = dto.autoImport;
        existing.autoImportSchedule = dto.autoImportSchedule;
        existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult enableNode(TenantId tenantId, TransportNodeId id) {
        auto existing = repo.find(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Transport node not found");
        existing.status = NodeStatus.enabled;
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult disableNode(TenantId tenantId, TransportNodeId id) {
        auto existing = repo.find(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Transport node not found");
        existing.status = NodeStatus.disabled;
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteNode(TenantId tenantId, TransportNodeId id) {
        auto existing = repo.find(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Transport node not found");
        repo.remove(existing);
        return CommandResult(true, id.value, "");
    }
}

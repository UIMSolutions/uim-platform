/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.application.usecases.manage.transport_actions;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

class ManageTransportActionsUseCase {
    private TransportActionRepository repo;

    this(TransportActionRepository repo) {
        this.repo = repo;
    }

    TransportAction getAction(TenantId tenantId, TransportActionId id) {
        return repo.findById(tenantId, id);
    }

    TransportAction[] listActions(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    TransportAction[] listActionsByNode(TenantId tenantId, TransportNodeId nodeId) {
        return repo.findByNode(tenantId, nodeId);
    }

    TransportAction[] listActionsByRequest(TenantId tenantId, TransportRequestId requestId) {
        return repo.findByRequest(tenantId, requestId);
    }

    TransportAction[] listActionsByStatus(TenantId tenantId, ActionStatus actionStatus) {
        return repo.findByStatus(tenantId, actionStatus);
    }

    CommandResult recordAction(TransportActionDTO dto) {
        TransportAction action;
        action.id = dto.actionId;
        action.tenantId = dto.tenantId;
        action.nodeId = TransportNodeId(dto.nodeId);
        action.requestId = TransportRequestId(dto.requestId);
        action.routeId = TransportRouteId(dto.routeId);
        action.performedBy = dto.performedBy;
        action.description = dto.description;
        action.logDetails = dto.logDetails;
        if (dto.actionType.length > 0) {
            import std.conv : to;
            try { action.actionType = dto.actionType.to!ActionType; } catch (Exception) {}
        }
        action.actionStatus = ActionStatus.initial;
        if (!TransportValidator.isValidAction(action))
            return CommandResult(false, "", "Invalid action: requestId and performedBy are required");
        repo.save(action);
        return CommandResult(true, action.id.value, "");
    }

    CommandResult updateActionStatus(TenantId tenantId, TransportActionId id, ActionStatus status, string errorMessage = "") {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Transport action not found");
        existing.actionStatus = status;
        if (errorMessage.length > 0) existing.errorMessage = errorMessage;
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }
}

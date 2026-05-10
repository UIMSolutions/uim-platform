/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.application.usecases.manage.transport_requests;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

class ManageTransportRequestsUseCase {
    private TransportRequestRepository repo;

    this(TransportRequestRepository repo) {
        this.repo = repo;
    }

    TransportRequest getRequest(TenantId tenantId, TransportRequestId id) {
        return repo.findById(tenantId, id);
    }

    TransportRequest[] listRequests(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    TransportRequest[] listRequestsByStatus(TenantId tenantId, RequestStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    TransportRequest[] listRequestsByNode(TenantId tenantId, TransportNodeId nodeId) {
        return repo.findBySourceNode(tenantId, nodeId);
    }

    CommandResult createRequest(TransportRequestDTO dto) {
        TransportRequest req;
        req.id = dto.requestId;
        req.tenantId = dto.tenantId;
        req.name = dto.name;
        req.description = dto.description;
        req.externalId = dto.externalId;
        req.version_ = dto.version_;
        req.contentSize = dto.contentSize;
        req.storageUrl = dto.storageUrl;
        req.checksum = dto.checksum;
        req.sourceNodeId = TransportNodeId(dto.sourceNodeId);
        req.namedUser = dto.namedUser;
        req.systemId = dto.systemId;
        req.createdBy = dto.createdBy;
        if (dto.contentType.length > 0) {
            import std.conv : to;
            try { req.contentType = dto.contentType.to!ContentType; } catch (Exception) {}
        }
        req.status = RequestStatus.initial;
        if (!TransportValidator.isValidRequest(req))
            return CommandResult(false, "", "Invalid transport request: name is required");
        repo.save(req);
        return CommandResult(true, req.id.value, "");
    }

    CommandResult updateRequestStatus(TenantId tenantId, TransportRequestId id, RequestStatus status) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Transport request not found");
        existing.status = status;
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteRequest(TenantId tenantId, TransportRequestId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Transport request not found");
        repo.remove(existing);
        return CommandResult(true, id.value, "");
    }
}

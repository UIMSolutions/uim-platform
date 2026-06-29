/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.application.usecases.manage.backend_connections;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

class ManageBackendConnectionsUseCase {
    private IBackendConnectionRepository repo;

    this(IBackendConnectionRepository repo) {
        this.repo = repo;
    }

    BackendConnection getBackendConnection(TenantId tenantId, BackendConnectionId id) {
        return repo.findById(tenantId, id);
    }

    BackendConnection[] listBackendConnections(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    BackendConnection[] listByBackendType(TenantId tenantId, BackendType backendType) {
        return repo.findByBackendType(tenantId, backendType);
    }

    BackendConnection[] listByStatus(TenantId tenantId, ConnectionStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    CommandResult createBackendConnection(BackendConnectionDTO dto) {
        auto conn = BackendConnection(dto.tenantId, dto.connectionId, dto.createdBy);
        conn.name = dto.name;
        conn.description = dto.description;
        conn.backendUrl = dto.backendUrl;
        conn.clientId = dto.clientId;
        conn.authMethod = dto.authMethod;
        conn.sysId = dto.sysId;
        conn.sysNumber = dto.sysNumber;
        conn.client = dto.client;
        conn.language = dto.language;
        conn.destinationName = dto.destinationName;
        conn.sslEnabled = dto.sslEnabled;
        conn.certificateFingerprint = dto.certificateFingerprint;

        if (!AgentryValidator.isValidBackendConnection(conn))
            return CommandResult(false, "", "Invalid backend connection data");

        repo.save(conn);
        return CommandResult(true, conn.id.value, "");
    }

    CommandResult updateBackendConnection(BackendConnectionDTO dto) {
        auto existing = repo.find(dto.tenantId, dto.connectionId);
        if (existing.isNull)
            return CommandResult(false, "", "Backend connection not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.backendUrl.length > 0) existing.backendUrl = dto.backendUrl;
        if (dto.destinationName.length > 0) existing.destinationName = dto.destinationName;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteBackendConnection(TenantId tenantId, BackendConnectionId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)
            return CommandResult(false, "", "Backend connection not found");

        repo.remove(entity);
        return CommandResult(true, entity.id.value, "");
    }
}

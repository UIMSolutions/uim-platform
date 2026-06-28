/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.application.usecases.manage.data_connections;

import uim.platform.build_apps;

// mixin(ShowModule!());

@safe:

class ManageDataConnectionsUseCase { // TODO: UIMUseCase {
    private DataConnectionRepository repo;

    this(DataConnectionRepository repo) {
        this.repo = repo;
    }

    DataConnection getDataConnection(TenantId tenantId, DataConnectionId id) {
        return repo.find(tenantId, id);
    }

    DataConnection[] listDataConnections(TenantId tenantId) {
        return repo.find(tenantId);
    }

    DataConnection[] listConnections(TenantId tenantId) {
        return listDataConnections(tenantId);
    }

    DataConnection[] listDataConnections(TenantId tenantId, ApplicationId applicationId) {
        return repo.findByApplication(applicationId)
            .filter!(e => e.tenantId.value == tenantId.value)
            .array;
    }

    CommandResult createDataConnection(DataConnectionDTO dto) {
        DataConnection e;
        e.initEntity(dto.tenantId, dto.createdBy);

        e.id = dto.connectionId;
        e.applicationId = dto.applicationId;
        e.name = dto.name;
        e.description = dto.description;
        e.baseUrl = dto.baseUrl;
        e.basePath = dto.basePath;
        e.credentials = dto.credentials;
        e.headers = dto.headers;
        e.queryParams = dto.queryParams;
        e.responseMapping = dto.responseMapping;
        e.destinationName = dto.destinationName;
        if (!BuildAppsValidator.isValidDataConnection(e))
            return CommandResult(false, "", "Invalid data connection");

        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    CommandResult updateDataConnection(DataConnectionDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.connectionId);
        if (existing.isNull)
            return CommandResult(false, "", "Data connection not found");
            
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.baseUrl.length > 0) existing.baseUrl = dto.baseUrl;
        if (dto.basePath.length > 0) existing.basePath = dto.basePath;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteDataConnection(TenantId tenantId, DataConnectionId id) {
        auto entity = repo.find(tenantId, id);
        if (entity.isNull)
            return CommandResult(false, "", "Data connection not found");
            
        repo.remove(entity);
        return CommandResult(true, entity.id.value, "");
    }
}

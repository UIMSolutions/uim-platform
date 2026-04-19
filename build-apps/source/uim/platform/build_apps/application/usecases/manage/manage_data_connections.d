/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.application.usecases.manage.manage_data_connections;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class ManageDataConnectionsUseCase { // TODO: UIMUseCase {
    private DataConnectionRepository repo;

    this(DataConnectionRepository repo) {
        this.repo = repo;
    }

    DataConnection getById(DataConnectionId id) {
        return repo.findById(id);
    }

    DataConnection[] list() {
        return repo.findAll();
    }

    DataConnection[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    DataConnection[] listByApplication(ApplicationId applicationId) {
        return repo.findByApplication(applicationId);
    }

    CommandResult create(DataConnectionDTO dto) {
        DataConnection e;
        e.id = DataConnectionId(dto.id);
        e.tenantId = dto.tenantId;
        e.applicationId = ApplicationId(dto.applicationId);
        e.name = dto.name;
        e.description = dto.description;
        e.baseUrl = dto.baseUrl;
        e.basePath = dto.basePath;
        e.credentials = dto.credentials;
        e.headers = dto.headers;
        e.queryParams = dto.queryParams;
        e.responseMapping = dto.responseMapping;
        e.destinationName = dto.destinationName;
        e.createdBy = dto.createdBy;
        if (!BuildAppsValidator.isValidDataConnection(e))
            return CommandResult(false, "", "Invalid data connection");
        repo.save(e);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(DataConnectionDTO dto) {
        if (!repo.existsById(DataConnectionId(dto.id)))
            return CommandResult(false, "", "Data connection not found");
        auto existing = repo.findById(DataConnectionId(dto.id));
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.baseUrl.length > 0) existing.baseUrl = dto.baseUrl;
        if (dto.basePath.length > 0) existing.basePath = dto.basePath;
        if (dto.modifiedBy.length > 0) existing.modifiedBy = dto.modifiedBy;
        repo.update(existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(DataConnectionId id) {
        if (!repo.existsById(id))
            return CommandResult(false, "", "Data connection not found");
        repo.remove(id);
        return CommandResult(true, id.value, "");
    }
}
